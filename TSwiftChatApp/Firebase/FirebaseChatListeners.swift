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
    
    //MARK: - Add user to chats
    func addChatForUser(userId: String ,chatRoomId: String){
        FirebaseRefFor(collection: .UserChats).document(userId).setData([chatRoomId : chatRoomId],merge: true)
    }
    
    //MARK: - Remove user from chat
    func removeUserFromchat(userId: String ,chatRoomId: String, newMemberIds : [String]){
//        chatListenerId[chatRoomId]?.remove()
        FirebaseRefFor(collection: .UserChats).document(userId).updateData([chatRoomId : FieldValue.delete()])
        FirebaseRefFor(collection: .Chat).document(chatRoomId).updateData(["memberIds" : newMemberIds])
    }

    
    //MARK: - Listener when have chat
    func fetchNewChat(completion : @escaping (_ allchat : [String : Chat]) -> Void){
        let dispatchGroup = DispatchGroup()
        FirebaseRefFor(collection: .UserChats).document(User.currentId).addSnapshotListener { document, error in
            var chatsFoundCount = 0
            var chatsData =  [String : Chat]()
            guard let listChatId = document?.data() as? [String: String],!listChatId.isEmpty else {
                print("Error fetching list chat")
                completion([:])
                return
            }
            for chatId in listChatId.values {
                self.chatListenerId[chatId] = FirebaseRefFor(collection: .Chat).document(chatId ).addSnapshotListener { chatSnapshot, error in
                    if let chatSnapshot = chatSnapshot {
                        guard let chatInfo = try? chatSnapshot.data(as: Chat.self) else {
                            print("Error fetching \(chatId) data")
                            return
                        }
                        if !chatInfo.memberIds.contains(User.currentId){
                            self.chatListenerId[chatId]?.remove()
                            return
                        }
                        
                        for userId in chatInfo.memberIds {
                            if self.listUser[userId] != nil {
                                continue
                            }
                            dispatchGroup.enter()
                            FirebaseRefFor(collection: .User).document(userId).getDocument { userDocument, error in
                                if let userDocument = userDocument, userDocument.exists {
                                    if let userInfo = try? userDocument.data(as: User.self) {
                                        self.listUser[userId] = userInfo
                                    }
                                }
                                dispatchGroup.leave()
                            }
                        }
                        
                        dispatchGroup.notify(queue: .main) {
                            chatsFoundCount+=1
                            chatsData[chatId] = chatInfo
                            if (chatsFoundCount >= listChatId.values.count) {
                                completion(chatsData)
                            }
                        }
                    }
                }
            }
            dispatchGroup.notify(queue: .main) {
                if (chatsFoundCount == 0) {
                    completion([:])
                }
            }
        }
    }
}
