
import 'package:easeim_flutter_demo/pages/me/me_multi_device_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:easeim_flutter_demo/widgets/common_widgets.dart';

class MeAccountAndSafePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("账号与安全"),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 20,
              ),
              commonCellWidget(
                "多端设备管理", 
                height: 64,
                onTap: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (ctx){
                        return MeMultiDeviceListPage();
                      }
                    )
                  );
                }
              ),
            ],
          ),
        ),
      ),
    );
  }
}