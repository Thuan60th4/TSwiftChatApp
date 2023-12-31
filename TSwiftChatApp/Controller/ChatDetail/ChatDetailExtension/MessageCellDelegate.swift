//
//  MessageCellDelegate.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 13/10/2023.
//

import Foundation
import MessageKit
import AVKit
import MapKit
import AVFoundation
import SKPhotoBrowser

extension ChatDetailViewController : MessageCellDelegate {
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell)  else { return }
        let mkMesage = mkMessages[indexPath.section]
        
        if let photoItem = mkMesage.photoItem, photoItem.url != nil {
            let photo = SKPhoto.photoWithImageURL(photoItem.url!.absoluteString)
            let browser = SKPhotoBrowser(photos: [photo],initialPageIndex: 0)
            present(browser, animated: true, completion: nil)
        }
        else if let videoItem = mkMesage.videoItem, videoItem.url != nil {
            let moviePlayer = AVPlayerViewController()
            let session = AVAudioSession.sharedInstance()
            try! session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            
            moviePlayer.player = AVPlayer(url: videoItem.url!)
            present(moviePlayer, animated: true) {
                moviePlayer.player?.play()
            }
        }
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell)  else { return }
        let mkMesage = mkMessages[indexPath.section]
        
        let mapView = MapViewController()
        mapView.location = mkMesage.locationItem?.location
        mapView.locationName = mkMesage.sender.displayName
        navigationController?.pushViewController(mapView, animated: true)
    }
    
    func didTapPlayButton(in cell: AudioMessageCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
                print("Failed to identify message when audio cell receive tap gesture")
                return
        }
        let message = mkMessages[indexPath.section]
        guard audioController.state != .stopped else {
            // There is no audio sound playing - prepare to start playing for given audio message
            audioController.playSound(for: message, in: cell)
            return
        }
        if audioController.playingMessage?.messageId == message.messageId {
            // tap occur in the current cell that is playing audio sound
            if audioController.state == .playing {
                audioController.pauseSound(for: message, in: cell)
            } else {
                audioController.resumeSound()
            }
        } else {
            // tap occur in a difference cell that the one is currently playing sound. First stop currently playing and start the sound for given message
            audioController.stopAnyOngoingPlaying()
            audioController.playSound(for: message, in: cell)
        }
    }
}
