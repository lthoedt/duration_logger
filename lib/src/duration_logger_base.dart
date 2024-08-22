/// This class is used to log the time taken by different actions in a class.
class DurationLogger {
  final Map<String, ({int start, int? end})> actionLogs = {};
  final stopwatch = Stopwatch();

  final List<String> timeLogs = [];

  int? previousEndTime;

  DurationLogger() {
    stopwatch.start();
  }

  Future<T> actionStartedAsync<T>(
    String action,
    Future<T> future,
  ) async {
    actionStarted(action);
    final T result = await future;
    actionFinished(action);

    return result;
  }

  T actionStartedSync<T>(
    String action,
    T Function() function,
  ) {
    actionStarted(action);
    final T result = function();
    actionFinished(action);

    return result;
  }

  void actionStarted<T>(String action) {
    final int start = stopwatch.elapsedMilliseconds;
    actionLogs[action] = (start: start, end: null);
  }

  void actionFinished(String action) {
    final int startTime = actionLogs[action]!.start;
    final int endTime = stopwatch.elapsedMilliseconds;
    final int duration = endTime - startTime;

    final int? actionGap =
        previousEndTime != null ? startTime - previousEndTime! : null;

    actionLogs[action] = (start: startTime, end: endTime);

    if (actionGap != null && actionGap > 0) {
      timeLogs.add(
        "\u{2191}\nExecution gap: $actionGap ms\n\u{2193}",
      );
    }
    timeLogs.add(
      "Action: '$action', started: [T = $startTime ms], ended: [T = $endTime ms], duration: $duration ms",
    );
    actionLogs.remove(action);
    previousEndTime = endTime;
  }

  String done() {
    stopwatch.stop();
    return '\n${timeLogs.join("\n")}';
  }
}

extension DurationLoggerFutureExtension<T> on Future<T> {
  Future<T> logTime(
    String action,
    DurationLogger logger,
  ) =>
      logger.actionStartedAsync<T>(action, this);
}

extension DurationLoggerFunctionExtension<T> on T Function() {
  T logTime(
    String action,
    DurationLogger logger,
  ) =>
      logger.actionStartedSync<T>(action, this);
}
