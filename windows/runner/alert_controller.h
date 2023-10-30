#define DllExport __declspec(dllexport)
/// AI报警Header

typedef struct Alert {
  int alert_type;   // 报警类型
  int cam_id;       // 摄像头ID
  const void* img;  // 图片bgra二进制
  size_t img_size;  // 图片长度
  int width;
  int height;
  int stride;
} Alert;

typedef struct PredictBean {
  const void* bgra_data;
  size_t len;
  int cam_id;
  int width;
  int height;
  int stride;
} PredictBean;

#ifdef __cplusplus
extern "C" {
#endif
/// 由Flutter主动调用，用于初始化模型
DllExport void alert_init();

/// 由Flutter主动调用，用于判断是否准备好
DllExport int is_alert_ready();

/// 由Flutter调用此函数完成图片的上传，注意，不要在此函数实现内同步进行推理，而是异步，实现内部维护一个有大小限制的FIFO队列。
/// 返回0表示成功。
DllExport int post_alert_img(PredictBean* bean);

/// 由Flutter主动调用，用于获取最新的alert数据。
/// 注意：如果没有最新message，那么返回nullptr即可。否则，返回一个生命周期独立（不用free，交给flutter做内存管理）的Alert。
DllExport Alert* get_latest_alert_msg();

/// 释放Alert内存
DllExport void free_alert(Alert* alert);
#ifdef __cplusplus
}
#endif