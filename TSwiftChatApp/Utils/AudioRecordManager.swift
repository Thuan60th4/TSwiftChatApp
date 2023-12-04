//
//  AudioRecordManager.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 04/12/2023.
//

import Foundation
import AVFAudio

class AudioRecordManager : NSObject,AVAudioRecorderDelegate {
    var recordingSession : AVAudioSession!
    var audioRecorder : AVAudioRecorder!
    var isGrantedRecordingAudio : Bool!
    
    static let share = AudioRecordManager()
    
    override init(){
        super.init()
        checkRecordPermission()
    }
    
    func checkRecordPermission(){
        switch AVAudioSession.sharedInstance().recordPermission {
            case .granted:
                isGrantedRecordingAudio = true
                break
            case .denied :
                isGrantedRecordingAudio = false
                break
            case . undetermined:
                AVAudioSession.sharedInstance().requestRecordPermission { isAllow in
                    self.isGrantedRecordingAudio = isAllow
                }
            default:
                break
        }
    }
    
    func setupRecorder(){
        if isGrantedRecordingAudio {
            recordingSession = AVAudioSession.sharedInstance()
            do {
                try recordingSession.setCategory(.record, mode: .default)
                try recordingSession.setActive(true)
            } catch {
                print("setting record audio error \(error.localizedDescription)")
            }
        }
    }
    
    func startRecording(fileName: String) {
        let audioFileNameURL = getDocumentUrl().appendingPathComponent(fileName + ".m4a", isDirectory: false)
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do {
            audioRecorder = try AVAudioRecorder(url: audioFileNameURL, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
        } catch {
            print("error recording \(error.localizedDescription)")
            finishRecording()
        }
    }
    
    func finishRecording(){
        if audioRecorder != nil {
            audioRecorder.stop()
            audioRecorder = nil
        }
    }
    
}
