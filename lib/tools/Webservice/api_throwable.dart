

class ApiThrowable implements Exception {
  String code = "";
  String? info;

  ApiThrowable(this.code, {this.info});

  String message() {
    switch (code) {
      case "-1":
        return "Something went wrong, please try again.";
      case "50049":
        return "This guy has deactivated his account.";
      case "50058":
      case "50053":
      case "50081":
        return "This guy has been banned!";
      default:
        return info ?? "未知错误";
    }
  }
}

class NetWorkError extends ApiThrowable {
  NetWorkError() : super("-1");
}
