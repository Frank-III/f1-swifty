# Enable Background Picture-in-Picture

To make Picture-in-Picture work when the app is minimized (backgrounded), you need to configure your app's background modes in Xcode.

## Steps to Enable Background PiP:

### 1. Open Project Settings
1. Open your project in Xcode
2. Select the "F1DashAppXCode" project in the navigator
3. Select the "F1DashAppXCode" target

### 2. Enable Background Modes
1. Go to the "Signing & Capabilities" tab
2. Click the "+" button to add a capability
3. Add "Background Modes"
4. Check the following options:
   - ✅ **Audio, AirPlay, and Picture in Picture**

### 3. Configure Info.plist (if needed)
If you have a custom Info.plist, add:
```xml
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
</array>
```

### 4. Update the Video PiP Manager

The `VideoBasedPictureInPictureManager` is already configured correctly with:
- `AVAudioSession` setup for playback mode
- Real-time rendering with `AVSampleBufferDisplayLayer`
- Proper delegate implementations

## Testing Background PiP:

1. **Start the app** and connect to a live session
2. **Activate video PiP** using:
   ```swift
   await appEnvironment.videoBasedPictureInPictureManager.startVideoPiP()
   ```
3. **Minimize the app** (press Home button or swipe up)
4. **PiP window should appear** automatically on the home screen

## Important Notes:

- **Simulator Limitations**: PiP may not work perfectly in the simulator. Test on a real device for best results.
- **iOS Version**: Requires iOS 14.0+ for AVPictureInPictureController with AVSampleBufferDisplayLayer
- **Audio Session**: The app maintains an audio session even though we're only displaying video (muted) - this is required for background PiP

## Triggering Video PiP:

Add a button in your UI to start video PiP:

```swift
Button("Start Video PiP") {
    Task {
        await appEnvironment.videoBasedPictureInPictureManager.startVideoPiP()
    }
}
.disabled(!AVPictureInPictureController.isPictureInPictureSupported())
```

## Alternative: Automatic PiP on Background

To automatically start PiP when the app goes to background:

```swift
.onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
    Task {
        await appEnvironment.videoBasedPictureInPictureManager.startVideoPiP()
    }
}
```

## Troubleshooting:

1. **PiP not appearing**: Check that background modes are enabled in project settings
2. **PiP stops immediately**: Ensure AVAudioSession is properly configured
3. **No PiP button in video**: The system PiP is handled programmatically, not through standard video controls