//
//  SystemPictureInPictureManager.swift
//  F1-Dash
//
//  Manages system Picture-in-Picture using AVKit with live SwiftUI rendering
//

import SwiftUI
import AVKit
import AVFoundation
import Combine
import CoreImage
import CoreMedia

#if !os(macOS)
// iOS-only container for platform-specific properties
private class iOSVideoComponents {
    var videoOutput: TrackMapVideoOutput?
}
#endif

@MainActor
@Observable
public final class SystemPictureInPictureManager: NSObject {
    // MARK: - Properties
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var pictureInPictureController: AVPictureInPictureController?
    private var displayLink: CADisplayLink?
    
    // weak var appEnvironment: AppEnvironment?
    weak var appEnvironment: OptimizedAppEnvironment?
    
    // Track if PiP is active
    private(set) var isSystemPiPActive = false
    
    // Video dimensions
    private let videoSize = CGSize(width: 480, height: 360)
    
    #if !os(macOS)
    // iOS-only components container
    private let iosComponents = iOSVideoComponents()
    #endif
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    // MARK: - Setup
    
    private func setupAudioSession() {
        #if !os(macOS)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
        #endif
    }
    
    // MARK: - Public Methods
    
    func startSystemPiP() {
        #if !os(macOS)
        guard AVPictureInPictureController.isPictureInPictureSupported() else {
            print("PiP not supported on this device")
            return
        }
        
        guard let appEnvironment = appEnvironment else {
            print("AppEnvironment not set")
            return
        }
        
        // Create custom video output
        iosComponents.videoOutput = TrackMapVideoOutput(appEnvironment: appEnvironment, videoSize: videoSize)
        
        // Create player with custom video
        setupVideoPlayer()
        
        // Setup PiP controller
        if let playerLayer = playerLayer {
            pictureInPictureController = AVPictureInPictureController(playerLayer: playerLayer)
            pictureInPictureController?.delegate = self
            
            // Configure PiP
            #if !os(macOS)
            pictureInPictureController?.canStartPictureInPictureAutomaticallyFromInline = true
            pictureInPictureController?.requiresLinearPlayback = false
            #endif
            
            // Start PiP
            pictureInPictureController?.startPictureInPicture()
        }
        #endif
    }
    
    func stopSystemPiP() {
        #if !os(macOS)
        pictureInPictureController?.stopPictureInPicture()
        cleanupVideoPlayer()
        #endif
    }
    
    // MARK: - Private Methods
    
    private func setupVideoPlayer() {
        #if !os(macOS)
        guard let videoOutput = iosComponents.videoOutput else { return }
        
        // Create player item with our custom video output
        let playerItem = videoOutput.createPlayerItem()
        
        // Create player
        let player = AVPlayer(playerItem: playerItem)
        player.isMuted = true
        player.allowsExternalPlayback = false
        self.player = player
        
        // Create player layer
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = CGRect(origin: .zero, size: videoSize)
        playerLayer.videoGravity = .resizeAspect
        self.playerLayer = playerLayer
        
        // Start playback
        player.play()
        
        // Start rendering
        videoOutput.startRendering()
        #endif
    }
    
    private func cleanupVideoPlayer() {
        #if !os(macOS)
        iosComponents.videoOutput?.stopRendering()
        player?.pause()
        player = nil
        playerLayer = nil
        pictureInPictureController = nil
        iosComponents.videoOutput = nil
        #endif
    }
}

// MARK: - AVPictureInPictureControllerDelegate

#if !os(macOS)
extension SystemPictureInPictureManager: @preconcurrency AVPictureInPictureControllerDelegate {
    public func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("PiP will start")
        isSystemPiPActive = true
    }
    
    public func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("PiP did start")
    }
    
    public func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("PiP will stop")
    }
    
    public func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("PiP did stop")
        isSystemPiPActive = false
        cleanupVideoPlayer()
    }
    
    public func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        print("PiP failed to start: \(error)")
        isSystemPiPActive = false
    }
}
#endif

// MARK: - Custom Video Output

#if !os(macOS)
@MainActor
class TrackMapVideoOutput: NSObject {
    // private let appEnvironment: AppEnvironment
    private let appEnvironment: OptimizedAppEnvironment
    private let videoSize: CGSize
    private var displayLink: CADisplayLink?
    private var sampleBufferDisplayLayer: AVSampleBufferDisplayLayer?
    private var renderer: ImageRenderer<AnyView>?
    private var isRendering = false
    
    // Timing
    private var frameCount: Int64 = 0
    private let frameRate: Double = 30.0
    
    // init(appEnvironment: AppEnvironment, videoSize: CGSize) {
    init(appEnvironment: OptimizedAppEnvironment, videoSize: CGSize) {
        self.appEnvironment = appEnvironment
        self.videoSize = videoSize
        super.init()
        setupRenderer()
    }
    
    private func setupRenderer() {
        // Create the track map view for rendering
        // let trackMapView = TrackMapPiPContent(appEnvironment: appEnvironment)
        let trackMapView = OptimizedTrackMapPiPContent(appEnvironment: appEnvironment)
            .frame(width: videoSize.width, height: videoSize.height)
            .background(Color.black)
        
        // Create renderer
        renderer = ImageRenderer(content: AnyView(trackMapView))
        renderer?.scale = UIScreen.main.scale
    }
    
    func createPlayerItem() -> AVPlayerItem {
        // Create a custom composition that will trigger our rendering
        let asset = createVideoAsset()
        let playerItem = AVPlayerItem(asset: asset)
        
        // Create video composition with custom rendering
        let videoComposition = createVideoComposition(for: asset)
        playerItem.videoComposition = videoComposition
        
        return playerItem
    }
    
    private func createVideoAsset() -> AVAsset {
        // Create a dummy video asset that will be replaced by our live rendering
        // We'll use a blank video composition
        let composition = AVMutableComposition()
        
        // Add a video track
        guard let videoTrack = composition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ) else {
            return composition
        }
        
        // Create a blank video segment (we'll render over this)
        let duration = CMTime(seconds: 3600, preferredTimescale: 600) // 1 hour
        _ = CMTimeRange(start: .zero, duration: duration)
        
        // Set up the track
        videoTrack.preferredTransform = .identity
        
        return composition
    }
    
    private func createVideoComposition(for asset: AVAsset) -> AVVideoComposition {
        let videoComposition = AVMutableVideoComposition()
        videoComposition.frameDuration = CMTime(value: 1, timescale: Int32(frameRate))
        videoComposition.renderSize = videoSize
        
        // Create custom compositor
        let compositor = TrackMapCompositor(videoOutput: self)
        videoComposition.customVideoCompositorClass = type(of: compositor)
        
        // Create instruction
        let instruction = TrackMapCompositionInstruction(
            timeRange: CMTimeRange(start: .zero, duration: CMTime(seconds: 3600, preferredTimescale: 600)),
            videoOutput: self
        )
        
        videoComposition.instructions = [instruction]
        
        return videoComposition
    }
    
    func startRendering() {
        isRendering = true
        
        // Create display link for frame updates
        displayLink = CADisplayLink(target: self, selector: #selector(updateFrame))
        displayLink?.preferredFrameRateRange = CAFrameRateRange(minimum: 30, maximum: 30, preferred: 30)
        displayLink?.add(to: .main, forMode: .default)
    }
    
    func stopRendering() {
        isRendering = false
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func updateFrame() {
        // This will trigger recomposition
        frameCount += 1
    }
    
    func renderFrame(at time: CMTime) -> CVPixelBuffer? {
        guard isRendering, let renderer = renderer else { return nil }
        
        // Create pixel buffer
        var pixelBuffer: CVPixelBuffer?
        let bufferAttributes: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true,
            kCVPixelBufferMetalCompatibilityKey as String: true
        ]
        
        CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(videoSize.width),
            Int(videoSize.height),
            kCVPixelFormatType_32BGRA,
            bufferAttributes as CFDictionary,
            &pixelBuffer
        )
        
        guard let buffer = pixelBuffer else { return nil }
        
        // Render SwiftUI view to pixel buffer
        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }
        
        let context = CIContext()
        
        // Render the SwiftUI view
        #if !os(macOS)
        if let cgImage = renderer.cgImage {
            // Convert to CIImage
            let ciImage = CIImage(cgImage: cgImage)
            // Render to pixel buffer
            context.render(ciImage, to: buffer)
        }
        #endif
        
        return buffer
    }
}

// Custom Video Compositor
class TrackMapCompositor: NSObject, AVVideoCompositing {
    private weak var videoOutput: TrackMapVideoOutput?
    
    init(videoOutput: TrackMapVideoOutput) {
        self.videoOutput = videoOutput
        super.init()
    }
    
    var sourcePixelBufferAttributes: [String : Any]? {
        return [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
    }
    
    var requiredPixelBufferAttributesForRenderContext: [String : Any] {
        return [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
    }
    
    func renderContextChanged(_ newRenderContext: AVVideoCompositionRenderContext) {
        // Handle context changes if needed
    }
    
    func startRequest(_ request: AVAsynchronousVideoCompositionRequest) {
        Task { @MainActor in
            // Render the current frame
            if let pixelBuffer = videoOutput?.renderFrame(at: request.compositionTime) {
                request.finish(withComposedVideoFrame: pixelBuffer)
            } else {
                request.finish(with: NSError(domain: "TrackMapCompositor", code: -1, userInfo: nil))
            }
        }
    }
}

// Custom Composition Instruction
class TrackMapCompositionInstruction: NSObject, AVVideoCompositionInstructionProtocol {
    var timeRange: CMTimeRange
    var enablePostProcessing = false
    var containsTweening = false
    var requiredSourceTrackIDs: [NSValue]? = nil
    var passthroughTrackID: CMPersistentTrackID = kCMPersistentTrackID_Invalid
    
    private weak var videoOutput: TrackMapVideoOutput?
    
    init(timeRange: CMTimeRange, videoOutput: TrackMapVideoOutput) {
        self.timeRange = timeRange
        self.videoOutput = videoOutput
        super.init()
    }
}
#endif