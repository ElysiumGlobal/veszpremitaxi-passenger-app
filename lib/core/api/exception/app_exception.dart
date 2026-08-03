import '../../../widgets/app_snackbar.dart';

class AppException implements Exception {
  late final String message;
  final String? tag;
  final int errorCode;

  AppException({required this.message, required this.errorCode, this.tag});

  int getErrorCode() => errorCode;

  String getMessage() => message;

  String getMessageWithTag() => "${tag ?? 'No Tag'} : $message";

  String? getTag() => tag;

  @override
  String toString() {
    return "${errorCode.toString()} : ${tag ?? 'No Tag'} : $message";
  }

  void show() {
    AppSnackBar.showErrorSnackBar(message: message, isError: true);
  }
}
