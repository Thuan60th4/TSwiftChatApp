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
    var newMessageListenter: ListenerRegistration?
    private var userChatListenter : ListenerRegistration?
    private var chatListenerId = [String : ListenerRegistration]()
    
    //MARK: - Reset when logout
    func resetChat() {
        listUser = [String : User]()
        userChatListenter?.remove()
        for chatListner in chatListenerId.values {
            chatListner.remove()
        }
        chatListenerId = [String : ListenerRegistration]()
    }
    
    //MARK: - Save a new chat
    func createNewChat(_ data : Chat){
        do{
            try FirebaseRefFor(collection: .Chat).document(data.chatRoomId).setData(from: data,merge: true)
            for userId in data.memberIds {
                addChatForUser(userId: userId, chatRoomId: data.chatRoomId)
            }
        }
        catch{
            print("save chat info to firestore error \(error.localizedDescription)")
        }
    }
    
    //MARK: - Add one chat for user
    func addChatForUser(userId: String ,chatRoomId: String){
        FirebaseRefFor(collection: .UserChats).document(userId).setData([chatRoomId : chatRoomId],merge: true)
    }
    
    //MARK: - Remove user from chat
    func removeUserFromchat(userId: String ,chatRoomId: String, newMemberIds : [String]){
        //chatListenerId[chatRoomId]?.remove()
        FirebaseRefFor(collection: .UserChats).document(userId).updateData([chatRoomId : FieldValue.delete()])
        FirebaseRefFor(collection: .Chat).document(chatRoomId).setData(["memberIdsLeft" : newMemberIds,"timeLeave" : [userId : Date().timeIntervalSince1970]], merge: true)
    }
    
    //MARK: - Send a message
    func addAMessage(message: LocalMessage){
        do {
            //let encoder = Firestore.Encoder()
            //let data = try encoder.encode(message)
            //FirebaseRefFor(collection: .Message).document(message.chatRoomId).setData([UUID().uuidString : data],merge: true)
            //Buộc phải như này thì mới lưu đc nhiều data(chỉ có collection ms lưu đc nhiều document)
            try FirebaseRefFor(collection: .Message).document(message.chatRoomId).collection(message.chatRoomId).document(message.id).setData(from: message)
        } catch {
            print("send a message to firebase error \(error.localizedDescription)")
        }
    }
    
    //MARK: - Load when chat is empty
    //there is no guarantee that async functions will run on the same thread so must add @MainActor
    @MainActor func loadOldChat(chatRoomId: String,_ isChannel : Bool) async{
//        var timeQuery : TimeInterval?
//
//        FirebaseRefFor(collection: .Chat).document(chatRoomId).getDocument { document, error in
//            if let chatDocument = document, chatDocument.exists{
//                if let chatInfo = try? chatDocument.data(as: Chat.self){
//                    timeQuery = chatInfo.timeLeave?[User.currentId]
//                }
//            }
//            var query : Query = FirebaseRefFor(collection: .Message).document(chatRoomId).collection(chatRoomId)
//            if timeQuery != nil {
//                query = query.whereField("sentDate", isGreaterThan: timeQuery!)
//            }
//            query.getDocuments { (querySnapshot, err) in
//                if let err = err {
//                    print("Error getting documents: \(err)")
//                } else {
//                    for document in querySnapshot!.documents {
//                        if let message = try? document.data(as: LocalMessage.self){
//                            RealmManager.shared.saveToRealm(message)
//                        }
//                    }
//                }
//            }
//
//        }
        do {
            var query: Query = FirebaseRefFor(collection: .Message).document(chatRoomId).collection(chatRoomId)
            if !isChannel {
                let chatInfo = try await FirebaseRefFor(collection: .Chat).document(chatRoomId).getDocument(as: Chat.self)
                let timeQuery = chatInfo.timeLeave?[User.currentId]
                if (timeQuery != nil)  {
                    query = query.whereField("sentDate", isGreaterThan: timeQuery!)
                }
            }
            let listMmessage = try await query.order(by: "sentDate", descending: false).getDocuments()
            for document in listMmessage.documents {
                if let message = try? document.data(as: LocalMessage.self){
                    RealmManager.shared.saveToRealm(message)
                }
            }
        } catch  {
            print("async await error \(error.localizedDescription)")
        } 
    }
    
    //MARK: - Listener when have new message
    func listenForNewMessage(chatRoomId: String,lastMessageDate : TimeInterval){
        newMessageListenter = FirebaseRefFor(collection: .Message)
            .document(chatRoomId)
            .collection(chatRoomId)
            .whereField("sentDate", isGreaterThan: lastMessageDate)
            .addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else { return }
            snapshot.documentChanges.forEach { change in
                if change.type == .added{
                    if let message = try? change.document.data(as: LocalMessage.self){
                        RealmManager.shared.saveToRealm(message)
                    }
                }
            }
        }
    }
    
    //MARK: - Listener when have chat
    func fetchNewChat(completion : @escaping (_ allchat : [String : Chat]) -> Void){
        let dispatchGroup = DispatchGroup()
        userChatListenter = FirebaseRefFor(collection: .UserChats)
            .document(User.currentId)
            .addSnapshotListener { document, error in
            var chatsFoundCount = 0
            var chatsData =  [String : Chat]()
            guard let listChatId = document?.data() as? [String: String],!listChatId.isEmpty else {
                print("Error fetching list chat")
                completion([:])
                return
            }
            for chatId in listChatId.values {
                self.chatListenerId[chatId] = FirebaseRefFor(collection: .Chat)
                    .document(chatId )
                    .addSnapshotListener { chatSnapshot, error in
                    guard let chatInfo = try? chatSnapshot?.data(as: Chat.self) else {
                        print("Error fetching \(chatId) data")
                        return
                    }
                    if !chatInfo.memberIdsLeft.contains(User.currentId){
                        self.chatListenerId[chatId]?.remove()
                        return
                    }
                    
                    for userId in chatInfo.memberIds {
                        if self.listUser[userId] != nil {
                            continue
                        }
                        dispatchGroup.enter()
                        DispatchQueue.global().async {
                            FirebaseRefFor(collection: .User).document(userId).getDocument { userDocument, error in
                                if let userDocument = userDocument, userDocument.exists {
                                    if let userInfo = try? userDocument.data(as: User.self) {
                                        self.listUser[userId] = userInfo
                                    }
                                }
                                dispatchGroup.leave()
                            }
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
            dispatchGroup.notify(queue: .main) {
                if (chatsFoundCount == 0) {
                    completion([:])
                }
            }
        }
    }
}
