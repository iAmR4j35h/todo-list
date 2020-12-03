
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
part 'Task.g.dart';
@HiveType(typeId: 0)
class Task extends HiveObject{

  @HiveField(0)
  String title;
  @HiveField(1)
  bool isActive;
  Task(this.title,this.isActive);
}