import 'dart:convert';

import 'package:ai_app/config.dart';
import 'package:ai_app/tools/Webservice/api_throwable.dart';
import 'package:ai_app/tools/Webservice/file_info_model.dart';
import 'package:ai_app/tools/Webservice/request_result_container.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:http_parser/http_parser.dart';
import 'package:package_info_plus/package_info_plus.dart';

class WebServiceHelper {
  static final dio = Dio()..options.headers["APPID"] = "";

  static Future<Map<String, dynamic>> toMap(
      Map<String, dynamic> map, String apiName) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    map["client_platform"] = "iOS";
    map["api_name"] = apiName;
    map["interface_version"] = apiVersion;
    map["client_os_version"] = iosDeviceInfo.systemVersion;
    map["client_app_version"] = packageInfo.version;
    map["udid"] = await FlutterUdid.udid;
    // map["token"] = UserRepository.instance().user?.token ?? "";
    // map["user_id"] =
    //     map["user_id"] ?? UserRepository.instance().user?.user_id ?? "";
    map["device_type"] = iosDeviceInfo.model;
    map["client_time"] =
        (DateTime.now().millisecondsSinceEpoch / 1000).round().toString();
    // map["latitude"] = "${lat == 0 ? "" : lat}";
    // map["longitude"] = "${lng == 0 ? "" : lng}";
    return map;
  }

  static Future<RequestResultContainer<T>> requestOriginData<T>(Map<String, dynamic> map, String apiName) async {
    // final body = AESHelper().encrypt(json.encode(await toMap(map, apiName)));
    final body = await toMap(map, apiName);
    print("request body $map");
    Response response = await dio.post(apiUrl, data: body);
    print(response.statusCode);
    if (response.statusCode == 200) {
      // final data = AESHelper().decrypt(response.data);
      var value = jsonDecode(response.data);
      // String content = json.decode(AESHelper().decrypt(response.data));
      print(value);
      final container = RequestResultContainer<T>(value, RequestReusltType.originData);
      return container;
    } else {
      return RequestResultContainer<T>({}, 
      RequestReusltType.originData,
      error: ApiThrowable("-1", info: "未知错误"));
    }
  }

  static Future<RequestResultContainer<T>> request<T>(Map<String, dynamic> map, String apiName,
      Function(Map<String, dynamic>) deserializable) async {
    // final body = AESHelper().encrypt(json.encode(await toMap(map, apiName)));
    final body = await toMap(map, apiName);
    print("request body $map");
    Response response = await dio.post(apiUrl, data: body);
    print(response.statusCode);
    if (response.statusCode == 200) {
      // final data = AESHelper().decrypt(response.data);
      var value = jsonDecode(response.data);
      // String content = json.decode(AESHelper().decrypt(response.data));
      print(value);
      final container = RequestResultContainer<T>(value, RequestReusltType.model, deserializable: deserializable);
      return container;
    } else {
      return RequestResultContainer<T>({}, 
      RequestReusltType.model, 
      deserializable: deserializable, 
      error: ApiThrowable("-1", info: "未知错误"));
    }
  }

  static Future<RequestResultContainer<T>> requestList<T>(
      Map<String, dynamic> map, String apiName, Function(Map<String, dynamic>) deserializable) async {
    final resultMap = await toMap(map, "");
    print("请求 $resultMap");
    // final body = AESHelper().encrypt(json.encode(map));
    final body = resultMap;
    Response response = await dio.post(apiUrl, data: body);
    print(response.statusCode);
    if (response.statusCode == 200) {
      // final data = AESHelper().decrypt(response.data);
      var value = jsonDecode(response.data);
      print("返回数据 $value");

      final container = RequestResultContainer<T>(value, RequestReusltType.array, deserializable: deserializable);
      return container;
    } else {
      return RequestResultContainer<T>({}, 
      RequestReusltType.array, 
      deserializable: deserializable, 
      error: ApiThrowable("-1", info: "未知错误"));
    }
  }

  static Future<RequestResultContainer<T>> uploadImages<T>(Map<String, dynamic> map, String apiName,
      Function(Map<String, dynamic>) deserializable, List<String> files) async {
    // final body = AESHelper().encrypt(json.encode(await toMap(map, apiName)));
    final body = await toMap(map, apiName);
    print("request body $map");
    List<MultipartFile> list = [];
    for (final file in files) {
      list.add(MultipartFile.fromFileSync(file,
          contentType: MediaType.parse("image/jpeg")));
    }
    Response response = await dio.post(apiUrl,
        data: FormData.fromMap({"data": body, "img": list}));
    print(response.statusCode);
    if (response.statusCode == 200) {
      // final data = AESHelper().decrypt(response.data);
      var value = jsonDecode(response.data);
      // String content = json.decode(AESHelper().decrypt(response.data));
      print(value);

      final container = RequestResultContainer<T>(value, RequestReusltType.model, deserializable: deserializable);

      return container;
    } else {
      return RequestResultContainer<T>({}, 
      RequestReusltType.model, 
      deserializable: deserializable, 
      error: ApiThrowable("-1", info: "未知错误"));
    }
  }

  static Future<T> uploadFiles<T>(Map<String, dynamic> map, String apiName,
      Function(Map<String, dynamic>) deserializable, List<FileInfoModel> files,
      {ProgressCallback? onSendProgress = null, bool isSameFiles = true}) async {
    // final body = AESHelper().encrypt(json.encode(await toMap(map, apiName)));
    final body = await toMap(map, apiName);
    print("request body $map");

    Map<String, MediaType> mimeMap = {
      "img": MediaType.parse("image/jpeg"),
      "video": MediaType.parse("video/mp4"),
      "voice": MediaType.parse("audio/amr"),
    };

    FormData formData = FormData();
    Map<String, dynamic> uploadMap = {"data": body};
    if (isSameFiles) {
      List<MultipartFile> imageList = [];
      String key = "";
      if (files.isNotEmpty) {
        key = files.first.uploadKey;

        for (final file in files) {
          imageList.add(MultipartFile.fromFileSync(
            file.path,
            filename: file.name,
            contentType: mimeMap[file.uploadKey],
          ));
        }

        uploadMap.addAll({key: imageList});
      }
    } else {
      if (files.isNotEmpty) {
        for (final file in files) {
          uploadMap.addEntries({
            MapEntry(
                file.uploadKey,
                MultipartFile.fromFileSync(
                  file.path,
                  filename: file.name,
                  contentType: mimeMap[file.uploadKey],
                ))
          });
        }
      }
    }
    formData = FormData.fromMap(uploadMap);

    Response response = await dio.post(apiUrl,
        data: formData, onSendProgress: onSendProgress);
    print(response.statusCode);
    if (response.statusCode == 200) {
      // final data = AESHelper().decrypt(response.data);
      var value = jsonDecode(response.data);
      // String content = json.decode(AESHelper().decrypt(response.data));
      print(value);
      return deserializable(value);
    }
    throw Exception("网络错误");
  }
}