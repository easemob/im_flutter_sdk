import 'package:shared_preferences/shared_preferences.dart';

class SharePreferenceManager {
  static SharePreferenceManager _instance;
  SharedPreferences _prefs;
  Function _callback;
  String _eid;
  static load(eid, {Function callback}) {
    SharePreferenceManager.shareInstance._eid = eid;
    SharePreferenceManager.shareInstance._callback = callback;
    if (callback != null) {
      Future.delayed(Duration(seconds: 2)).then((value) {
        if (SharePreferenceManager.shareInstance._callback != null) {
          SharePreferenceManager.shareInstance._callback();
        }
      });
    }
  }

  static SharePreferenceManager get shareInstance =>
      _instance = _instance ?? SharePreferenceManager._getInstance();

  static clear() {
    SharePreferenceManager.shareInstance._callback = null;
  }

  // 收到好友申请时调用
  static addRequest(String eid) {
    SharePreferenceManager.shareInstance._addRequest(eid);
  }

  // 获取所有好友申请
  static List<String> loadAllRequests() {
    return SharePreferenceManager.shareInstance._loadAllRequests();
  }

  static int loadUnreadCount() {
    List<String> list = loadAllRequests();
    RegExp eidExp = RegExp(r' ');
    int count = 0;
    for (var requestId in list) {
      if (!eidExp.hasMatch(requestId)) {
        count++;
      }
    }
    return count;
  }

  // 处理好友申请
  static updateRequest(String eid, bool agree) {
    SharePreferenceManager.shareInstance._updateRequest(eid, agree);
  }

  // 删除所有好有申请
  static removeAllRequest() {
    SharePreferenceManager.shareInstance._removeAllRequest();
  }

  SharePreferenceManager._getInstance() {
    _loadSharePerference();
  }

  _loadSharePerference() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
  }

  // 收到好友申请时调用
  _addRequest(String eid) {
    List<String> list = loadAllRequests();
    for (var requestId in list) {
      if (requestId.contains(eid)) {
        list.remove(requestId);
        break;
      }
    }
    list.insert(0, eid);
    _prefs?.setStringList(this._eid, list);
  }

  // 获取所有好友申请
  List<String> _loadAllRequests() {
    List<String> list = _prefs?.getStringList(this._eid);
    return list ?? List();
  }

  // 处理好友申请
  _updateRequest(String eid, bool agree) {
    List<String> list = loadAllRequests();
    for (int i = 0; i < list.length; i++) {
      String requestId = list[i];
      if (requestId == eid) {
        // eid ==> eid 0
        requestId = '$requestId ${!agree ? 0 : 1}';
        list[i] = requestId;
        break;
      }
    }

    _prefs?.setStringList(this._eid, list);
  }

  // 删除所有好有申请
  _removeAllRequest() {
    List<String> list = List();
    _prefs?.setStringList(this._eid, list);
  }
}
