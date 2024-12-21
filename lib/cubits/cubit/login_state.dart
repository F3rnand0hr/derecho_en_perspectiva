part of 'login_cubit.dart';


class LoginState {
  final bool isLoading;
  final bool hasError;
  final bool hasData;
  final String? error;

  LoginState(
    {required this.isLoading, required this.hasError, required this.hasData, this.error});

  LoginState copyWith(isLoading,hasError,hasData,error) {
    return LoginState(isLoading: isLoading, hasError: hasError, hasData: hasData);
  }
}
