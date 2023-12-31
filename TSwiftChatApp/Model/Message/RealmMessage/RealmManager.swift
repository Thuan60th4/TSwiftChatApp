//
//  RealmManager.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 21/10/2023.
//

import Foundation
import RealmSwift

class RealmManager {
   static let shared = RealmManager()
    let realm = try! Realm()
    private init(){
    }

    func saveToRealm<T: Object>(_ object : T){
        do {
            //phân biệt giữa các user khi logout
            object.setValue(User.currentId, forKey: "memberLocalId")
            let oldKey = object["id"]! as! String
            object.setValue(User.currentId + oldKey , forKey: "id")
            try realm.write({
                realm.add(object,update: .all)
            })
        } catch {
            print("save to realm failure \(error.localizedDescription)")
        }
    }
    
    func removeToRealm<T: Object>(_ object : T.Type,chatRoomId: String){
        do {
            try realm.write {
                let objectsToDelete = realm.objects(object).filter("chatRoomId == %@ && memberLocalId == %@",chatRoomId ,User.currentId)
                realm.delete(objectsToDelete)
            }
        } catch {
            print("delete to realm failure \(error.localizedDescription)")

        }
    }
}
