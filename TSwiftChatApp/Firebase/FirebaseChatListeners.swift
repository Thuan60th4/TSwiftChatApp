//
//  FirebaseChatListeners.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 02/10/2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirebaseChatListeners {
    static let shared = FirebaseChatListeners()
    var listUser = [String : User]()
    private var chatListenerId = [String : ListenerRegistration]()
    
    //MARK: - Reset when logout
    func resetChat() {
        listUser = [String : User]()
        for chatListner in chatListenerId.values {
            chatListner.remove()
        }
        chatListenerId = [String : ListenerRegistration]()
    }
    
    //MARK: - Save a new chat
    func createNewChat(_ data : Chat){
        do{
            try FirebaseRefFor(collection: .Chat).document(data.chatRoomId).setData(from: data)
            for userId in data.memberIds {
                addChatForUser(userId: userId, chatRoomId: data.chatRoomId)
            }
        }
        catch{
            print("save chat info to firestore error \(error.localizedDescription)")
        }
    }
    
    //MARK: - Save user chats
    func addChatForUser(userId: String ,chatRoomId: String){
        FirebaseRefFor(collection: .UserChats).document(userId).setData([UUID().uuidString : chatRoomId],merge: true)
    }
    
    //MARK: - Listener when have chat
    func fetchNewChat(completion : @escaping (_ allchat : [String : Chat]) -> Void){
        var chatsFoundCount = 0
        var chatsData =  [String : Chat]()
        FirebaseRefFor(collection: .UserChats).document(User.currentId).addSnapshotListener { document, error in
            guard let listChatId = document?.data() as? [String: String],!listChatId.isEmpty else {
                print("Error fetching list chat")
                return
            }
            for chatId in listChatId.values {
                self.chatListenerId[chatId] = FirebaseRefFor(collection: .Chat).document(chatId ).addSnapshotListener { chatSnapshot, error in
                    if let chatSnapshot = chatSnapshot {
                        guard let chatInfo = try? chatSnapshot.data(as: Chat.self) else {
                            print("Error fetching \(chatId) data")
                            return
                        }
                        chatsFoundCount+=1
                        if !chatInfo.memberIds.contains(User.currentId){
                            self.chatListenerId[chatId]?.remove()
                            return
                        }
                        for userId in chatInfo.memberIds {
                            if self.listUser[userId] != nil {
                                continue
                            }
                            FirebaseRefFor(collection: .User).document(userId).getDocument { userDocument, error in
                                if let userDocument = userDocument, userDocument.exists {
                                    if let userInfo = try? userDocument.data(as: User.self) {
                                        self.listUser[userId] = userInfo
                                    }
                                }
                                chatsData[chatId] = chatInfo
                                if (chatsFoundCount >= listChatId.values.count) {
                                    completion(chatsData)
                                }
                            }
                        }
                    }
                }
            }
        }
        if (chatsFoundCount == 0) {
            completion([:])
        }
    }
}
