# im_flutter_sdk

集成SDK：
在flutter项目中的 pubspec.yaml 里面的 dependencies: 下添加
im_flutter_sdk:
    git:
      url: https://github.com/easemob/im_flutter_sdk.git

然后 Package get 一下，将SDK下载下来

想使用SDK方法时导入SDK头文件即可： import 'package:im_flutter_sdk/im_flutter_sdk.dart';  

SDK的方法说明文档见：[Easemob IM Flutter SDK API文档](https://easemob.github.io/im_flutter_sdk):

A new flutter plugin project.

## Getting Started

## 生成文档

SDK API文档由以下命令生成,线上文档请参看[Easemob IM Flutter SDK API文档](https://easemob.github.io/im_flutter_sdk):

```shell

dartdoc --exclude dart:io,dart:async,dart:ui,dart:math,dart:collection,dart:convert,dart:core,dart:developer,dart:isolate,dart:typed_data --output doc
```


## SDK简要说明
