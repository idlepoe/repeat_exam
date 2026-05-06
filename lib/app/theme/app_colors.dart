import 'package:flutter/material.dart';

/// Colors not covered by [ColorScheme] (success states, overlays).
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.successMuted,
    required this.errorMuted,
    required this.info,
    required this.infoContainer,
    required this.onInfoContainer,
    required this.scrim,
  });

  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;

  /// Softer success tint (borders / inactive correct state).
  final Color successMuted;

  /// Softer error tint (borders / wrong state backgrounds).
  final Color errorMuted;

  final Color info;
  final Color infoContainer;
  final Color onInfoContainer;

  final Color scrim;

  static const light = AppColors(
    success: Color(0xFF2E7D32),
    onSuccess: Color(0xFFFFFFFF),
    successContainer: Color(0xFFEAF6EA),
    onSuccessContainer: Color(0xFF1B5E20),
    successMuted: Color(0xFF7CB67C),
    errorMuted: Color(0xFFE28E8E),
    info: Color(0xFF1976D2),
    infoContainer: Color(0xFFF5F9FF),
    onInfoContainer: Color(0xFF0D47A1),
    scrim: Color(0x73000000),
  );

  static const dark = AppColors(
    success: Color(0xFF81C784),
    onSuccess: Color(0xFF003D00),
    successContainer: Color(0xFF1B3D1F),
    onSuccessContainer: Color(0xFFC8E6C9),
    successMuted: Color(0xFF558B59),
    errorMuted: Color(0xFF9E5C5C),
    info: Color(0xFF90CAF9),
    infoContainer: Color(0xFF1A2D42),
    onInfoContainer: Color(0xFFBBDEFB),
    scrim: Color(0xB3000000),
  );

  @override
  AppColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? successMuted,
    Color? errorMuted,
    Color? info,
    Color? infoContainer,
    Color? onInfoContainer,
    Color? scrim,
  }) {
    return AppColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      successMuted: successMuted ?? this.successMuted,
      errorMuted: errorMuted ?? this.errorMuted,
      info: info ?? this.info,
      infoContainer: infoContainer ?? this.infoContainer,
      onInfoContainer: onInfoContainer ?? this.onInfoContainer,
      scrim: scrim ?? this.scrim,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t)!,
      onSuccessContainer:
          Color.lerp(onSuccessContainer, other.onSuccessContainer, t)!,
      successMuted: Color.lerp(successMuted, other.successMuted, t)!,
      errorMuted: Color.lerp(errorMuted, other.errorMuted, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      onInfoContainer:
          Color.lerp(onInfoContainer, other.onInfoContainer, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
    );
  }
}

extension AppColorsX on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
