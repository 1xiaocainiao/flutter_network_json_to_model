import 'dart:convert';

import 'package:ai_app/tools/Webservice/api_throwable.dart';


enum RequestReusltType { originData, model, array }

class RequestResultContainer<T> {
  String code = "";
  String? message;

  T? value;
  List<T>? values;

  String? debugDescription;
  Map<String, dynamic>? originObject;
  ApiThrowable? error;

  Function(Map<String, dynamic>)? _deserializable;

  late RequestReusltType _type;

  RequestResultContainer(Map<String, dynamic> jsonObject,
   RequestReusltType type,
   {Function(Map<String, dynamic>)? deserializable, ApiThrowable? error}) {
    this.originObject = jsonObject;
    this._type = type;
    this._deserializable = deserializable;
    this.error = error;
    processData();
  }

  void processData() {
    try {
      if (originObject != null && originObject!.isNotEmpty) {
        code = originObject!["code"] as String;
        message = originObject!["message"] as String?;
        debugDescription = originObject!["debug_description"] as String?;

        if (code == "200" ) {
          final data = originObject!["data"];
          
          if (_type == RequestReusltType.model) {
            if (_deserializable != null) {
              this.value = _deserializable!(data);
            }
          } else if (_type == RequestReusltType.array) {
            if (_deserializable != null) {
              this.values = List<T>.from(data.map((e) => _deserializable!(e)));
            }
          } else {
            this.value = data;
          }
        } else {
          this.error = ApiThrowable(code, info: message);
        }
      } else {
        print("返回数据错误");
        if (error == null) {
          this.error = ApiThrowable("-1", info: "返回数据错误");
        }
      }
    } catch (e) {
      print(e.toString());
      
      if (e is ApiThrowable) {
        this.error = e;
      } else {
        if (error == null) {
          this.error = ApiThrowable("-1", info: "未知错误");
        }
      }
    }
  }
}