
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

class MeMultiDeviceListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MeMultiDeviceListPageState();
  }
}

class MeMultiDeviceListPageState extends State<MeMultiDeviceListPage> {
  
  String password;
  List<EMDeviceInfo> deviceInfoList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("登录设备列表"),
      ),
      backgroundColor: Color(0xFFEEEEEE),
      body: Container(
        margin: EdgeInsets.only(
          left: 0,
          top: 0,
          right: 0,
          bottom: 0,
        ),
        child: Center(
          child: Scrollbar(
            child: RefreshIndicator(
              child: ListView.builder(
                itemCount: this.deviceInfoList != null ? this.deviceInfoList.length : 0,
                itemBuilder: (ctx, index){
                  return Container(
                    padding: EdgeInsets.only(
                      left: 15,
                      top: 10,
                      bottom: 10,
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          "images/login_icon.png",
                          width: 40,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          children: [
                            Text(
                              this.deviceInfoList[index].deviceName
                            ),
                            Text(
                              this.deviceInfoList[index].deviceUUID
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
              ),
              onRefresh: _refresh,
            )
          ),
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    if (this.password == null) {

    }
    this.deviceInfoList = await EMClient.getInstance.getLoggedInDevicesFromServer(username: EMClient.getInstance.currentUsername, password: "123456");
    EMLog.v(this.deviceInfoList.toString());
  }
}
