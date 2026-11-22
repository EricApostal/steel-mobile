import 'dart:ffi' show Abi;

import 'package:steelmc_api/steelmc_api.dart';

/// The SteelMC build matching this device, or null if none is published for it
/// (e.g. 32-bit ARM).
SteelTarget? detectSteelTarget() => switch (Abi.current()) {
      Abi.androidArm64 => SteelTarget.androidAarch64,
      Abi.androidX64 => SteelTarget.androidX86_64,
      _ => null,
    };
