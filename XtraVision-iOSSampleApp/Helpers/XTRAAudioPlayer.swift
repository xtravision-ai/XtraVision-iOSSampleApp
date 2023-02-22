//
//  XTRAAudioPlayer.swift
//  Xtra-PaaS
//
//  Created by XTRA on 18/04/22.
//

import Foundation
import AVFoundation

class AudioManager : NSObject, AVAudioPlayerDelegate {
    static let sharedInstance = AudioManager()
    
    var musicPlayer: AVAudioPlayer?
    private var currentFileName = ""
    
    private override init() {
        
    }
    
    func resetFileName() {
        currentFileName = ""
    }
    
    func startMusic(_ fileName : String, soundType : String) {
        do {
            // Music BG
            if currentFileName != fileName {
                currentFileName = fileName
                if let resourcePath = Bundle.main.path(forResource: fileName, ofType: soundType) {
                    let url = URL(fileURLWithPath: resourcePath)
                    try musicPlayer = AVAudioPlayer(contentsOf: url)
                    if let player = musicPlayer, !(player.isPlaying) {
                        musicPlayer?.volume = 1.0
                        musicPlayer?.play()
                    }
                }
            }
            
        } catch let err as NSError {
            print(err.debugDescription)
        }
    }
    
    func playChatNotification(_ fileName : String, soundType : String) {
        do {
            // Music BG
//            Take a few steps back until you see your full body in the screen
            if let resourcePath = Bundle.main.path(forResource: fileName, ofType: soundType) {
                let url = URL(fileURLWithPath: resourcePath)
                try musicPlayer = AVAudioPlayer(contentsOf: url)
                if let player = musicPlayer, !(player.isPlaying) {
                    musicPlayer?.volume = 1.0
                    musicPlayer?.play()
                }
            }
            
        } catch let err as NSError {
            print(err.debugDescription)
        }
    }
    
    func stopMusic() { // implementation
        musicPlayer?.stop()
        musicPlayer = nil
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopMusic()
    }
}
