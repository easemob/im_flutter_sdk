# 常见问题：   
打包后真机运行crash报

```Java
Pending exception java.lang.ClassNotFoundException: com.hyphenate.chat.adapter.EMAGroupReadAck
```


混淆规则有问题，可以在app目录下增加proguard-rules.pro  文件，并添加内容
```Java
 -keep class com.hyphenate.** {*;}
 -dontwarn com.hyphenate.**
```

也可以参考文档 [Android打包混淆](https://docs-im.easemob.com/im/android/sdk/import#app_%E6%89%93%E5%8C%85%E6%B7%B7%E6%B7%86) 。

