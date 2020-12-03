import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/db/Task.dart';

class TaskWidget extends StatelessWidget {
  Task data;
  bool isDelete;
  Function onCheckChange;
  Function onDelete;
  TaskWidget({this.data,this.isDelete=false,this.onCheckChange,this.onDelete});
  ValueKey key;

  @override
  Widget build(BuildContext context) {
    if(data!=null)
    key=ValueKey(data.title);
    return  data!=null?Row(
      children: <Widget>[
        Checkbox(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          value: !data.isActive,
          onChanged: onCheckChange,
        ),
        Text(
          data.title,
          style: TextStyle(
            fontSize: 18,
            decoration: !data.isActive?TextDecoration.lineThrough:TextDecoration.none,
          ),
        ),
        Spacer(),
        if(isDelete)
        InkWell(onTap:onDelete,child: Icon(Icons.delete_outline,color: Color(0xFFBDBDBD),))
      ],
    ):Container();
  }
}
