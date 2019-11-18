import 'dart:core';

class UserInfo {
  String userId;
  String nickName;
  String portraitUrl;
}

class UserInfoDataSource {
  static Map<String,UserInfo> cachedUserMap = new Map();//保证同一 userId

  static UserInfo getUserInfo(String userId) {
    UserInfo cachedUserInfo = cachedUserMap[userId];
    if (cachedUserInfo != null) {
      return cachedUserInfo;
    }


    UserInfo user = new UserInfo();
    user.userId = userId;
    user.nickName = '测试小明';
    user.portraitUrl = '';

    cachedUserMap[userId] = user;
    return user;
  }
//  Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context){
//  return new ChatPage(arguments: {'conversationType': conversation.type,'toChatUsername':conversation.conversationId});
//  }));
//  Navigator.of(context).pushNamed( 'chatPage',arguments: {'conversationType': conversation.type,'toChatUsername':conversation.conversationId});

}