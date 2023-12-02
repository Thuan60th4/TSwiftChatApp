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
        // navigate to apple map
        //        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: locationItem.location.coordinate, addressDictionary: nil))
        //        mapItem.name = mkMesage.sender.displayName
        //        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
        
    }
}
