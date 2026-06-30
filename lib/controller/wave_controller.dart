import 'package:vibe_now/core/constant/api_constant.dart';
import 'package:vibe_now/services/custom_http.dart';

import 'package:get/get.dart';

class WaveController extends GetxController {
  final RxBool isLoading = false.obs;

  // wave action
  Future<bool> waveAction({required int waveId, required String action}) async {
    isLoading(true);
    final response = await CustomHttp.post(
      need_auth: true,
      endpoint: ApiConstant.waveOperation(waveId: waveId),
      body: {'action': action},
    );
    isLoading(false);
    return response.ok;
  }
}
