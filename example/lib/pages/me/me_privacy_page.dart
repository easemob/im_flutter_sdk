
import 'package:easeim_flutter_demo/pages/me/me_black_list_page.dart';
import 'package:easeim_flutter_demo/widgets/common_widgets.dart';
import 'package:flutter/material.dart';

class MePrivacyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("隐私"),
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
                "黑名单", 
                height: 64,
                onTap: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (ctx){
                        return MeBlackListPage();
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