import 'dart:convert';

import 'package:ai_app/tools/Webservice/api_throwable.dart';


class RequestResultContainer<T> {
  String code = "";
  String? message;
  T? value;
  String? debugDescription;
  Map<String, dynamic>? originObject;
  dynamic originData;
  Error? error;

  late Function(Map<String, dynamic>) deserializable;

  RequestResultContainer(Map<String, dynamic> jsonObject,
   Function(Map<String, dynamic>) deserializable) {
    this.originObject = jsonObject;
    this.deserializable = deserializable;
    processData();
  }

  void processData() {
    try {
      if (originObject != null && originObject!.isNotEmpty) {
        code = originObject!["code"] as String;
        message = originObject!["message"] as String?;
        debugDescription = originObject!["debug_description"] as String?;

        if (code == "200" ) {
          var data = originObject!["data"];
          originData = data;
          this.value = deserializable(data);
        } else {
          ApiThrowable(code, info: message);
        }
      }
    } catch (e) {
      error = e as Error?;
    }
  }
}