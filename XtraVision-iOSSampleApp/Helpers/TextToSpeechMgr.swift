//
//  TextToSpeechMgr.swift
//  XtraVision-iOSSampleApp
//
//  Created by XTRA on 13/06/23.
//

import Foundation
import AVKit

class TextToSpeechManager : NSObject, AVSpeechSynthesizerDelegate {
    static let sharedInstance = TextToSpeechManager()
    
    let avSpeechSynthesizer = AVSpeechSynthesizer()
    private var textToSpeech = ""
    
    private override init() {
        
    }
    
    func resetText() {
        textToSpeech = ""
    }
    
    func startSpeaking(_ text : String) {
        if textToSpeech != text {
            textToSpeech = text
            
            let utterance = AVSpeechUtterance(string: text)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            utterance.volume = 1
            utterance.rate = 0.5
            if !avSpeechSynthesizer.isSpeaking {
                avSpeechSynthesizer.speak(utterance)
            }
        }
    }
    
    func stopSpeaking() {
        textToSpeech = ""
        if avSpeechSynthesizer.isSpeaking {
            avSpeechSynthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        }
    }
    
    func pauseSpeaking() {
        textToSpeech = ""
        if avSpeechSynthesizer.isSpeaking {
            avSpeechSynthesizer.pauseSpeaking(at: .immediate)
        }
    }
}

