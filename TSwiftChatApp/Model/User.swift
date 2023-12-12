//
//  User.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 27/08/2023.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore


struct User : Codable,Equatable{
    
    var id : String
    var username : String
    var email : String
    var pushToken : String
    var avatar : String
    var status : String
    var description : String
    
    static var currentId :String {
        return Auth.auth().currentUser!.uid
    }
    
    static var currentUser : User? {
        if Auth.auth().currentUser != nil{
            if let dictionary = UserDefaults.standard.data(forKey: KCURRENTUSER) {
                let decoder = JSONDecoder()
                do {
                    let data = try decoder.decode(User.self, from: dictionary)
                    return data
                }
                catch{
                    print("Error decoder UserDefault data \(error)")
                }
            }
        }
        return nil
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}

func saveUserToLocalStorage (_ user : User){
    let encoder = JSONEncoder()
    do{
      let jsonData = try encoder.encode(user)
        UserDefaults.standard.set(jsonData, forKey: KCURRENTUSER)
    }
    catch{
        print("encode data to UserDefault failure \(error)")

    }
}
