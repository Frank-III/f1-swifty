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
    
    private var sampleBufferDisplayLayer: AVSampleBufferDisplayLayer?
    private var pictureInPictureController: AVPictureInPictureController?
    
    // Real-time rendering
    private var displayLink: CADisplayLink?
    private var renderer: ImageRenderer<AnyView>?
    private var pixelBufferPool: CVPixelBufferPool?
    
    // weak var appEnvironment: AppEnvironment?
    weak var appEnvironment: OptimizedAppEnvironment?
    
    // Track if PiP is active
    private(set) var isVideoPiPActive = false
    
    // Track rendering state
    private var isRendering = false
    
    // Video properties
    private let videoSize = CGSize(width: 480, height: 360)
    private let frameRate: Double = 15.0 // Lower frame rate for better performance
    private var frameCounter: Int64 = 0
    
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
        
        guard let appEnvironment = appEnvironment else {
            print("AppEnvironment not set")
            return
        }
        
        // Check if already active
        if isVideoPiPActive || isRendering {
            print("Video PiP already active or rendering")
            return
        }
        
        // Setup real-time video rendering
        setupSampleBufferDisplayLayer()
        setupRenderer(appEnvironment: appEnvironment)
        startRealTimeRendering()
        #endif
    }
    
    func stopVideoPiP() {
        #if !os(macOS)
        isRendering = false
        pictureInPictureController?.stopPictureInPicture()
        cleanupRealTimeRendering()
        #endif
    }
    
    // MARK: - Real-time Setup
    
    private func setupSampleBufferDisplayLayer() {
        #if !os(macOS)
        sampleBufferDisplayLayer = AVSampleBufferDisplayLayer()
        sampleBufferDisplayLayer?.frame = CGRect(origin: .zero, size: videoSize)
        sampleBufferDisplayLayer?.videoGravity = .resizeAspect
        
        // Setup pixel buffer pool
        let pixelBufferAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferWidthKey as String: Int(videoSize.width),
            kCVPixelBufferHeightKey as String: Int(videoSize.height),
            kCVPixelBufferIOSurfacePropertiesKey as String: [:]
        ]
        
        CVPixelBufferPoolCreate(
            kCFAllocatorDefault,
            nil,
            pixelBufferAttributes as CFDictionary,
            &pixelBufferPool
        )
        
        // Setup PiP controller
        if let layer = sampleBufferDisplayLayer {
            pictureInPictureController = AVPictureInPictureController(contentSource: .init(sampleBufferDisplayLayer: layer, playbackDelegate: self))
            pictureInPictureController?.delegate = self
        }
        #endif
    }
    
    private func setupRenderer(appEnvironment: OptimizedAppEnvironment) {
        let trackMapView = OptimizedTrackMapPiPContent(appEnvironment: appEnvironment)
            .frame(width: videoSize.width, height: videoSize.height)
            .background(Color.black)
        
        renderer = ImageRenderer(content: AnyView(trackMapView))
        renderer?.scale = 1.0
    }
    
    private func startRealTimeRendering() {
        #if !os(macOS)
        isRendering = true
        displayLink = CADisplayLink(target: self, selector: #selector(renderFrame))
        displayLink?.preferredFramesPerSecond = Int(frameRate)
        displayLink?.add(to: .main, forMode: .common)
        
        // Start PiP after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self, self.isRendering else { return }
            self.pictureInPictureController?.startPictureInPicture()
        }
        #endif
    }
    
    @objc private func renderFrame() {
        #if !os(macOS)
        guard isRendering,
              let sampleBufferDisplayLayer = sampleBufferDisplayLayer,
              let pixelBufferPool = pixelBufferPool,
              let renderer = renderer,
              appEnvironment != nil else { return }
        
        // Create pixel buffer
        var pixelBuffer: CVPixelBuffer?
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pixelBufferPool, &pixelBuffer)
        
        guard let buffer = pixelBuffer else { return }
        
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
        ) else { return }
        
        // Clear background
        context.setFillColor(UIColor.black.cgColor)
        context.fill(CGRect(origin: .zero, size: videoSize))
        
        // Render the SwiftUI view with error handling
        do {
            if let cgImage = renderer.cgImage {
                context.draw(cgImage, in: CGRect(origin: .zero, size: videoSize))
            }
        } catch {
            print("Failed to render image: \(error)")
            return
        }
        
        // Create sample buffer
        let presentationTime = CMTime(value: frameCounter, timescale: Int32(frameRate))
        frameCounter += 1
        
        var sampleBuffer: CMSampleBuffer?
        var timingInfo = CMSampleTimingInfo()
        timingInfo.duration = CMTime(value: 1, timescale: Int32(frameRate))
        timingInfo.presentationTimeStamp = presentationTime
        timingInfo.decodeTimeStamp = .invalid
        
        var formatDescription: CMVideoFormatDescription?
        CMVideoFormatDescriptionCreateForImageBuffer(
            allocator: kCFAllocatorDefault,
            imageBuffer: buffer,
            formatDescriptionOut: &formatDescription
        )
        
        guard let format = formatDescription else { return }
        
        CMSampleBufferCreateReadyWithImageBuffer(
            allocator: kCFAllocatorDefault,
            imageBuffer: buffer,
            formatDescription: format,
            sampleTiming: &timingInfo,
            sampleBufferOut: &sampleBuffer
        )
        
        if let sample = sampleBuffer {
            sampleBufferDisplayLayer.enqueue(sample)
        }
        #endif
    }
    
    private func cleanupRealTimeRendering() {
        #if !os(macOS)
        isRendering = false
        
        displayLink?.invalidate()
        displayLink = nil
        
        sampleBufferDisplayLayer?.flushAndRemoveImage()
        sampleBufferDisplayLayer = nil
        pictureInPictureController = nil
        
        renderer = nil
        pixelBufferPool = nil
        frameCounter = 0
        #endif
    }
    
    // MARK: - Force Cleanup
    
    func forceCleanup() {
        // Stop PiP if active
//        #if !os(macOS)
//        if isVideoPiPActive {
//              stopPictureInPicture()
//          }
//        #endif
        
        // Always cleanup resources
        cleanupRealTimeRendering()
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
        cleanupRealTimeRendering()
    }
    
    public func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        print("Video PiP failed to start: \(error)")
        isVideoPiPActive = false
        cleanupRealTimeRendering()
    }
}

// MARK: - AVPictureInPictureSampleBufferPlaybackDelegate

extension VideoBasedPictureInPictureManager: @preconcurrency AVPictureInPictureSampleBufferPlaybackDelegate {
    public func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, setPlaying playing: Bool) {
        // Handle play/pause state
        if playing {
            displayLink?.isPaused = false
        } else {
            displayLink?.isPaused = true
        }
    }
    
    public func pictureInPictureControllerTimeRangeForPlayback(_ pictureInPictureController: AVPictureInPictureController) -> CMTimeRange {
        // Return a continuous time range
        return CMTimeRange(start: .zero, duration: .positiveInfinity)
    }
    
    public func pictureInPictureControllerIsPlaybackPaused(_ pictureInPictureController: AVPictureInPictureController) -> Bool {
        return displayLink?.isPaused ?? false
    }
    
    public func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, didTransitionToRenderSize newRenderSize: CMVideoDimensions) {
        // Handle render size changes if needed
    }
    
    public func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, skipByInterval skipInterval: CMTime, completion completionHandler: @escaping () -> Void) {
        // Skip functionality not needed for live data
        completionHandler()
    }
}
#endif
