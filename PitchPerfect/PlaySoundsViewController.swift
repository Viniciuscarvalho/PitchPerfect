//
//  PlaySoundsViewController.swift
//  PitchPerfect
//
//  Created by Vinicius Carvalho on 08/07/16.
//  Copyright © 2016 Vinicius Carvalho. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {

    @IBOutlet weak var snailBtn: UIButton!
    @IBOutlet weak var chipmunkBtn: UIButton!
    @IBOutlet weak var rabbitBtn: UIButton!
    @IBOutlet weak var vaderBtn: UIButton!
    @IBOutlet weak var echoBtn: UIButton!
    @IBOutlet weak var revertBtn: UIButton!
    @IBOutlet weak var stopBtn: UIButton!
    
    var recordedAudioURL: NSURL!
    var audioFile: AVAudioFile!
    var audioEngine: AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var stopTimer: NSTimer!
    
    enum ButtonType: Int {
        case Slow = 0, Fast, Chipmunk, Vader, Echo, Reverb
    }

    @IBAction func playSoundForButton(sender: UIButton) {
        print("Play sound button pressed")
        switch (ButtonType(rawValue: sender.tag)!) {
        case .Slow:
            playSound(rate: 0.5)
        case .Fast:
            playSound(rate: 1.5)
        case .Chipmunk:
            playSound(pitch: 1000)
        case .Vader:
            playSound(pitch: -1000)
        case .Echo:
            playSound(echo: true)
        case .Reverb:
            playSound(reverb: true)
        }
        
        configureUI(.Playing)
        
    }
    
    @IBAction func stopButtonPressed(sender: AnyObject) {
        print("Stop audio button pressed")
        stopAudio()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudio()
    }
    
    override func viewWillAppear(animated: Bool) {
        configureUI(.NotPlaying)
    }
}
