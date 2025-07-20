//
//  SoundManager.swift
//  F1-Dash
//
//  Manages sound playback for notifications and alerts
//

import Foundation
#if os(iOS)
import AVFoundation
#elseif os(macOS)
import AppKit
#endif

@MainActor
final class SoundManager {
    // MARK: - Properties
    
    #if os(iOS)
    private var audioPlayer: AVAudioPlayer?
    #endif
    
    // MARK: - Sound Types
    
    enum SoundType: String {
        case raceControlChime = "race_control_chime"
        case notification = "notification"
        
        var systemSoundName: String {
            switch self {
            case .raceControlChime:
                #if os(iOS)
                return "Glass" // iOS system sound
                #else
                return "Glass" // macOS system sound
                #endif
            case .notification:
                #if os(iOS)
                return "Morse" // iOS system sound
                #else
                return "Morse" // macOS system sound
                #endif
            }
        }
    }
    
    // MARK: - Public Methods
    
    func playSound(_ type: SoundType) {
        #if os(iOS)
        playIOSSound(type)
        #elseif os(macOS)
        playMacOSSound(type)
        #endif
    }
    
    // MARK: - Platform-specific implementations
    
    #if os(iOS)
    private func playIOSSound(_ type: SoundType) {
        // Try to play system sound
        if let soundURL = getSystemSoundURL(for: type.systemSoundName) {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.play()
            } catch {
                // Fallback to simple system sound
                playFallbackSound()
            }
        } else {
            playFallbackSound()
        }
    }
    
    private func playFallbackSound() {
        // Play a simple system sound as fallback
        // Using AudioServicesPlaySystemSound for simple feedback
        AudioServicesPlaySystemSound(1104) // Key press sound
    }
    
    private func getSystemSoundURL(for name: String) -> URL? {
        // Try to find system sound
        let systemSoundPath = "/System/Library/Audio/UISounds/\(name).caf"
        let url = URL(fileURLWithPath: systemSoundPath)
        if FileManager.default.fileExists(atPath: systemSoundPath) {
            return url
        }
        return nil
    }
    #endif
    
    #if os(macOS)
    private func playMacOSSound(_ type: SoundType) {
        // Play system sound on macOS
        if let sound = NSSound(named: NSSound.Name(type.systemSoundName)) {
            sound.play()
        } else {
            // Fallback to beep
            NSSound.beep()
        }
    }
    #endif
}