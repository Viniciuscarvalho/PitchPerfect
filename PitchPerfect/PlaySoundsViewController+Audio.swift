//
//  PlaySoundsViewController+Audio.swift
//  PitchPerfect
//
//  Created by Vinicius Carvalho on 09/07/16.
//  Copyright © 2016 Vinicius Carvalho. All rights reserved.
//

import UIKit
import AVFoundation

extension PlaySoundsViewController: AVAudioPlayerDelegate {

    struct Alerts {
        static let DismissAlert = "Dismiss"
        static let RecordingDisabledTitle = "Recording Disabled"
        static let RecordingDisabledMessage = "You've disabled this app from recording your microphone. Check Settings."
        static let RecordingFailedTitle = "Recording Failed"
        static let RecordingFailedMessage = "Something went wrong with your recording."
        static let AudioRecorderError = "Audio Recorder Error"
        static let AudioSessionError = "Audio Session Error"
        static let AudioFileError = "Audio File Error"
        static let AudioEngineError = "Audio Engine Error"
    }
    
    // raw values correspond to sender tags
    enum PlayingState { case Playing, NotPlaying }
    
    // MARK: Audio Functions
    
    func setupAudio() {
        do {
            audioFile = try AVAudioFile (forReading: recordedAudioURL)
        } catch {
            showAlert(Alerts.AudioFileError, message: String(error))
        }
        print("Audio has been setup")
    }
    
    func playSound(rate rate: Float? = nil, pitch: Float? = nil, echo: Bool = false, reverb: Bool = false) {
        //Initialize audio engine components
        audioEngine = AVAudioEngine()
        
        //Node for playing audio
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        
        let changeRatePitchNode = AVAudioUnitTimePitch()
        if let pitch = pitch {
            changeRatePitchNode.pitch = pitch
        }
        if let rate = rate {
            changeRatePitchNode.rate = rate
        }
        audioEngine.attachNode(changeRatePitchNode)
        
        // node for echo
        let echoNode = AVAudioUnitDistortion()
        echoNode.loadFactoryPreset(.MultiEcho1)
        audioEngine.attachNode(echoNode)
        
        // node for reverb
        let reverbNode = AVAudioUnitReverb()
        reverbNode.loadFactoryPreset(.Cathedral)
        reverbNode.wetDryMix = 50
        audioEngine.attachNode(reverbNode)
        
        // Connect nodes
        if echo == true && reverb == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, reverbNode, audioEngine.outputNode)
        } else if echo == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, audioEngine.outputNode)
        } else if reverb == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, reverbNode, audioEngine.outputNode)
        } else {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, audioEngine.outputNode)
        }
        
        //schedule to play and start the engine
        audioPlayerNode.stop()
        audioPlayerNode.scheduleFile(audioFile, atTime: nil) {
            var delayInSeconds: Double = 0
            
            if let lastRenderTime = self.audioPlayerNode.lastRenderTime, let playerTime = self.audioPlayerNode.playerTimeForNodeTime(lastRenderTime) {
                
                if let rate = rate {
                    delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate) / Double(rate)
                } else {
                    delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate)
                }
            }
            
            self.stopTimer = NSTimer(timeInterval: delayInSeconds, target: self, selector: "stopAudio", userInfo: nil, repeats: false)
            NSRunLoop.mainRunLoop().addTimer(self.stopTimer!, forMode: NSDefaultRunLoopMode)
            
        }
        
        do {
            try audioEngine.start()
        } catch {
            showAlert(Alerts.AudioEngineError, message: String(error))
            return
        }
        
        // play the recording
        audioPlayerNode.play()
        
    }
    
    // MARK: Connect List of Audio Nodes
    func connectAudioNodes(nodes: AVAudioNode...) {
    
        for x in 0..<nodes.count-1 {
            audioEngine.connect(nodes[x], to: nodes[x+1], format: audioFile.processingFormat)
        }
    }
    
    func stopAudio() {
        if let stopTimer = stopTimer {
            stopTimer.invalidate()
        }
        
        configureUI(.NotPlaying)
        
        if let audioPlayerNode = audioPlayerNode {
            audioPlayerNode.stop()
        }
        
        if let audioEngine = audioEngine {
            audioEngine.stop()
            audioEngine.reset()
        }
    }
    
    // MARK: UI Functions
    func configureUI(playState: PlayingState) {
        snailBtn.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        chipmunkBtn.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        rabbitBtn.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        vaderBtn.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        echoBtn.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        revertBtn.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        stopBtn.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        
        switch (playState) {
        case .Playing:
            setPlayButtonsEnabled(false)
            stopBtn.enabled = true
        case .NotPlaying:
            setPlayButtonsEnabled(true)
            stopBtn.enabled = false
        }
    }
    
    func setPlayButtonsEnabled(enabled: Bool) {
        snailBtn.enabled = enabled
        chipmunkBtn.enabled = enabled
        rabbitBtn.enabled = enabled
        vaderBtn.enabled = enabled
        echoBtn.enabled = enabled
        revertBtn.enabled = enabled
        
    }
        
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: Alerts.DismissAlert, style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
        
    
}
