//
//  TTSManager.swift
//  QuickNovel
//
//  Text-to-Speech manager using AVSpeechSynthesizer
//

import Foundation
import AVFoundation

class TTSManager: NSObject, ObservableObject {
    @Published var isPlaying = false
    @Published var currentRate: Float = 0.5
    @Published var currentPitch: Float = 1.0
    
    private let synthesizer = AVSpeechSynthesizer()
    private var currentText: String = ""
    
    override init() {
        super.init()
        synthesizer.delegate = self
        configureAudioSession()
    }
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
    
    func speak(text: String) {
        guard !text.isEmpty else { return }
        
        currentText = text
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = currentRate
        utterance.pitchMultiplier = currentPitch
        utterance.volume = 1.0
        
        // Use default voice for the current language
        if let voice = AVSpeechSynthesisVoice(language: "en-US") {
            utterance.voice = voice
        }
        
        synthesizer.speak(utterance)
        isPlaying = true
    }
    
    func pause() {
        synthesizer.pauseSpeaking(at: .word)
        isPlaying = false
    }
    
    func resume() {
        synthesizer.continueSpeaking()
        isPlaying = true
    }
    
    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        isPlaying = false
    }
    
    func toggleTTS() {
        if isPlaying {
            pause()
        } else if synthesizer.isPaused {
            resume()
        }
    }
    
    func setRate(_ rate: Float) {
        currentRate = rate
    }
    
    func setPitch(_ pitch: Float) {
        currentPitch = pitch
    }
}

// MARK: - AVSpeechSynthesizerDelegate
extension TTSManager: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        isPlaying = false
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        isPlaying = false
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        isPlaying = true
    }
}
