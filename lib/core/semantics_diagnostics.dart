import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

/// 在首次语义树断言时记录组件来源；不改变错误处理或无障碍行为。
/// 仅从 assert 中安装，发布版本不会启用。
void installSemanticsDiagnostics() {
  final previousHandler = FlutterError.onError;
  FlutterErrorDetails? firstError;
  var reported = false;

  FlutterError.onError = (details) {
    final isParentDataError =
        details.exceptionAsString().contains('!semantics.parentDataDirty');
    firstError ??= details;

    if (previousHandler != null) {
      previousHandler(details);
    } else {
      FlutterError.presentError(details);
    }

    if (!isParentDataError || reported) return;
    reported = true;

    debugPrintSynchronously('=== SEMANTICS DIAGNOSTICS BEGIN ===');
    if (!identical(firstError, details)) {
      debugPrintSynchronously('本次运行中更早的首条异常：');
      FlutterError.dumpErrorToConsole(firstError!, forceReport: true);
    }
    FlutterError.dumpErrorToConsole(details, forceReport: true);

    // 候选节点可能包含被其他节点遮挡的合法脏节点，需结合组件链判断。
    var count = 0;
    void visit(RenderObject object) {
      if (count >= 8) return;
      if (object.debugNeedsSemanticsUpdate) {
        count++;
        debugPrintSynchronously('候选节点 $count: ${object.toStringShort()}');
        debugPrintSynchronously('组件链: ${object.debugCreator}');
        // 保留最高的脏节点，避免其整个子树占满日志。
        return;
      }
      object.visitChildrenForSemantics(visit);
    }

    for (final view in RendererBinding.instance.renderViews) {
      visit(view);
    }
    debugPrintSynchronously('=== SEMANTICS DIAGNOSTICS END ===');
  };
}
