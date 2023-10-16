// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
// ignore_for_file: type=lint
import 'dart:ffi' as ffi;

class NativeLibrary {
  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  NativeLibrary(ffi.DynamicLibrary dynamicLibrary)
      : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  NativeLibrary.fromLookup(
      ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
          lookup)
      : _lookup = lookup;

  /// 由Flutter主动调用，用于初始化模型
  void alert_init() {
    return _alert_init();
  }

  late final _alert_initPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function()>>('alert_init');
  late final _alert_init = _alert_initPtr.asFunction<void Function()>();

  /// 由Flutter主动调用，用于判断是否准备好
  int is_alert_ready() {
    return _is_alert_ready();
  }

  late final _is_alert_readyPtr =
      _lookup<ffi.NativeFunction<ffi.Int Function()>>('is_alert_ready');
  late final _is_alert_ready = _is_alert_readyPtr.asFunction<int Function()>();

  /// 由Flutter调用此函数完成图片的上传，注意，不要在此函数实现内同步进行推理，而是异步，实现内部维护一个有大小限制的FIFO队列。
  /// 返回0表示成功。
  int post_alert_img(
    ffi.Pointer<ffi.Void> bgra_data,
    int len,
    int cam_id,
  ) {
    return _post_alert_img(
      bgra_data,
      len,
      cam_id,
    );
  }

  late final _post_alert_imgPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(ffi.Pointer<ffi.Void>, ffi.Size,
              ffi.UnsignedInt)>>('post_alert_img');
  late final _post_alert_img = _post_alert_imgPtr
      .asFunction<int Function(ffi.Pointer<ffi.Void>, int, int)>();

  /// 由Flutter主动调用，用于获取最新的alert数据。
  /// 注意：如果没有最新message，那么返回nullptr即可。否则，返回一个生命周期独立（不用free，交给flutter做内存管理）的Alert。
  ffi.Pointer<Alert> get_latest_alert_msg() {
    return _get_latest_alert_msg();
  }

  late final _get_latest_alert_msgPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<Alert> Function()>>(
          'get_latest_alert_msg');
  late final _get_latest_alert_msg =
      _get_latest_alert_msgPtr.asFunction<ffi.Pointer<Alert> Function()>();
}

/// AI报警Header
final class Alert extends ffi.Struct {
  @ffi.Int()
  external int alert_type;

  @ffi.Int()
  external int cam_id;

  external ffi.Pointer<ffi.Void> img;

  @ffi.Size()
  external int img_size;
}
