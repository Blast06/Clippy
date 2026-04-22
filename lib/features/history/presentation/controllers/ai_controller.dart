import 'package:get/get.dart';

import '../../../clipboard/presentation/controllers/clipboard_state_controller.dart';
import '../../domain/analysis_result.dart';

class AiController extends GetxController {
  AiController(this._state);

  final ClipboardStateController _state;

  Future<AnalysisResult> analyze(String text) {
    return _state.analyze(text);
  }
}
