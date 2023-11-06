//
//  MessageCellDelegate.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 13/10/2023.
//

import Foundation
import MessageKit
import AVKit
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
}
