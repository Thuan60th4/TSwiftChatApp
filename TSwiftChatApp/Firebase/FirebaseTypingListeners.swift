//
//  FirebaseTypingListeners.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 31/10/2023.
//

import Foundation
import FirebaseFirestore

class FirebaseTypingListeners {
    static let shared = FirebaseTypingListeners()
    private init(){}
    
    var typingListener : ListenerRegistration!
    
    func createTypingObserver(chatRoomId : String, completion : @escaping (_ isTyping : Bool) -> Void){
        typingListener = FirebaseRefFor(collection: .Typing).document(chatRoomId).addSnapshotListener({ snapshot, error in
            if let snapshot = snapshot?.data() {
                for data in snapshot {
                    if data.key != User.currentId{
                        completion(data.value as! Bool)
                    }
                }
            }
        })
    }
    
    func updateTyingStatus(typing : Bool, chatRoomId : String){
        FirebaseRefFor(collection: .Typing).document(chatRoomId).setData([User.currentId : typing],merge: true)
    }
    
    func removeTypingObserver(){
        typingListener.remove()
    }
    
}
