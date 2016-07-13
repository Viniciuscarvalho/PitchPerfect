//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Vinicius Carvalho on 07/07/16.
//  Copyright © 2016 Vinicius Carvalho. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    
    var audioRecorder: AVAudioRecorder!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stopRecordingButton.enabled = false
    }
    
    func buttonStatus(recording: Bool) {
        recordButton.enabled = !recording
        stopRecordingButton.enabled = recording
    }
    
    @IBAction func recordAudio(sender: AnyObject) {
        buttonStatus(true)
        recordingLabel.text = "Recording in progress"
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        
        let session = AVAudioSession.sharedInstance()
        do {
            try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        }
        
        try! audioRecorder = AVAudioRecorder (URL: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.meteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    @IBAction func stopRecording(sender: AnyObject) {
        buttonStatus(false)
        recordingLabel.text = "Tap to record"
        
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    // MARK - Finish Record
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if (flag) {
            performSegueWithIdentifier("stopRecording", sender: audioRecorder.url)
        } else {
            print ("A gravação de seu audio falhou, tente novamente.")
        }
        
    }
    
    // MARK - PrepareForSegue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "stopRecording") {
            let playSoundsVC = segue.destinationViewController as! PlaySoundsViewController
            let recordedAudioURL = sender as! NSURL
            playSoundsVC.recordedAudioURL = recordedAudioURL
        }
    }

    
}