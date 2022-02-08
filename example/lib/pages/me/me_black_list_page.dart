
import 'package:easeim_flutter_demo/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

class MeBlackListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MeBlackListState();
  }
}

class MeBlackListState extends State<MeBlackListPage> {

  List<String> blackList;

  @override
  void initState() {
    super.initState();
    this._loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("黑名单"),
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
                itemCount: this.blackList != null ? this.blackList.length : 0,
                itemBuilder: (ctx, index){
                  return slidableItem(
                    child: Container(
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
                          Text(
                            this.blackList[index]
                          ),
                        ],
                      ),
                    ),
                    // 侧滑事件，有必要可以加上置顶之类的
                    actions: [slidableDeleteAction(onTap: () async {
                      await EMClient.getInstance.contactManager.removeUserFromBlockList(this.blackList[index]);
                      this._loadData();
                    })],
                  );
                },
              ),
              onRefresh: _loadData,
            )
          ),
        ),
      ),
    );
  }

  Future<void> _loadData() async {
    this.blackList = await EMClient.getInstance.contactManager.getBlockListFromServer();
    EMLog.v(this.blackList);
    this.setState(() {
      
    });
  }
}