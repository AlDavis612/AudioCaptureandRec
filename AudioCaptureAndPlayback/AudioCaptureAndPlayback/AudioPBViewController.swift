//
//  AudioPBViewController.swift
//  AudioCaptureAndPlayback
//
//  Created by Alex Davis on 11/1/19.
//  Copyright © 2019 Alex Davis. All rights reserved.
//

import UIKit
import AVKit

class AudioPBViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    
    @IBOutlet weak var RecordBarButton: UIBarButtonItem!
    @IBOutlet weak var PlayBarButton: UIBarButtonItem!
    
    var audioSession: AVAudioSession?
    var fileManager: FileManager?
    var documentDirectoryURL: URL?
    var audioFileName = "audioRec.caf"
    var audioFileURL: URL?
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        RecordBarButton.isEnabled = false
        PlayBarButton.isEnabled = false
        
        initializeAudioFileStorage()
        initializeAudioSession()
        
        audioSession?.requestRecordPermission() {
            [unowned self] allowed in
            if allowed {
                self.initializeAudioRecorder()
                guard let _ = self.audioSession, let _ = self.audioRecorder else {
                    return
                }
                
                self.RecordBarButton.isEnabled = true
            } else {
                
            }
        }
    }
    
    func initializeAudioFileStorage() {
        let fileManager = FileManager.default
        let documentDirectoryPaths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        documentDirectoryURL = documentDirectoryPaths[0]
        audioFileURL = documentDirectoryURL?.appendingPathComponent(audioFileName)
    }
    
    func initializeAudioSession() {
        audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession?.setCategory(.playAndRecord, mode: .default, options: [])
        } catch {
        }
    }
    
    func initializeAudioRecorder() {
        let recordingSettings =
            [AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue,
             AVEncoderBitRateKey: 16,
             AVNumberOfChannelsKey: 2,
             AVSampleRateKey: 44100.0] as [String : Any]
        
        guard let audioFileURL = audioFileURL else {
            return
        }
        
        do {
            try audioRecorder = AVAudioRecorder(url: audioFileURL, settings: recordingSettings)
            audioRecorder?.delegate = self
        } catch {
        }
    }
    
    @IBAction func playButtonTapped(_ sender: Any) {
        guard let audioFileURL = audioFileURL else {
        presentAlert(message: "Error")
        return
    }
    
        func recordButtonTapped(_ sender: Any) {
        if (audioRecorder?.isRecording == false) {
            PlayBarButton.isEnabled = false
            RecordBarButton.image = UIImage(named: "stop")
            audioRecorder?.record()
        } else {
            PlayBarButton.isEnabled = true
            RecordBarButton.image = UIImage(named: "record")
            audioRecorder?.stop()
        }
    }
        
    guard let audioRecorder = audioRecorder, audioRecorder.isRecording == false else {
                presentAlert(message: "Error")
                return
            }
               
            if let audioPlayer = audioPlayer {
                if (audioPlayer.isPlaying) {
                    audioPlayer.stop()
                    PlayBarButton.image = UIImage(named: "play")
                    RecordBarButton.isEnabled = true
                    return
                }
            }
               
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: audioFileURL)
                audioPlayer?.delegate = self
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
                RecordBarButton.isEnabled = false
                PlayBarButton.image = UIImage(named: "stop")
            } catch {
                presentAlert(message: "Error")
                return
            }
        }
        
        func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
            RecordBarButton.isEnabled = true
            PlayBarButton.image = UIImage(named: "play")
        }
    
        func presentAlert(message: String) {
            let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
           
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
               
            present(alert, animated: true, completion: nil)
        }
}
