#include "alert_controller.h"

#include <Windows.h>
#include <onnxruntime/onnxruntime_cxx_api.h>

#include <cstdio>
#include <cstdlib>
#include <iostream>
#include <opencv2/core/core.hpp>
#include <opencv2/opencv.hpp>
#include <string>
#include <thread>
#include <vector>
#include <cmath>
#include <random>
// #include <onnxruntime/core/providers/providers.h>
// #include <onnxruntime/core/providers/cpu/cpu_provider_factory.h>
#include <fstream>
// #ifdef __cplusplus
// extern "C" {
// #endif

using namespace Ort;
using namespace std;
using namespace cv;

static int cnt = 0;
static bool use_yolo_v8 = false;

Env* env = nullptr;
/// @brief yolov5
Session* yolo_session = nullptr;
SessionOptions* yolo_session_options;
/// @brief resnet18
Session* cloth_cnn_session = nullptr;
SessionOptions* cloth_cnn_session_options;
static int is_ready = false;
uchar lut[256];

static Mat resize_image(Mat srcimg, int* newh, int* neww, int* top, int* left) {
  int srch = srcimg.rows, srcw = srcimg.cols;
  int inpHeight = 640;
  int inpWidth = 640;
  *newh = inpHeight;
  *neww = 640;
  bool keep_ratio = true;
  Mat dstimg;
  if (keep_ratio && srch != srcw) {
    float hw_scale = (float)srch / srcw;
    if (hw_scale > 1) {
      *newh = inpHeight;
      *neww = int(inpWidth / hw_scale);
      resize(srcimg, dstimg, Size(*neww, *newh), INTER_AREA);
      *left = int((inpWidth - *neww) * 0.5);
      copyMakeBorder(dstimg, dstimg, 0, 0, *left, inpWidth - *neww - *left,
                     BORDER_CONSTANT, 0);
    } else {
      *newh = (int)(inpHeight * hw_scale);
      *neww = inpWidth;
      resize(srcimg, dstimg, Size(*neww, *newh), INTER_AREA);
      *top = (int)((inpHeight - *newh) * 0.5);
      copyMakeBorder(dstimg, dstimg, *top, inpHeight - *newh - *top, 0, 0,
                     BORDER_CONSTANT, 0);
    }
  } else {
    resize(srcimg, dstimg, Size(*neww, *newh), INTER_AREA);
  }
  return dstimg;
}

std::vector<float> softmax(const std::vector<float>& input) {
    std::vector<float> result;
    float sum = 0.0;

    // 计算指数求和
    for (float value : input) {
        float expValue = std::exp(value);
        sum += expValue;
        result.push_back(expValue);
    }
    // 归一化
    for (float& value : result) {
        value /= sum;
    }
    return result;
}


int cnn_yolo_inference(Session* session, Mat dstimg, size_t width = 640, size_t height = 640) {
  AllocatorWithDefaultOptions allocator;
  // size_t num_input_nodes = session->GetInputCount();
  vector<const char*> input_node_names = {"input"};
  vector<const char*> output_node_names = {"output"};
  size_t input_tensor_size = 3 * width * height;
  vector<float> input_tensor_values(input_tensor_size);

  for (int c = 0; c < 3; c++) {
    for (int i = 0; i < width; i++) {
      for (int j = 0; j < height; j++) {
        float pix = dstimg.ptr<uchar>(i)[j * 3 + 2 - c];
        input_tensor_values[c * width * height + i * width + size_t(j)] =
            (float)(pix / 255.0);
      }
    }
  }
  vector<int64_t> input_node_dims = {1, 3, (int64_t)width, (int64_t)height};
  auto memory_info =
      MemoryInfo::CreateCpu(OrtArenaAllocator, OrtMemTypeDefault);
  Value input_tensor = Value::CreateTensor<float>(
      memory_info, input_tensor_values.data(), input_tensor_size,
      input_node_dims.data(), input_node_dims.size());

  vector<Value> ort_inputs;
  ort_inputs.push_back(move(input_tensor));
  vector<Value> output_tensors =
      session->Run(RunOptions{nullptr}, input_node_names.data(),
                   ort_inputs.data(), input_node_names.size(),
                   output_node_names.data(), output_node_names.size());
  const float* rawOutput = output_tensors[0].GetTensorData<float>();
  // size_t count =
  //     output_tensors[0].GetTensorTypeAndShapeInfo().GetElementCount();
  vector<float> output(rawOutput, rawOutput + 2);
  output = softmax(output);
  // std::cout << output[0] << " " << output[1] << " " << std::endl;
  // float output_0_log = log(output[0]);
  // float output_1_log = log(output[1]);
  if (output[0] > output[1] && output[0] > 0.9) {
    // 没穿，非常自信没穿
    return 0;
  } else {
    // 穿了
    return 1;
  }
}

/// @brief 模型推理代码
/// @param session
/// @param dstimg 640x640x3分辨率mat
/// @param boxes
/// @param confs
/// @param classIds
/// @return
vector<int> alert_yolo_inference(Session* session, Mat dstimg,
                                 vector<Rect>& boxes, vector<float>& confs,
                                 vector<int>& classIds) {
  AllocatorWithDefaultOptions allocator;
  // size_t num_input_nodes = session->GetInputCount();
  vector<const char*> input_node_names = {"images"};
  vector<const char*> output_node_names = {"output0"};
  size_t input_tensor_size = 3 * 640 * 640;
  vector<float> input_tensor_values(input_tensor_size);

  for (int c = 0; c < 3; c++) {
    for (int i = 0; i < 640; i++) {
      for (int j = 0; j < 640; j++) {
        float pix = dstimg.ptr<uchar>(i)[j * 3 + 2 - c];
        input_tensor_values[c * 640 * 640 + i * 640 + size_t(j)] =
            (float)(pix / 255.0);
      }
    }
  }
  vector<int64_t> input_node_dims = {1, 3, 640, 640};
  auto memory_info =
      MemoryInfo::CreateCpu(OrtArenaAllocator, OrtMemTypeDefault);
  Value input_tensor = Value::CreateTensor<float>(
      memory_info, input_tensor_values.data(), input_tensor_size,
      input_node_dims.data(), input_node_dims.size());

  vector<Value> ort_inputs;
  ort_inputs.push_back(move(input_tensor));
  vector<Value> output_tensors =
      session->Run(RunOptions{nullptr}, input_node_names.data(),
                   ort_inputs.data(), input_node_names.size(),
                   output_node_names.data(), output_node_names.size());
  const float* rawOutput = output_tensors[0].GetTensorData<float>();
  vector<int64_t> outputShape =
      output_tensors[0].GetTensorTypeAndShapeInfo().GetShape();
  size_t count =
      output_tensors[0].GetTensorTypeAndShapeInfo().GetElementCount();
  vector<float> output(rawOutput, rawOutput + count);

  int numClasses = (int)outputShape[2] - 5;
  int elementsInBatch = (int)(outputShape[1] * outputShape[2]);
  float confThreshold = 0.8f;

  for (auto it = output.begin(); it != output.begin() + elementsInBatch;
       it += outputShape[2]) {
    float clsConf = *(it + 4);  // object scores
    if (clsConf > confThreshold) {
      int centerX = (int)(*it);
      int centerY = (int)(*(it + 1));
      int width = (int)(*(it + 2));
      int height = (int)(*(it + 3));
      int x1 = centerX - width / 2;
      int y1 = centerY - height / 2;
      boxes.emplace_back(Rect(x1, y1, width, height));
      // first 5 element are x y w h and obj confidence
      int bestClassId = -1;
      float bestConf = 0.0;
      for (int i = 5; i < numClasses + 5; i++) {
        if ((*(it + i)) > bestConf) {
          bestConf = it[i];
          bestClassId = i - 5;
        }
      }
      confs.emplace_back(clsConf);
      classIds.emplace_back(bestClassId);
    }
  }

  float iouThreshold = 0.5;
  vector<int> indices;
  dnn::NMSBoxes(boxes, confs, confThreshold, iouThreshold,
                indices);  // �Ǽ���ֵ����
  return indices;
}
extern "C" {
DllExport void alert_init() {
  auto version = ORT_API_VERSION;
  printf("onnx runtime version %d\n", version);
  printf("cv version %s\n", CV_VERSION);
  WCHAR path[MAX_PATH];
  GetModuleFileNameW(NULL, path, MAX_PATH);
  std::wstring exe_path(path);
  size_t last = exe_path.find_last_of(L"\\");
  exe_path = exe_path.substr(0, last);
  // std::wcout << path << std::endl;
  env = new Env(ORT_LOGGING_LEVEL_WARNING, "yolov5s-5.0");
  yolo_session_options = new SessionOptions();
  std::wstring yolo_path =
      exe_path + L"\\data\\flutter_assets\\assets\\models\\yolov5s.onnx";
  yolo_session = new Session(*env, yolo_path.c_str(), *yolo_session_options);
  yolo_session_options->SetIntraOpNumThreads(1);
  yolo_session_options->SetGraphOptimizationLevel(
      GraphOptimizationLevel::ORT_ENABLE_EXTENDED);

  cloth_cnn_session_options = new SessionOptions();
  std::wstring cloth_cnn_path =
      exe_path + L"\\data\\flutter_assets\\assets\\models\\resnet.onnx";
  cloth_cnn_session =
      new Session(*env, cloth_cnn_path.c_str(), *cloth_cnn_session_options);
  cloth_cnn_session_options->SetIntraOpNumThreads(1);
  cloth_cnn_session_options->SetGraphOptimizationLevel(
      GraphOptimizationLevel::ORT_ENABLE_EXTENDED);
  is_ready = 1;
  // lut
  for (int i = 0; i < 256; i++) {
    // Enhance white color by increasing intensity
    lut[i] = cv::saturate_cast<uchar>(1.2 * i);
  }
}

/// 由Flutter主动调用，用于判断是否准备好
DllExport int is_alert_ready() { return is_ready; }

/// 由Flutter调用此函数完成图片的上传，注意，不要在此函数实现内同步进行推理，而是异步，实现内部维护一个有大小限制的FIFO队列〄1�7
/// 注意：bgra_data生命周期由Flutter管理，异步的话请做copy
DllExport int post_alert_img(PredictBean* bean) {
  vector<Rect> boxes;
  vector<float> confs;
  vector<int> classIds;
  try {
    Mat srcimg(bean->height, bean->width, CV_8UC4, (void*)bean->bgra_data,
               bean->stride);
    Mat tmp;
    cv::cvtColor(srcimg, tmp, cv::COLOR_BGRA2BGR);
    cv::LUT(tmp, cv::Mat(1, 256, CV_8U, lut), tmp);
    int newh = 0, neww = 0, padh = 0, padw = 0;
    Mat dstimg = resize_image(tmp, &newh, &neww, &padh, &padw);  // Padded
                                                                 // resize
    vector<int> indices =
        alert_yolo_inference(yolo_session, dstimg, boxes, confs, classIds);
    RNG rng((unsigned)time(NULL));
    for (size_t i = 0; i < indices.size(); ++i)  // ���˳���indices������4��ֵ
    {
      int index = indices[i];
      if (classIds.size() <= index || classIds[index] != 0) continue;
      float scores = round(confs[index] * 100) / 100;
      ostringstream oss;
      oss << scores;
      // remove padding
      // 640x640
      // double x_rate = bean->width * 1.0 / 640;
      // double y_rate = bean->height * 1.0 / 640;
      // double rate = max(x_rate, y_rate);

      int x1, y1, x2, y2;
      x1 = min(max(0, int(((boxes[index].tl().x - padw) * 1.0 / neww) *
                          bean->width)),
               bean->width);
      y1 = min(max(0, int(((boxes[index].tl().y - padh) * 1.0 / newh) *
                          bean->height)),
               bean->height);
      x2 = min(max(0, int(((boxes[index].br().x - padw) * 1.0 / neww) *
                          bean->width)),
               bean->width);
      y2 = min(max(0, int(((boxes[index].br().y - padh) * 1.0 / newh) *
                          bean->height)),
               bean->height);
      // std::cout << x1 << " " << y1 << " " << x2 << " " << y2 << " " << padw
      // << " " <<neww << std::endl;
      Point pt1(x1, y1);
      Point pt2(x2, y2);
      rectangle(srcimg, pt1, pt2, Scalar(0, 0, 255), 6);
      // rectangle(tmp, pt1, pt2, Scalar(0, 0, 255), 6);
      Rect roi(pt1.x, pt1.y, pt2.x - pt1.x, pt2.y - pt1.y);
      Mat cropped_img = resize_image(tmp(roi), &newh, &neww, &padh,
                                 &padw);  // Padded resize
      Mat cropped_img_resized;
      cv::resize(cropped_img, cropped_img_resized, cv::Size(224, 224));
      // 白大褂检测
      boxes.clear();
      confs.clear();
      classIds.clear();
      // // std::cout << "yolo: not wearing!" << std::endl;
      //   string s = "d-";
      //   s += to_string(cnt++);
      //   s += ".png";
      cv::imwrite(bean->uuid, cropped_img);
      if (cnn_yolo_inference(cloth_cnn_session, cropped_img_resized, 224, 224) == 0) {
          // 有人没穿白大褂
          // std::cout << "not wearing!" << std::endl;
          // string s = "n-";
          // s += to_string(cnt++);
          // s += ".png";
          // cv::imwrite(s.c_str(), cropped_img);
          return 1;
        } else {
          // string s = "y-";
          // s += to_string(cnt++);
          // s += ".png";
          // cv::imwrite(s.c_str(), cropped_img);
          // std::cout << "weared" << std::endl;
        }
    }
  } catch (const std::exception& e) {
    std::cerr << e.what() << '\n';
  }
  // 没有人没穿白大褂
  return 0;
}
}

// /// 由Flutter主动调用，用于获取最新的alert数据
// ///
// 注意：如果没有最新message，那么返回nullptr即可。否则，返回丢�个生命周期独立（不用free，交给flutter做内存管理）的Alert
// DllExport Alert* get_latest_alert_msg() {
//   if (tmp_alert == nullptr) {
//     return nullptr;
//   }
//     auto tmp_ptr = tmp_alert;
//     tmp_alert = nullptr;
//     return tmp_ptr;
// }

// // 不要修改实现
// DllExport void free_alert(Alert* alert) {
//   if (alert->img != nullptr && alert->img_size > 0) {
//     alert->img = nullptr;
//   }
//   free(alert);
// }

// #ifdef __cplusplus
// }
// #endif
