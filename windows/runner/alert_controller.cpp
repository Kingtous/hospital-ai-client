#include "alert_controller.h"

#include <cstdio>
#include <cstdlib>
#include <thread>

#ifdef __cplusplus
extern "C" {
#endif

Alert* tmp_alert = nullptr;

DllExport void alert_init() {
}

/// 由Flutter主动调用，用于判断是否准备好
DllExport int is_alert_ready() { return 1; }

/// 由Flutter调用此函数完成图片的上传，注意，不要在此函数实现内同步进行推理，而是异步，实现内部维护一个有大小限制的FIFO队列。
/// 返回0表示成功。
/// 注意：bgra_data生命周期由Flutter管理，异步的话请做拷贝
DllExport int post_alert_img(PredictBean* bean) {
  // for debug, please impl this.
  if (tmp_alert == nullptr) {
    tmp_alert = (Alert*)malloc(sizeof(Alert));
    tmp_alert->alert_type = 1;
    tmp_alert->cam_id = bean->cam_id;
    void* buf = malloc(bean->len + 1);
    memcpy(buf, bean->bgra_data, bean->len);
    ((uint8_t*) buf)[bean->len] = '\0';
    tmp_alert->img = buf;
    tmp_alert->img_size = bean->len;
    tmp_alert->height = bean->height;
    tmp_alert->width = bean->width;
    tmp_alert->stride = bean->stride;
  }
  return 1;
}

/// 由Flutter主动调用，用于获取最新的alert数据。
/// 注意：如果没有最新message，那么返回nullptr即可。否则，返回一个生命周期独立（不用free，交给flutter做内存管理）的Alert。
DllExport Alert* get_latest_alert_msg() { 
  auto ret = tmp_alert;
  tmp_alert = nullptr;
  return ret;
 }

// 不要修改实现
DllExport void free_alert(Alert* alert) {
  if (alert->img != nullptr && alert->img_size > 0) {
    free((void*)alert->img);
    alert->img = nullptr;
  }
  free(alert);
}
#ifdef __cplusplus
}
#endif
