import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/constant/api_constant.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/core/routes/routes.dart';
import 'package:vibe_now/controller/profile_controller.dart';
import 'package:vibe_now/services/custom_http.dart';
import 'package:vibe_now/services/local_storage.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  var isRefreshing = false.obs;

  // FOR REFRESH TOKEN
  bool _isRefreshing = false;
  Completer<bool>? _refreshCompleter;

  // user signup
  Future<Map<String, String>?> signup({
    required String emailAddress,
    required String password,
    required BuildContext context,
  }) async {
    try {
      isLoading.value = true;
      final response = await CustomHttp.post(
        show_floating_error: false,
        endpoint: ApiConstant.signup,
        body: {"email_address": emailAddress.trim(), "password": password},
        need_auth: false,
      );

      final data = response.data ?? {};

      if (response.ok) {
        final userId = data['data'] != null ? data['data']['user_id'] : '';
        await LocalStorage.user_id.set(userId ?? '');

        print("user id after sign up =====>$userId");

        final message = data['message'] ?? 'Account created successfully';
        _safeShowSnack(context, message, SnackType.info);

        await Future.delayed(const Duration(milliseconds: 500));
        return {'user_id': userId, 'email_address': emailAddress};
      } else {
        final message =
            data['message']?.toString() ??
            response.error ??
            'Something went wrong. Try again';
        debugPrint("message =====>$message");
        _safeShowSnack(context, message, SnackType.error);
        return null;
      }
    } catch (e) {
      _safeShowSnack(context, 'Network error. Try again.', SnackType.error);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // user sign up otp verification
  Future<bool> signupOtpVerification({
    required String userId,
    required String otp,
    required BuildContext context,
  }) async {
    try {
      isLoading.value = true;

      final response = await CustomHttp.post(
        endpoint: ApiConstant.verifyEmail,
        body: {"user_id": userId, "verification_code": otp.trim()},
        need_auth: false,
      );

      final data = response.data ?? {};

      if (response.ok) {
        final accessToken = data['data']?['tokens']?['access'] ?? '';
        final refreshToken = data['data']?['tokens']?['refresh'] ?? '';
        final userId = data['data']?['user']?['id'] ?? '';

        print("user id after sign up otp verification =====>$userId");

        // Save to local storage
        await LocalStorage.access_token.set(accessToken);
        await LocalStorage.refresh_token.set(refreshToken);
        await LocalStorage.user_id.set(userId);

        final message = data['message'] ?? 'OTP verified successfully.';
        _safeShowSnack(context, message, SnackType.info);

        await Future.delayed(const Duration(milliseconds: 500));
        return true;
      } else {
        final message = data['message'] ?? 'Something went wrong. Try again';
        _safeShowSnack(context, message, SnackType.error);
        return false;
      }
    } catch (e) {
      _safeShowSnack(context, 'Network error. Try again.', SnackType.error);

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Otp Resent
  Future<bool> otpResent({
    required String userId,
    required String purpose,
    required BuildContext context,
  }) async {
    try {
      isLoading.value = true;

      final response = await CustomHttp.post(
        endpoint: ApiConstant.resentOtp,
        body: {"user_id": userId, "purpose": purpose},
        need_auth: false,
      );

      final data = response.data ?? {};

      if (response.ok) {
        final message = data['message'] ?? 'OTP resent successfully';
        _safeShowSnack(context, message, SnackType.info);

        return true;
      } else {
        final message =
            data['message'] ??
            response.error?.toString() ??
            'Something went wrong. Try again';
        _safeShowSnack(context, message, SnackType.error);
        return false;
      }
    } catch (e) {
      _safeShowSnack(context, 'Network error. Try again.', SnackType.error);

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // user login
  Future<Map<String, dynamic>?> login({
    required String emailAddress,
    required String password,
    required BuildContext context,
  }) async {
    try {
      isLoading.value = true;

      final response = await CustomHttp.post(
        show_floating_error: false,
        endpoint: ApiConstant.signIn,
        body: {"email_address": emailAddress.trim(), "password": password},
        need_auth: false,
      );

      final data = response.data ?? {};

      if (response.ok) {
        print("data after login =======> $data");
        final message = data['message'] ?? 'Login successful';
        _safeShowSnack(context, message, SnackType.info);

        final accessToken = data['data']?['tokens']?['access'] ?? '';
        final refreshToken = data['data']?['tokens']?['refresh'] ?? '';
        final userId = data['data']?['user']?['id'] ?? '';

        print("user id after sign up otp verification =====>$userId");

        // Save to local storage
        await LocalStorage.access_token.set(accessToken);
        await LocalStorage.refresh_token.set(refreshToken);
        await LocalStorage.user_id.set(userId);

        await Future.delayed(const Duration(milliseconds: 500));
        return data['data'] as Map<String, dynamic>?;
      } else {
        final message =
            data['message']?.toString() ??
            response.error?.toString() ??
            'Something went wrong. Try again';
        _safeShowSnack(context, message, SnackType.error);
        return null;
      }
    } catch (e) {
      _safeShowSnack(context, '=====${e.toString()}', SnackType.error);
      debugPrint("error ${e.toString()}");
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh token
  Future<bool> refreshToken() async {
    if (_isRefreshing) {
      return _refreshCompleter?.future ?? false;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<bool>();

    try {
      final storedRefreshToken = await LocalStorage.refresh_token.get();

      if (storedRefreshToken == null || storedRefreshToken.isEmpty) {
        await logout();
        _refreshCompleter!.complete(false);
        return false;
      }

      final response = await CustomHttp.post(
        endpoint: ApiConstant.refreshToken,
        body: {"refresh_token": storedRefreshToken},
        need_auth: false,
        show_floating_error: false,
      );

      final data = response.data ?? {};

      if (!response.ok) {
        await logout();
        _refreshCompleter!.complete(false);
        return false;
      }

      final tokens = data['data']?['tokens'];

      final access = tokens?['access'];
      final refresh = tokens?['refresh'];

      if (access == null || access.isEmpty) {
        await logout();
        _refreshCompleter!.complete(false);
        return false;
      }

      await LocalStorage.access_token.set(access);
      await LocalStorage.refresh_token.set(refresh);

      _refreshCompleter!.complete(true);
      return true;
    } catch (e) {
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }

  // user forget password
  Future<Map<String, String>?> forgetPassword({
    required String emailAddress,
    required BuildContext context,
  }) async {
    try {
      isLoading.value = true;

      final response = await CustomHttp.post(
        show_floating_error: false,
        endpoint: ApiConstant.forgetPassword,
        body: {"email_address": emailAddress.trim()},
        need_auth: false,
      );

      final data = response.data ?? {};

      if (response.ok) {
        final userId = data['data']['user_id'] ?? '';
        final message = data['message'] ?? 'Account created successfully';
        _safeShowSnack(context, message, SnackType.info);

        return {'user_id': userId, 'email_address': emailAddress};
      } else {
        final message =
            data['message'] ??
            response.error ??
            'Something went wrong. Try again';
        _safeShowSnack(context, message, SnackType.error);
        return null;
      }
    } catch (e) {
      _safeShowSnack(context, 'Network error. Try again.', SnackType.error);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // user forgot otp verification
  Future<String?> forgotOtpVerification({
    required String userId,
    required String otp,
    required BuildContext context,
  }) async {
    try {
      isLoading.value = true;

      final response = await CustomHttp.post(
        endpoint: ApiConstant.forgetOtpVerification,
        body: {"user_id": userId, "verification_code": otp.trim()},
        need_auth: false,
      );

      final data = response.data ?? {};

      if (response.ok) {
        final message =
            data['message'] ??
            'OTP verified successfully. Wait for admin approval';
        _safeShowSnack(context, message, SnackType.info);
        return data['data']["secret_key"];
      } else {
        final message =
            data['message'] ??
            response.error ??
            'Something went wrong. Try again';
        _safeShowSnack(context, message, SnackType.error);
        return null;
      }
    } catch (e) {
      _safeShowSnack(context, 'Network error. Try again.', SnackType.error);

      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // User Change Password
  Future<bool> resetPassword({
    required String userId,
    required String secretKey,
    required String newPassword,
    required String confirmPassword,
    required BuildContext context,
  }) async {
    try {
      isLoading.value = true;

      final response = await CustomHttp.post(
        endpoint: ApiConstant.resetPassword,
        body: {
          "user_id": userId,
          "secret_key": secretKey,
          "new_password": newPassword,
          "confirm_password": confirmPassword,
        },
        need_auth: false,
      );

      final data = response.data ?? {};

      if (response.ok) {
        final message = data['message'] ?? 'Password changed successfully';
        _safeShowSnack(context, message, SnackType.info);

        await Future.delayed(const Duration(milliseconds: 500));
        return true;
      } else {
        final message =
            data['message'] ??
            response.error ??
            'Something went wrong. Try again';
        _safeShowSnack(context, message, SnackType.error);
        return false;
      }
    } catch (e) {
      _safeShowSnack(context, 'Network error. Try again.', SnackType.error);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await LocalStorage.clear();
    // Clear any cached profile data so it doesn't flash on next visit
    Get.find<ProfileController>().clearProfile();
    // setupRouter(false);
    appRouter.goNamed(RouteNames.splashScreen);
  }

  void _safeShowSnack(BuildContext context, String message, SnackType type) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final targetContext =
            Get.overlayContext ??
            Get.context ??
            Get.key.currentContext ??
            context;

        if (targetContext.mounted) {
          AppSnackbar.show(message: message, type: type);
        }
      } catch (e) {
        debugPrint("Snacko Error: $e");
      }
    });
  }
}
