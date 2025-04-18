//
//  SoundManager.swift
//  WorkoutApp
//
//  Created by Leon Grimmeisen on 19.12.23.
//

import Foundation
import AVKit
import AVFoundation

class SoundManager {

    static let instance = SoundManager()
    
    var player: AVAudioPlayer?
    let synthesizer = AVSpeechSynthesizer()
    
    enum SoundOption: String {
        case dadam, countdown, jubilant
    }
    
    func playSound(sound: SoundOption) {
        guard UserDefaults.standard.bool(forKey: "hasSoundsEnabled") else {
            print("Sounds are disabled.")
            return
        }
        
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, options: AVAudioSession.CategoryOptions.mixWithOthers)
        } catch(let error) {
            print(error.localizedDescription)
        }
                
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            print("Error playing sound... \(error.localizedDescription)")
        }
    }
    
    func pauseSound() {
        player?.pause()
    }
    
    func stopSound() {
        player?.stop()
        player?.currentTime = 0
    }
    
    func resumeSound() {
        player?.play()
    }
    
    func speakText(text: String) {
        guard UserDefaults.standard.bool(forKey: "announceActivitiesEnabled") else {
            print("Announce Activities disabled.")
            return
        }
        guard UserDefaults.standard.bool(forKey: "hasSoundsEnabled") else {
            print("Sounds are disabled.")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category: \(error.localizedDescription)")
        }
        
        let utterance = AVSpeechUtterance(string: text)
        let language: Language = Language(rawValue: UserDefaults.standard.string(forKey: "AppLanguage") ?? "EN") ?? .englishUS
        utterance.voice = AVSpeechSynthesisVoice(language: language.locale.identifier)
        utterance.rate = 0.5
        
        synthesizer.speak(utterance)
    }
}
