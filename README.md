# Carousel - Automatic Wallpaper Changer

A Flutter application that automatically changes your device wallpaper with customizable features and settings.

## Features

- **Automatic Wallpaper Rotation**: Automatically changes wallpapers at specified intervals
- **Custom Wallpaper Selection**: Choose your own wallpaper collection
- **Scheduling Options**: Set custom timing for wallpaper changes
- **Background Service**: Continues to work even when the app is closed
- **Boot Persistence**: Automatically restarts after device reboot
- **Notification Controls**: Easy access to wallpaper controls via notifications
- **Battery Optimized**: Designed to minimize battery impact

## Project Workflow

1. **Application Launch**
   - App initializes through MainActivity
   - Checks and requests necessary permissions
   - Sets up background services

2. **Wallpaper Service**
   - WallpaperChangeService runs in the background
   - Manages scheduling of wallpaper changes
   - Handles periodic updates

3. **Wallpaper Management**
   - WallpaperChanger handles actual wallpaper changes
   - WallpaperManagerHelper provides utility functions
   - Manages file operations and system interactions

4. **Notification System**
   - NotificationHelper manages user notifications
   - Provides status updates and controls
   - Maintains notification channels

5. **System Integration**
   - WallpaperRestartReceiver ensures service persistence
   - Handles system events (boot, updates, etc.)
   - Maintains app functionality across system changes

## Getting Started

1. Clone the repository
2. Ensure Flutter is installed and set up
3. Run `flutter pub get` to install dependencies
4. Connect a device or emulator
5. Run `flutter run` to start the application

## Requirements

- Android 5.0 (API level 21) or higher
- Flutter 2.0 or higher
- Sufficient storage for wallpaper files

## Permissions Required

- READ_EXTERNAL_STORAGE: For accessing wallpaper files
- SET_WALLPAPER: For changing device wallpaper
- RECEIVE_BOOT_COMPLETED: For service restart after device boot

## Contributing

Contributions are welcome! Please feel free to submit pull requests.

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Android Developer Documentation](https://developer.android.com/)
