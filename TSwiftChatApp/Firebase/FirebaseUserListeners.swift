//
//  FirebaseUserListeners.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 28/08/2023.
//

import Foundation
import FirebaseAuth
import FirebaseFirestoreSwift

class FirebaseUserListeners {
    static let shared = FirebaseUserListeners()
    
    //MARK: - Register listener
    func RegisterUserWith(email : String,password : String,completion : @escaping (_ error : Error?)-> Void ){
        Auth.auth().createUser(withEmail: email, password: password) { AuthDataResult, err in
            completion(err)
            if let authRes = AuthDataResult{
                authRes.user.sendEmailVerification { error in
                    if let error = error{
                        print("send email verification failure \(error.localizedDescription)")
                    }
                }
                let userInfo = authRes.user
                let user = User(id: userInfo.uid, username: email , email: email, pushToken: "", avatar: "", status: "Online", description: "")
                saveUserToLocalStorage(user)
                self.SaveUserToFirestore(user)
            }
        }
    }
    
    //MARK: - Login listener
    func LoginUserWith(email : String,password : String,completion : @escaping (_ error : Error?,_ verified : Bool)-> Void ){
        Auth.auth().signIn(withEmail: email, password: password) {  authResult, error in
            completion(error,authResult?.user.isEmailVerified ?? false)
            
            if let authResult = authResult, authResult.user.isEmailVerified{
                self.FetchUserFromFirebase(userId: authResult.user.uid)
            }
        }
    }
    
    //MARK: - Logout listener
    func LogoutUserListener (completion : @escaping (_ error : Error?) -> Void){
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.removeObject(forKey: KCURRENTUSER)
            completion(nil)
        } catch {
            completion(error)
        }
        
    }
    
    
    //MARK: - Reset password
    func ResetPasswordWith(email : String,completion : @escaping (_ error : Error?) -> Void){
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            completion(error)
        }
    }
    
    
    //MARK: - Save user info to firestore
    func SaveUserToFirestore(_ user : User){
        do{
            try FirebaseRefFor(collection: .User).document(user.id).setData(from: user)
        }
        catch{
            print("save data to firestore error \(error.localizedDescription)")
        }
    }
    
    //MARK: - Fetch user from firebase
    func FetchUserFromFirebase(userId : String){
        FirebaseRefFor(collection: .User).document(userId).getDocument { document, error in
            if let document = document, document.exists {
                do{
                    let user = try document.data(as: User.self)
                    saveUserToLocalStorage(user)
                }
                catch{
                    print("get data to firestore error \(error.localizedDescription)")
                    
                }
            }
        }
    }
    
    
    //MARK: - Fetch list online user from firebase
    func FetchListOnlineUserFromFirebase( completion : @escaping (_ listUser : [User])-> Void){
        FirebaseRefFor(collection: .User)
            .limit(to: 500)
            .whereField("status", isEqualTo: "Online")
            .whereField("id", isNotEqualTo: User.currentId)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    completion( querySnapshot!.documents.compactMap({ document in
                        try? document.data(as: User.self)
                    }))
                }
            }
    }
    
    //MARK: - Fetch list specific user from firebase
    func FetchListUserIDFromFirebase(userIds : [String], completion : @escaping (_ listUser : [User])-> Void){
        var userArray : [User] = []
        for (index,userId) in userIds.enumerated() {
            FirebaseRefFor(collection: .User).document(userId).getDocument(as: User.self) {  result in
                switch result {
                    case .success(let user):
                        userArray.append(user)
                    case .failure(let error):
                        print("Get user failure: \(error)")
                }
                if index == userIds.count{
                    completion(userArray)
                }
            }
        }
    }
    
}




