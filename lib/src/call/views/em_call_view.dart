import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

typedef CreatedCallback(EMRTCView view, int id);

enum EMRTCViewType { local, remote }

class EMRTCView extends StatefulWidget {

  static const String viewTypeId = 'com.easemob.rtc/CallView';
  final CreatedCallback onCreated;
  final EMRTCViewType viewType;
  final _EMRTCViewStatus state = _EMRTCViewStatus();

  EMRTCView({this.onCreated, this.viewType})
      : super(key: Key('EMRTCView[${DateTime.now().millisecondsSinceEpoch}]'));

  @override
  State<StatefulWidget> createState() => state;

  get id => state.id;
}

class _EMRTCViewStatus extends State<EMRTCView> {
  int id;

  @override
  Widget build(BuildContext context) {
    return _platformView();
  }

  Widget _platformView() {
    final Map<String, dynamic> viewMap = {"tag": widget.viewType == EMRTCViewType.local ? 0 : 1};
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidView(
          viewType: EMRTCView.viewTypeId,
          creationParams: viewMap,
          hitTestBehavior: PlatformViewHitTestBehavior.transparent,
          creationParamsCodec: StandardMessageCodec(),
          onPlatformViewCreated: _onViewCreated,
        );
      case TargetPlatform.iOS:
        return UiKitView(viewType: EMRTCView.viewTypeId,
          creationParams: viewMap,
          hitTestBehavior: PlatformViewHitTestBehavior.transparent,
          creationParamsCodec: StandardMessageCodec(),
          onPlatformViewCreated: _onViewCreated,
        );
      default:
        assert(false);
        return null;
    }
  }

  @override
  void dispose() {
    EMClient.getInstance.callManager.releaseVideoView(id, widget.viewType);
    EMLog.v('RTCView release');
    super.dispose();
  }

  void _onViewCreated(int id) {
    this.id = id;
    if (widget.onCreated != null) {
      widget.onCreated(widget, widget.id);
    }
  }
}

class EMRTCRemoteView extends EMRTCView {
    EMRTCRemoteView(CreatedCallback callback): super(onCreated: callback, viewType: EMRTCViewType.remote);
}

class EMRTCLocalView extends EMRTCView {
  EMRTCLocalView(CreatedCallback callback): super(onCreated: callback, viewType: EMRTCViewType.local);
}