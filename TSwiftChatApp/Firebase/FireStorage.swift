//
//  FireStorage.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 17/09/2023.
//

import Foundation
import FirebaseStorage
import ProgressHUD

let storage = Storage.storage()

class FireStorage{
    
    //MARK: - Images
    //Class func cũg tươg tự như static nhưng khác cái là nó có thể đc ghi đè ở lớp con
    class func uploadImageFor(directory : String,_ image : UIImage, completion: @escaping (_ imageUrl: String?) -> Void){
        let storageRef = storage.reference().child(directory)
        let imageData = image.jpegData(compressionQuality: 0.6)
        var uploadTask : StorageUploadTask!
        uploadTask = storageRef.putData(imageData!, metadata: nil) { (metadata, error) in
            uploadTask.removeAllObservers()
            ProgressHUD.dismiss()
            storageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    completion(nil)
                    return
                }
                completion(downloadURL.absoluteString)
            }
        }
        uploadTask.observe(.progress) { snapshot in
            let progress = snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount
            ProgressHUD.showProgress(CGFloat(progress))
        }
    }
    
    class func uploadVideoTo(chatRoomId: String, videoURL: URL, thumbnail: UIImage, completion : @escaping (_ thumbnailLink :String, _ videoLink : String) -> Void) {

        let dispatchGroup = DispatchGroup()
        let videoRef = storage.reference().child("MediaMessage/video/\(chatRoomId)/_\(UUID().uuidString).mov")
        let imageRef = storage.reference().child("MediaMessage/photo/\(chatRoomId)/_\(UUID().uuidString).jpg")
        
        var videoUploadedLink: String?
        var imageUploadedLink: String?
        
        dispatchGroup.enter()
        DispatchQueue.global().async {
            let videoData = NSData(contentsOf: videoURL)
            videoRef.putData(videoData! as Data, metadata: nil) { (metadata, error) in
                videoRef.downloadURL { url, error in
                    videoUploadedLink = url?.absoluteString
                    dispatchGroup.leave()

                }
            }
        }
        dispatchGroup.enter()
        DispatchQueue.global().async {
            let imageData = thumbnail.jpegData(compressionQuality: 0.6)
            imageRef.putData(imageData!, metadata: nil){ (metadata, error) in
                imageRef.downloadURL { url, error in
                    imageUploadedLink = url?.absoluteString
                    dispatchGroup.leave()

                }
            }
        }
        
        dispatchGroup.notify(queue: .global()) {
            completion(imageUploadedLink ?? "", videoUploadedLink ?? "")
        }
    }
    
    
    //MARK: - Download image from url (instead of SDWebImage)
    class func downloadImageFrom(imageUrl : String,completion : @escaping (_ image : UIImage?) -> Void){
        
        //get userId from avatar url
        let imageByUserId = fileNameFrom(imageUrl)
        guard let imageByUserId = imageByUserId else{
            fatalError("cant get userID from your image")
        }
        //check if avatar was downloaded in localstorage or not
        if fileExistAt(Path: imageByUserId) {
            if let contentOfFile = UIImage(contentsOfFile: fileInDocumentDirectory(filename: imageByUserId)){
                completion(contentOfFile)
                return
            }
            completion(nil)
        }
        else {
            let downloadUrl = URL(string: imageUrl)
            DispatchQueue(label: "imageDownloadQueue").async {
                if let data = NSData(contentsOf: downloadUrl!){
                    FireStorage.saveFileLocally(fileData: data, fileName: imageByUserId)
                    DispatchQueue.main.async {
                        completion(UIImage(data: data as Data))
                    }
                }
                else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    
                }
            }
        }
    }
    
    
    //MARK: - Save Locally
    class func saveFileLocally(fileData : NSData,fileName : String){
        let docUrl = getDocumentUrl().appendingPathComponent(fileName, isDirectory: false)
        fileData.write(to: docUrl,atomically: true)
    }
}

//Helper

func fileInDocumentDirectory(filename : String) -> String{
    return getDocumentUrl().appendingPathComponent(filename).path
}

func getDocumentUrl() -> URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
}

func fileExistAt(Path : String) -> Bool{
    return FileManager.default.fileExists(atPath: fileInDocumentDirectory(filename:Path))
}

