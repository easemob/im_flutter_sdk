import 'package:flutter/material.dart';

class EMGroupPickContactsItem extends StatefulWidget{
  final String _member;
  final EMGroupPickContactsItemDelegate _delegate;

  const EMGroupPickContactsItem(this._member, this._delegate);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _EMGroupPickContactsItemState(this._member, this._delegate);
  }
}

class _EMGroupPickContactsItemState extends State<EMGroupPickContactsItem>{
  String _member;
  EMGroupPickContactsItemDelegate _delegate;
  bool _valued = false;

  _EMGroupPickContactsItemState(this._member, this._delegate);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child: CheckboxListTile(
        title: Text(_member),
        value: this._valued,
        onChanged: (bool value) {
          if(this._delegate != null){
            _delegate.onTapContact(_member, value);
          }else {
            print("没有实现 EMGroupPickContactsItemDelegate");
          }
          setState(() {
            this._valued = value;
          });
        },
      ),
    );
  }
}

abstract class EMGroupPickContactsItemDelegate {
  void onTapContact(String contact, bool isSelected);
}