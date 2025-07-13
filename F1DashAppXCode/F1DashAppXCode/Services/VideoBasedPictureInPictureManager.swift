//
//  VideoBasedPictureInPictureManager.swift
//  F1-Dash
//
//  Simplified video-based PiP implementation using AVSampleBufferDisplayLayer
//

import SwiftUI
import AVKit
import AVFoundation
import CoreMedia
import CoreGraphics

@MainActor
@Observable
public final class VideoBasedPictureInPictureManager: NSObject {
    // MARK: - Properties
    
    private var playerLayer: AVPlayerLayer?
    private var player: AVQueuePlayer?
    private var playerLooper: AVPlayerLooper?
    private var pictureInPictureController: AVPictureInPictureController?
    
    // Rendering
    private var displayLink: CADisplayLink?
    private var renderer: ImageRenderer<AnyView>?
    
    // weak var appEnvironment: AppEnvironment?
    weak var appEnvironment: OptimizedAppEnvironment?
    
    // Track if PiP is active
    private(set) var isVideoPiPActive = false
    
    // Video properties
    private let videoSize = CGSize(width: 480, height: 360)
    private let frameRate: Double = 30.0
    
    // Temporary video file
    private var videoURL: URL?
    
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
    
    func startVideoPiP() async {
        #if !os(macOS)
        guard AVPictureInPictureController.isPictureInPictureSupported() else {
            print("PiP not supported on this device")
            return
        }
        
        guard appEnvironment != nil else {
            print("AppEnvironment not set")
            return
        }
        
        // Create a video file with the track map
        await createTrackMapVideo()
        
        // Setup player and PiP
        setupVideoPlayer()
        #endif
    }
    
    func stopVideoPiP() {
        #if !os(macOS)
        pictureInPictureController?.stopPictureInPicture()
        cleanupVideoPlayer()
        #endif
    }
    
    // MARK: - Video Creation
    
    private func createTrackMapVideo() async {
        #if !os(macOS)
        // Create a temporary video file
        let tempDir = FileManager.default.temporaryDirectory
        let videoPath = tempDir.appendingPathComponent("trackmap_\(Date().timeIntervalSince1970).mp4")
        
        // Create video writer
        guard let videoWriter = try? AVAssetWriter(outputURL: videoPath, fileType: .mp4) else {
            print("Failed to create video writer")
            return
        }
        
        // Configure video settings
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: Int(videoSize.width),
            AVVideoHeightKey: Int(videoSize.height),
            AVVideoCompressionPropertiesKey: [
                AVVideoAverageBitRateKey: 2_000_000,
                AVVideoProfileLevelKey: AVVideoProfileLevelH264High41,
                AVVideoMaxKeyFrameIntervalKey: 60
            ]
        ]
        
        let videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        videoInput.expectsMediaDataInRealTime = false
        
        let pixelBufferAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferWidthKey as String: Int(videoSize.width),
            kCVPixelBufferHeightKey as String: Int(videoSize.height)
        ]
        
        let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: videoInput,
            sourcePixelBufferAttributes: pixelBufferAttributes
        )
        
        videoWriter.add(videoInput)
        
        // Start writing
        videoWriter.startWriting()
        videoWriter.startSession(atSourceTime: .zero)
        
        // Create a simple animated video (10 seconds)
        let duration = 10.0
        let totalFrames = Int(duration * frameRate)
        
        // Setup renderer
        guard let appEnvironment = appEnvironment else { return }
        // let trackMapView = TrackMapPiPContentTrackMapPiPContent(appEnvironment: appEnvironment)
        let trackMapView = OptimizedTrackMapPiPContent(appEnvironment: appEnvironment)
            .frame(width: videoSize.width, height: videoSize.height)
            .background(Color.black)
        
        let renderer = ImageRenderer(content: AnyView(trackMapView))
        renderer.scale = 2.0
        
        // Render frames
        for frameIndex in 0..<totalFrames {
            let presentationTime = CMTime(value: Int64(frameIndex), timescale: Int32(frameRate))
            
            // Wait for buffer to be ready
            while !videoInput.isReadyForMoreMediaData {
                await Task.yield()
            }
            
            // Create pixel buffer
            if let pixelBuffer = self.createPixelBuffer(from: renderer, at: frameIndex, totalFrames: totalFrames) {
                pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTime)
            }
        }
        
        // Finish writing
        videoInput.markAsFinished()
        await videoWriter.finishWriting()
        
        self.videoURL = videoPath
        print("Video created at: \(videoPath)")
        #endif
    }
    
    private func createPixelBuffer(from renderer: ImageRenderer<AnyView>, at frameIndex: Int, totalFrames: Int) -> CVPixelBuffer? {
        #if !os(macOS)
        // Create pixel buffer
        var pixelBuffer: CVPixelBuffer?
        let bufferAttributes: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
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
        
        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }
        
        let pixelData = CVPixelBufferGetBaseAddress(buffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        
        guard let context = CGContext(
            data: pixelData,
            width: Int(videoSize.width),
            height: Int(videoSize.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: rgbColorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        ) else { return nil }
        
        // Clear background
        context.setFillColor(UIColor.black.cgColor)
        context.fill(CGRect(origin: .zero, size: videoSize))
        
        // Render the SwiftUI view
        if let cgImage = renderer.cgImage {
            context.draw(cgImage, in: CGRect(origin: .zero, size: videoSize))
        }
        
        // Add frame counter for testing
        let progress = Double(frameIndex) / Double(totalFrames)
        context.setFillColor(UIColor.white.cgColor)
        context.setFont(CGFont("Helvetica" as CFString)!)
        context.setFontSize(12)
        
        _ = "Frame: \(frameIndex) Progress: \(Int(progress * 100))%"
        context.textPosition = CGPoint(x: 10, y: videoSize.height - 20)
        // Note: Drawing text in CGContext is complex, skipping for now
        
        return buffer
        #else
        return nil
        #endif
    }
    
    // MARK: - Video Player Setup
    
    private func setupVideoPlayer() {
        #if !os(macOS)
        guard let videoURL = videoURL else {
            print("No video URL available")
            return
        }
        
        // Create player item
        let playerItem = AVPlayerItem(url: videoURL)
        
        // Create queue player for looping
        let player = AVQueuePlayer(playerItem: playerItem)
        player.isMuted = true
        player.allowsExternalPlayback = false
        
        // Create looper
        self.playerLooper = AVPlayerLooper(player: player, templateItem: playerItem)
        self.player = player
        
        // Create player layer
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = CGRect(origin: .zero, size: videoSize)
        playerLayer.videoGravity = .resizeAspect
        self.playerLayer = playerLayer
        
        // Setup PiP controller
        pictureInPictureController = AVPictureInPictureController(playerLayer: playerLayer)
        pictureInPictureController?.delegate = self
        
        // Configure PiP
        #if !os(macOS)
        pictureInPictureController?.canStartPictureInPictureAutomaticallyFromInline = false
        #endif
        
        // Start playback
        player.play()
        
        // Start PiP after a short delay to ensure player is ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.pictureInPictureController?.startPictureInPicture()
        }
        #endif
    }
    
    private func cleanupVideoPlayer() {
        #if !os(macOS)
        player?.pause()
        player = nil
        playerLayer = nil
        playerLooper = nil
        pictureInPictureController = nil
        
        // Clean up video file
        if let videoURL = videoURL {
            try? FileManager.default.removeItem(at: videoURL)
            self.videoURL = nil
        }
        #endif
    }
}

// MARK: - AVPictureInPictureControllerDelegate

#if !os(macOS)
extension VideoBasedPictureInPictureManager: @preconcurrency AVPictureInPictureControllerDelegate {
    public func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("Video PiP will start")
        isVideoPiPActive = true
    }
    
    public func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("Video PiP did start")
    }
    
    public func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("Video PiP will stop")
    }
    
    public func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("Video PiP did stop")
        isVideoPiPActive = false
        cleanupVideoPlayer()
    }
    
    public func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        print("Video PiP failed to start: \(error)")
        isVideoPiPActive = false
    }
}
#endif
