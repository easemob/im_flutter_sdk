import 'package:easeim_flutter_demo/widgets/common_widgets.dart';
import 'package:easeim_flutter_demo/widgets/time_range_picker_dialog.dart';
import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

class MeCurrencyPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MeCurrencyPageState();
}

class MeCurrencyPageState extends State<MeCurrencyPage> {

  bool noDisturb = false;
  bool showInput = false;
  bool autoAcceptGroupInvitation = EMClient.getInstance.options.autoAcceptGroupInvitation;
  bool deleteMessagesAsExitGroup = EMClient.getInstance.options.deleteMessagesAsExitGroup;

  int beginTime = 0;
  int endTime = 24;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("通用"),
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
    List<Widget>contents = [];
    contents.add(
      commonCellWidget(
        "消息免打扰",
        arrowShow: false,
        rightChildren: [
          Switch(
            value: this.noDisturb, 
            onChanged: (value){
              this.noDisturb = value;
              this.setState(() {
                
              });
            }
          )
        ],
      )
    );
    if (this.noDisturb) {
      contents.add(
        commonCellWidget(
          "起止时间不能相同",
          rightChildren: [
            Text(this.noDisturbTimeString()),
          ],
          onTap: () {
            showTimeRangePickerDialog(
              context,
              (begin, end) {
                this.beginTime = begin;
                this.endTime = end;
                this.setState(() {
                  
                });
              },
              beginTime: this.beginTime,
              endTime: this.endTime,
            );
          }
        )
      );
    }
    contents.addAll([
      SizedBox(height: 10,),
      commonCellWidget("多语言"),
      SizedBox(height: 10,),
      commonCellWidget(
        "显示输入状态",
        arrowShow: false,
        rightChildren: [
          Switch(
            value: this.showInput, 
            onChanged: (value){
              this.showInput = value;
              this.setState(() {
                
              });
            }
          )
        ],
      ),
      SizedBox(height: 10,),
      commonCellWidget(
        "自动接受群组邀请",
        arrowShow: false,
        rightChildren: [
          Switch(
            value: this.autoAcceptGroupInvitation, 
            onChanged: (value){
              this.autoAcceptGroupInvitation = value;
              EMClient.getInstance.options.autoAcceptGroupInvitation = value;
              this.setState(() {
                
              });
            }
          )
        ],
      ),
      commonCellWidget(
        "退出群组时删除会话",
        arrowShow: false,
        rightChildren: [
          Switch(
            value: this.deleteMessagesAsExitGroup, 
            onChanged: (value){
              this.deleteMessagesAsExitGroup = value;
              EMClient.getInstance.options.deleteMessagesAsExitGroup = value;
              this.setState(() {
                
              });
            }
          )
        ],
      ),
    ]);
    return contents;
  }

  String noDisturbTimeString() {
    if (this.beginTime == 0 && this.endTime == 24) {
      return "全天";
    }
    return "${this.beginTime}:00 ~ ${this.endTime}:00";
  }
}