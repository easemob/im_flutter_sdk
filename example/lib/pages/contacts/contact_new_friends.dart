import 'package:easeim_flutter_demo/widgets/demo_app_bar.dart';
import 'package:flutter/material.dart';

class ContactNewFirends extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ContactNewFirendsState();
}

class ContactNewFirendsState extends State<ContactNewFirends> {
  bool _isDone = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DemoAppBar.normal(
        '好友申请',
      ),
      body: ListView.builder(
        itemCount: 20,
        itemBuilder: (_, index) {
          return Card(
            elevation: 5, //阴影
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            color: Colors.white, //颜色
            margin: EdgeInsets.all(20), //margin
            child: Container(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Container(
                      child: Text(
                        "du001添加您为好友",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: EdgeInsets.all(0),
                    child: _isDone
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              FlatButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {},
                                child: Text(
                                  '同意',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              FlatButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {},
                                child: Text(
                                  '拒绝',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Text(
                            '已处理',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
