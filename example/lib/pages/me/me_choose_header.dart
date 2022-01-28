
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert' as convert;

import 'package:im_flutter_sdk/im_flutter_sdk.dart';

class MeChooseHeaderPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MeChooseHeaderPageState();
}

class MeChooseHeaderPageState extends State<MeChooseHeaderPage> with WidgetsBindingObserver {

  Map<String, String> headsMap = {};
  String selectingItemKey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("选择头像"),
      ),
      body: Container(
        margin: EdgeInsets.only(
          left: 30,
          top: 30,
          right: 30,
          bottom: 10,
        ),
        child: Column(
          children: [
            Wrap(
              children: this._getWidgetList(),
              spacing: (MediaQuery.of(context).size.width - (3 * 80) - 60) / 2,
              runSpacing: 20,
            ), 
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _didClickSave,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.blue),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                    ),
                    child: Text(
                      "保存",
                    ),
                  ),
                )
              ],
            ),
          ],
        )
      )
    );
  }

  @override
  void initState() {
    super.initState();
    this.loadData();
  }

  Future<void> loadData() async {
    var uri = Uri.http("download-sdk.oss-cn-beijing.aliyuncs.com", "/downloads/IMDemo/avatar/headImage.conf");
    var httpClient = HttpClient();
    var request = await httpClient.getUrl(uri);
    var response = await request.close();
    httpClient.close();
    if (response.statusCode == HttpStatus.ok) {
      var _content = await response.transform(Utf8Decoder()).join();
      var map = convert.jsonDecode(_content);
      Map headsMap = map["headImageList"];
      headsMap.forEach((key, value) {
        this.headsMap[key] = value;
      });
      this.setState(() {
        
      });
    }
  }

  List<Widget> _getWidgetList() {
    if (this.headsMap == null || this.headsMap.length <= 0) {
      return [];
    }
    List<Widget> list = [];
    this.headsMap.forEach((key, value) {
      var view = InkWell(
        child: Column(
          children: [
            Image.network(
              "https://download-sdk.oss-cn-beijing.aliyuncs.com/downloads/IMDemo/avatar/${value}",
              width: 80,
              height: 80,
            ),
            SizedBox(
              height: 10,
            ),
            Text(key),
          ],
        ),
        onTap: () {
          this.selectingItemKey = key;
        },
      );
      list.add(view);
    });
    return list;
  } 

  void _didClickSave() async {
    if (this.selectingItemKey != null) {
      var value = this.headsMap[this.selectingItemKey];
      var url = "https://download-sdk.oss-cn-beijing.aliyuncs.com/downloads/IMDemo/avatar/${value}";
      await EMClient.getInstance.userInfoManager.updateOwnUserInfoWithType(EMUserInfoType.AvatarURL, url);
      Navigator.pop(context);
    } else {
      showDialog<Null>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('请选择头像'),
            actions: <Widget>[
              TextButton(
                child: Text('确定'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        },
      );
    };
  }

}