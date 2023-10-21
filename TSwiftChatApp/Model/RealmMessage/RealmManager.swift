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
            try realm.write({
                realm.add(object,update: .all)
            })
        } catch {
            print("save to realm failure \(error.localizedDescription)")
        }
    }
}
