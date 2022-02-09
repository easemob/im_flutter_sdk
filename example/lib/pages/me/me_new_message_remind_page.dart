
import 'package:easeim_flutter_demo/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

class MeNewMessageRemindPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MeNewMessageRemindPageState();
  
}

class MeNewMessageRemindPageState extends State<MeNewMessageRemindPage> {

  bool recvMessageNoticeOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("新消息提醒"),
      ),
      body: Container(
        margin: EdgeInsets.only(
          left: 10,
          top: 10,
          right: 10,
          bottom: 10,
        ),
        child: Column(
          children: this.contents()
        ),
      ),
    );
  } 

  List<Widget> contents() {
    List<Widget> contents = [];
    contents.add(
      commonCellWidget(
        "接受新消息通知",
        arrowShow: false,
        rightChildren: [
          Switch(value: this.recvMessageNoticeOpen, onChanged: (value){
            this.recvMessageNoticeOpen = value;
            this.setState(() {
              
            });
          })
        ]
      )
    );
    if (this.recvMessageNoticeOpen) {
      contents.add(
        commonCellWidget(
          "显示消息详情",
          rightChildren: [
            Text("显示消息详情"),
          ],
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (ctx) {
                return Container(
                  margin: EdgeInsets.only(
                    bottom: 40,
                  ),
                  height: 130,
                  child: Column(
                    children: [
                      commonCellWidget(
                        "仅未读提示",
                        rightChildren: [
                          Image.asset("images/contact_select_check.png"),
                        ],
                        arrowShow: false,
                      ),
                      commonCellWidget(
                        "显示消息详情",
                        rightChildren: [
                          Image.asset("images/contact_select_check.png"),
                        ],
                        arrowShow: false,
                      ),
                      Container(
                        height: 40,
                        child: InkWell(
                          onTap: (){
                            Navigator.of(ctx).pop();
                          },
                          child: Column(
                            children: [
                              Spacer(),
                              Row(
                                children: [
                                  Spacer(),
                                  Text("取消"),
                                  Spacer(),
                                ],
                              ),
                              Spacer(),
                            ],
                          ),
                        )  
                      )
                    ],
                  )
                );
              },
            );
          }
        )
      );
    }
    return contents;
  }
}