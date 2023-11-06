//
//  GlobalFunc.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 17/09/2023.
//

import Foundation
import UIKit
import AVFoundation

func fileNameFrom(_ fileUrl: String) -> String? {
    return fileUrl.components(separatedBy: "_").last?.components(separatedBy: ".jpg").first
}

func generateThumbnailVideo(for videoURL: URL) -> UIImage? {
    let asset = AVURLAsset(url: videoURL)
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    
    imageGenerator.appliesPreferredTrackTransform = true
    
    do {
        let cgImage = try imageGenerator.copyCGImage(at: CMTime(seconds: 0.5, preferredTimescale: 1000), actualTime: nil)
        return UIImage(cgImage: cgImage)
    } catch {
        print("Lỗi khi tạo thumbnail: \(error.localizedDescription)")
        return nil
    }
}
