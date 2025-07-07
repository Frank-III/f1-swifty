//
//  StreamingPictureInPictureManager.swift
//  F1-Dash
//
//  Real-time streaming PiP implementation using ReplayKit
//

import SwiftUI
import AVKit
import AVFoundation
#if !os(macOS)
import ReplayKit
#endif

#if !os(macOS)
// iOS-only container for platform-specific properties
private class iOSPiPComponents {
    var broadcastController: RPBroadcastController?
    var broadcastActivityController: RPBroadcastActivityViewController?
    var screenRecorder = RPScreenRecorder.shared()
    var hostingController: UIHostingController<AnyView>?
    var pipWindow: UIWindow?
}
#endif

@MainActor
@Observable
public final class StreamingPictureInPictureManager: NSObject {
    // MARK: - Properties
    
    // AVPlayer for PiP
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var pictureInPictureController: AVPictureInPictureController?
    
    weak var appEnvironment: AppEnvironment?
    
    // Track if PiP is active
    private(set) var isStreamingPiPActive = false
    
    #if !os(macOS)
    // iOS-only components container
    private let iosComponents = iOSPiPComponents()
    #endif
    
    // MARK: - Public Methods
    
    func startStreamingPiP() {
        #if !os(macOS)
        guard AVPictureInPictureController.isPictureInPictureSupported() else {
            print("PiP not supported on this device")
            return
        }
        
        guard let appEnvironment = appEnvironment else {
            print("AppEnvironment not set")
            return
        }
        
        // Create a more direct approach using a hidden window
        setupHiddenWindow(with: appEnvironment)
        #endif
    }
    
    func stopStreamingPiP() {
        #if !os(macOS)
        pictureInPictureController?.stopPictureInPicture()
        cleanupPiP()
        #endif
    }
    
    // MARK: - Private Methods
    
    private func setupHiddenWindow(with appEnvironment: AppEnvironment) {
        #if !os(macOS)
        // Create a hidden window with the track map
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 480, height: 360))
        window.windowLevel = .normal - 1 // Below everything
        window.isHidden = false
        window.alpha = 0.01 // Nearly invisible
        
        // Create the track map view
        let trackMapView = TrackMapPiPContent(appEnvironment: appEnvironment)
            .frame(width: 480, height: 360)
            .background(Color.black)
        
        let hostingController = UIHostingController(rootView: AnyView(trackMapView))
        window.rootViewController = hostingController
        window.makeKeyAndVisible()
        
        iosComponents.pipWindow = window
        iosComponents.hostingController = hostingController
        
        // Use screen recording to capture this window
        setupScreenRecording()
        #endif
    }
    
    private func setupScreenRecording() {
        #if !os(macOS)
        // Check if screen recording is available
        guard RPScreenRecorder.shared().isAvailable else {
            print("Screen recording not available")
            return
        }
        
        // Start in-app screen capture
        iosComponents.screenRecorder.isMicrophoneEnabled = false
        iosComponents.screenRecorder.isCameraEnabled = false
        
        // Start capturing
        iosComponents.screenRecorder.startCapture { [weak self] sampleBuffer, sampleType, error in
            if let error = error {
                print("Screen capture error: \(error)")
                return
            }
            
            // Process the sample buffer
            self?.processSampleBuffer(sampleBuffer, type: sampleType)
        } completionHandler: { error in
            if let error = error {
                print("Failed to start screen capture: \(error)")
            } else {
                print("Screen capture started")
                // Now setup PiP with the captured content
                Task { @MainActor in
                    self.setupPiPFromCapture()
                }
            }
        }
        #endif
    }
    
    #if !os(macOS)
    private func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, type: RPSampleBufferType) {
        // Process video frames here if needed
        // For now, we'll use a different approach
    }
    #endif
    
    private func setupPiPFromCapture() {
        #if !os(macOS)
        // This is where it gets tricky - we need to feed the captured frames to AVPlayer
        // For a simpler approach, let's use the video file method but update it periodically
        
        // Create initial video
        createAndPlayVideo()
        #endif
    }
    
    private func createAndPlayVideo() {
        #if !os(macOS)
        // Similar to VideoBasedPictureInPictureManager but with periodic updates
        // This is a simplified approach for demonstration
        
        // For now, use the custom overlay approach
        appEnvironment?.pictureInPictureManager.activatePiP()
        #endif
    }
    
    private func cleanupPiP() {
        #if !os(macOS)
        iosComponents.screenRecorder.stopCapture { error in
            if let error = error {
                print("Error stopping capture: \(error)")
            }
        }
        
        iosComponents.pipWindow?.isHidden = true
        iosComponents.pipWindow = nil
        iosComponents.hostingController = nil
        
        player?.pause()
        player = nil
        playerLayer = nil
        pictureInPictureController = nil
        #endif
    }
}

// MARK: - AVPictureInPictureControllerDelegate

#if !os(macOS)
extension StreamingPictureInPictureManager: @preconcurrency AVPictureInPictureControllerDelegate {
    public func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        isStreamingPiPActive = true
    }
    
    public func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        isStreamingPiPActive = false
        cleanupPiP()
    }
    
    public func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        print("Streaming PiP failed: \(error)")
        isStreamingPiPActive = false
    }
}
#endif