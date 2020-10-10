import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk_example/utils/localizations.dart';
import 'package:im_flutter_sdk_example/utils/style.dart';
import 'package:im_flutter_sdk_example/utils/theme_util.dart';
import 'package:im_flutter_sdk_example/utils/time_util.dart';
import 'package:im_flutter_sdk_example/utils/widget_util.dart';
import 'package:im_flutter_sdk_example/widgets/progress_dialog.dart';


class EMGroupFilesPage extends StatefulWidget{
  final String _groupId;

  const EMGroupFilesPage(this._groupId);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _EMGroupFilesPageState(this._groupId);
  }
}

class _EMGroupFilesPageState extends State<EMGroupFilesPage>{
  String _groupId;
  List<EMGroupSharedFile> _fileList = [];
  bool _loading = true;

  _EMGroupFilesPageState(this._groupId);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchGroupSharedFile();
  }

  void _fetchGroupSharedFile() async {
    try{
      _fileList = await EMClient.getInstance.groupManager.getGroupFileListFromServer(groupId:_groupId, pageNum: 1, pageSize: 20);
      _refreshUI(false);
    }catch(e){
      WidgetUtil.hintBoxWithDefault(e.toString());
      _refreshUI(false);
    }
  }

  _refreshUI(bool loading) {
    setState(() {
      _loading = loading;
    });
  }

  Widget _buildListView(){
    return ListView.builder(
        itemCount: _fileList.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index){
          return _buildFilesItem(_fileList[index]);
        });
  }

  Widget _buildFilesItem(EMGroupSharedFile file){
    return InkWell(
      onTap: (){
//        WidgetUtil.hintBoxWithDefault('正在下载');
//        EMClient.getInstance.groupManager().downloadGroupSharedFile(groupId: _groupId, fileId: file.getFileId(), savePath: '/storage/emulated/0/DCIM/Camera/'+file.getFileName(),
//        onSuccess: (){
//          WidgetUtil.hintBoxWithDefault('下载成功');
//        },
//        onError: (code, desc){
//          WidgetUtil.hintBoxWithDefault(code.toString() + ':' + desc);
//        });

        WidgetUtil.hintBoxWithDefault('demo暂未实现，api已开放，可自行调用');
      },
      child: Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    width: 0.5,
                    color: ThemeUtils.isDark(context)
                        ? EMColor.darkBorderLine
                        : EMColor.borderLine))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(file.fileName, style: TextStyle(fontSize: 16)),
            Text((file.fileSize / 1024 / 1024).toString().substring(0,4) + 'M',style: TextStyle(fontSize: 12)),
            Text(TimeUtil.convertTime(file.createTime),style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          centerTitle : true,
          backgroundColor: ThemeUtils.isDark(context) ? EMColor.darkAppMain : EMColor.appMain,
          title: Text(DemoLocalizations.of(context).groupFiles, style: TextStyle(fontSize:EMFont.emAppBarTitleFont, color: ThemeUtils.isDark(context) ? EMColor.darkText : EMColor.text)),
          leading: Builder(builder:(BuildContext context){
          return IconButton(
              icon: new Icon(Icons.arrow_back,color: Colors.black),
              onPressed: (){
                Navigator.pop(context);
              }
          );
        }),
        actions: <Widget>[
          // 隐藏的菜单
          new PopupMenuButton<String>(
            icon: new Icon(Icons.more_vert,color: Colors.black,),
            itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
              PopupMenuItem<String>(
                  value: 'upload',
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      // ignore: non_constant_identifier_names
                      new Icon(Icons.arrow_upward, color: Colors.blue),
                      new Text('上传文件'),
                    ],
                  )
              ),
            ],
            onSelected: (String action) {
              // 点击选项的时候
              switch (action) {
                case 'upload':
                  WidgetUtil.hintBoxWithDefault('demo暂未实现，api已开放，可自行调用');
                  break;
              }
            },
          ),
        ],
      ),
      key: UniqueKey(),
      body: Stack(children: <Widget>[
        _buildListView(),
        ProgressDialog(loading: _loading, msg: DemoLocalizations.of(context).loading,),
      ],),

    );
  }
}