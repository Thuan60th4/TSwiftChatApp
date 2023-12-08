//
//  FirebaseReference.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 28/08/2023.
//

import Foundation
import FirebaseFirestore

enum FCollectionRef : String{
    case User
    case Chat
    case UserChats
    case Message
    case Typing
    case Channel
}
//get tham chiếu của đường dẫn vào database
func FirebaseRefFor(collection : FCollectionRef ) -> CollectionReference {
    return Firestore.firestore().collection(collection.rawValue)
}
