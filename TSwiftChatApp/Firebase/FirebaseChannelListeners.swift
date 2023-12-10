//
//  FirebaseChannelListeners.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 08/12/2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirebaseChannelListeners{
    
    static let shared = FirebaseChannelListeners()
    
    var channelListener : ListenerRegistration!
    
    private init(){}
    
    //MARK: - Add channel
    func saveChannel(channel : Channel){
        do {
            try FirebaseRefFor(collection: .Channel).document(channel.id).setData(from: channel)
        } catch {
            print("Add channel failure \(error.localizedDescription)")
        }
    }
    
    
    //MARK: - Fetch channel
    func fetchMyChannels(completion: @escaping (_ allChannels: [Channel]) ->Void) {
        channelListener = FirebaseRefFor(collection: .Channel)
            .whereField(KADMINID, isEqualTo: User.currentId)
            .order(by: "lastMessageDate", descending: true)
            .addSnapshotListener({ (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("no documents for user channels")
                    return
                }
                let allChannels = documents.compactMap { (queryDocumentSnapshot)  in
                    try? queryDocumentSnapshot.data(as: Channel.self)
                }
                DispatchQueue.main.async {
                    completion(allChannels)
                }
            })
    }
    
    func fetchSubcribedChannels(completion: @escaping (_ allChannels: [Channel]) ->Void) {
        channelListener = FirebaseRefFor(collection: .Channel)
            .whereField(KMEMBERIDS, arrayContains: User.currentId)
            .order(by: "lastMessageDate", descending: true)
            .addSnapshotListener({ (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("no documents for subcribed channels")
                    return
                }
                let allChannels = documents.compactMap { (queryDocumentSnapshot)  in
                    try? queryDocumentSnapshot.data(as: Channel.self)
                }
                DispatchQueue.main.async {
                    completion(allChannels)
                }
            })
    }
    
    //MARK: - Delete channel
    func deleteChannel(_ channel: Channel) {
        FirebaseRefFor(collection: .Channel).document(channel.id).delete()
    }
}
