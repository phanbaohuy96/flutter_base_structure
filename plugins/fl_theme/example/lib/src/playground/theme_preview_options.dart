import 'package:device_frame/device_frame.dart';
import 'package:flutter/material.dart';

class ThemePreviewDevice {
  final String label;
  final DeviceInfo device;

  const ThemePreviewDevice({required this.label, required this.device});
}

class ThemePreviewOptions {
  final bool showDeviceFrame;
  final ThemePreviewDevice selectedDevice;
  final Orientation orientation;

  ThemePreviewOptions({
    this.showDeviceFrame = true,
    ThemePreviewDevice? selectedDevice,
    this.orientation = Orientation.portrait,
  }) : selectedDevice = selectedDevice ?? themePreviewDeviceIPhone13;

  ThemePreviewOptions copyWith({
    bool? showDeviceFrame,
    ThemePreviewDevice? selectedDevice,
    Orientation? orientation,
  }) {
    return ThemePreviewOptions(
      showDeviceFrame: showDeviceFrame ?? this.showDeviceFrame,
      selectedDevice: selectedDevice ?? this.selectedDevice,
      orientation: orientation ?? this.orientation,
    );
  }
}

final themePreviewDeviceIPhone13 = ThemePreviewDevice(
  label: 'iPhone 13',
  device: Devices.ios.iPhone13,
);
final themePreviewDevicePixel9 = ThemePreviewDevice(
  label: 'Pixel 9',
  device: Devices.android.googlePixel9,
);
final themePreviewDeviceMacBookPro = ThemePreviewDevice(
  label: 'MacBook Pro',
  device: Devices.macOS.macBookPro,
);

final themePreviewDevices = [
  themePreviewDeviceIPhone13,
  themePreviewDevicePixel9,
  themePreviewDeviceMacBookPro,
];
