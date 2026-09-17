/// An event reported by the native side of the plugin.
sealed class SecureScreenEvent {
  const SecureScreenEvent();
}

/// iOS only.
final class ScreenshotTaken extends SecureScreenEvent {
  const ScreenshotTaken();

  @override
  bool operator ==(Object other) => other is ScreenshotTaken;

  @override
  int get hashCode => (ScreenshotTaken).hashCode;

  @override
  String toString() => 'ScreenshotTaken()';
}

/// Screen recording, AirPlay or mirroring started or stopped. iOS only.
final class CaptureStateChanged extends SecureScreenEvent {
  const CaptureStateChanged({required this.captured});

  /// Whether the screen is being captured now.
  final bool captured;

  @override
  bool operator ==(Object other) =>
      other is CaptureStateChanged && other.captured == captured;

  @override
  int get hashCode => Object.hash(CaptureStateChanged, captured);

  @override
  String toString() => 'CaptureStateChanged(captured: $captured)';
}
