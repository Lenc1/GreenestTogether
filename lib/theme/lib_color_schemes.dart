import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(4278218243),
      surfaceTint: Color(4278218243),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4282889274),
      onPrimaryContainer: Color(4278195712),
      secondary: Color(4282083634),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4294967295),
      onSecondaryContainer: Color(4280767520),
      tertiary: Color(4278216075),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4280854753),
      onTertiaryContainer: Color(4278194716),
      error: Color(4290386458),
      onError: Color(4294967295),
      errorContainer: Color(4294957782),
      onErrorContainer: Color(4282449922),
      surface: Color(4294967295),
      onSurface: Color(0xFF2F2E33),
      onSurfaceVariant: Color(4282337850),
      outline: Color(4285496169),
      outlineVariant: Color(4290693814),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281086505),
      inversePrimary: Color(4285587038),
      primaryFixed: Color(4287429751),
      onPrimaryFixed: Color(4278198784),
      primaryFixedDim: Color(4285587038),
      onPrimaryFixedVariant: Color(4278211329),
      secondaryFixed: Color(4294967295),
      onSecondaryFixed: Color(4278198784),
      secondaryFixedDim: Color(4294967295),
      onSecondaryFixedVariant: Color(4280504348),
      tertiaryFixed: Color(4291160063),
      onTertiaryFixed: Color(4278197805),
      tertiaryFixedDim: Color(4286566655),
      onTertiaryFixedVariant: Color(4278209642),
      surfaceDim: Color(4292205774),
      surfaceBright: Color(4294967295),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4293916391),
      surfaceContainer: Color(4293521633),
      surfaceContainerHigh: Color(4293192412),
      surfaceContainerHighest: Color(4292797910),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(4278210305),
      surfaceTint: Color(4278218243),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4279076876),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4280241176),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4283531334),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4278208612),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4278222251),
      onTertiaryContainer: Color(4294967295),
      error: Color(4287365129),
      onError: Color(4294967295),
      errorContainer: Color(4292490286),
      onErrorContainer: Color(4294967295),
      surface: Color(4294967295),
      onSurface: Color(0xFF2F2E33),
      onSurfaceVariant: Color(4282074678),
      outline: Color(4283916882),
      outlineVariant: Color(4285693548),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281086505),
      inversePrimary: Color(4285587038),
      primaryFixed: Color(4279076876),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4278217730),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4283531334),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4281951791),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4278222251),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4278215560),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4292205774),
      surfaceBright: Color(4294967295),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4293916391),
      surfaceContainer: Color(4293521633),
      surfaceContainerHigh: Color(4293192412),
      surfaceContainerHighest: Color(4292797910),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(4278200576),
      surfaceTint: Color(4278218243),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4278210305),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4278200576),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4280241176),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4278199606),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4278208612),
      onTertiaryContainer: Color(4294967295),
      error: Color(4283301890),
      onError: Color(4294967295),
      errorContainer: Color(4287365129),
      onErrorContainer: Color(4294967295),
      surface: Color(4294967295),
      onSurface: Color(4278190080),
      onSurfaceVariant: Color(4280035097),
      outline: Color(4282074678),
      outlineVariant: Color(4282074678),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281086505),
      inversePrimary: Color(4294967295),
      primaryFixed: Color(4278210305),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4278203648),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4280241176),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4278596868),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4278208612),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4278202437),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4292205774),
      surfaceBright: Color(4294967295),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4293916391),
      surfaceContainer: Color(4293521633),
      surfaceContainerHigh: Color(4293192412),
      surfaceContainerHighest: Color(4292797910),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(4285587038),
      surfaceTint: Color(4285587038),
      onPrimary: Color(4278204929),
      primaryContainer: Color(4279076876),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4294967295),
      onSecondary: Color(4278860039),
      secondaryContainer: Color(4279978005),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4286566655),
      onTertiary: Color(4278203466),
      tertiaryContainer: Color(4278222251),
      onTertiaryContainer: Color(4294967295),
      error: Color(4294948011),
      onError: Color(4285071365),
      errorContainer: Color(4287823882),
      onErrorContainer: Color(4294957782),
      surface: Color(4279178509),
      onSurface: Color(4292797910),
      onSurfaceVariant: Color(4290693814),
      outline: Color(4287140993),
      outlineVariant: Color(4282337850),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4292797910),
      inversePrimary: Color(4278218243),
      primaryFixed: Color(4287429751),
      onPrimaryFixed: Color(4278198784),
      primaryFixedDim: Color(4285587038),
      onPrimaryFixedVariant: Color(4278211329),
      secondaryFixed: Color(4294967295),
      onSecondaryFixed: Color(4278198784),
      secondaryFixedDim: Color(4294967295),
      onSecondaryFixedVariant: Color(4280504348),
      tertiaryFixed: Color(4291160063),
      onTertiaryFixed: Color(4278197805),
      tertiaryFixedDim: Color(4286566655),
      onTertiaryFixedVariant: Color(4278209642),
      surfaceDim: Color(4279178509),
      surfaceBright: Color(4281613105),
      surfaceContainerLowest: Color(4278849544),
      surfaceContainerLow: Color(0xFF2F2E33),
      surfaceContainer: Color(4279968024),
      surfaceContainerHigh: Color(4280626210),
      surfaceContainerHighest: Color(4281349933),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(4285916002),
      surfaceTint: Color(4285587038),
      onPrimary: Color(4278197248),
      primaryContainer: Color(4281902637),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4289058965),
      onSecondary: Color(4278197248),
      secondaryContainer: Color(4285308255),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4287353855),
      onTertiary: Color(4278196517),
      tertiaryContainer: Color(4278229971),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294949553),
      onError: Color(4281794561),
      errorContainer: Color(4294923337),
      onErrorContainer: Color(4278190080),
      surface: Color(0xFF2F2E33),
      onSurface: Color(4294376942),
      onSurfaceVariant: Color(4290957242),
      outline: Color(4288325523),
      outlineVariant: Color(4286285684),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4292797910),
      inversePrimary: Color(4278211841),
      primaryFixed: Color(4287429751),
      onPrimaryFixed: Color(4278195712),
      primaryFixedDim: Color(4285587038),
      onPrimaryFixedVariant: Color(4278206465),
      secondaryFixed: Color(4294967295),
      onSecondaryFixed: Color(4278195712),
      secondaryFixedDim: Color(4294967295),
      onSecondaryFixedVariant: Color(4279385868),
      tertiaryFixed: Color(4291160063),
      onTertiaryFixed: Color(4278194974),
      tertiaryFixedDim: Color(4286566655),
      onTertiaryFixedVariant: Color(4278205266),
      surfaceDim: Color(4279178509),
      surfaceBright: Color(4281613105),
      surfaceContainerLowest: Color(4278849544),
      surfaceContainerLow: Color(0xFF2F2E33),
      surfaceContainer: Color(4279968024),
      surfaceContainerHigh: Color(4280626210),
      surfaceContainerHighest: Color(4281349933),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(4294049768),
      surfaceTint: Color(4285587038),
      onPrimary: Color(4278190080),
      primaryContainer: Color(4285916002),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4294049768),
      onSecondary: Color(4278190080),
      secondaryContainer: Color(4289058965),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4294507519),
      onTertiary: Color(4278190080),
      tertiaryContainer: Color(4287353855),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294965753),
      onError: Color(4278190080),
      errorContainer: Color(4294949553),
      onErrorContainer: Color(4278190080),
      surface: Color(4279178509),
      onSurface: Color(4294967295),
      onSurfaceVariant: Color(4294115305),
      outline: Color(4290957242),
      outlineVariant: Color(4290957242),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4292797910),
      inversePrimary: Color(4278202880),
      primaryFixed: Color(4288151425),
      onPrimaryFixed: Color(4278190080),
      primaryFixedDim: Color(4285916002),
      onPrimaryFixedVariant: Color(4278197248),
      secondaryFixed: Color(4290835887),
      onSecondaryFixed: Color(4278190080),
      secondaryFixedDim: Color(4289058965),
      onSecondaryFixedVariant: Color(4278197248),
      tertiaryFixed: Color(4291750911),
      onTertiaryFixed: Color(4278190080),
      tertiaryFixedDim: Color(4287353855),
      onTertiaryFixedVariant: Color(4278196517),
      surfaceDim: Color(0xFF2F2E33),
      surfaceBright: Color(4281613105),
      surfaceContainerLowest: Color(4278849544),
      surfaceContainerLow: Color(0xFF2F2E33),
      surfaceContainer: Color(4279968024),
      surfaceContainerHigh: Color(4280626210),
      surfaceContainerHighest: Color(4281349933),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }


  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    scaffoldBackgroundColor: colorScheme.background,
    canvasColor: colorScheme.surface,
  );


  List<ExtendedColor> get extendedColors => [
  ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
