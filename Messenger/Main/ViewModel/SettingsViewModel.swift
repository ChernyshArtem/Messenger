//
//  SettingsViewModel.swift
//  Messenger
//
//  Created by Артём Черныш on 5.11.23.
//

import UIKit
import FirebaseAuth

protocol SettingsViewModelInterface {
    var model: SettingsModel { get }
    func changeNickname(newNickname: String, userId: String, userNameLabel: UILabel)
    func checkFreeStatusOfNickname(_ nickname: String, completion: @escaping (Bool) -> ())
    func deleteAccount(userId: String, completion: @escaping () -> ())
    func downloadUserImage(userId: String)
    func uploadNewUserImage(userId: String, userNickname: String, imageData: Data)
}

class SettingsViewModel: SettingsViewModelInterface {
    
    var model: SettingsModel
    
    init() { model = SettingsModel() }
    
    func changeNickname(newNickname: String, userId: String, userNameLabel: UILabel) {
        let database = model.database
        database.collection("user").document(userId).updateData(["nickname": newNickname ])
        UserDefaults.standard.string(forKey: "userNickname")
        UserDefaults.standard.set(newNickname, forKey: "userNickname")
        userNameLabel.text = newNickname
    }
    
    func checkFreeStatusOfNickname(_ nickname: String, completion: @escaping (Bool) -> ()) {
        var nicknameStatus = true
        let database = model.database
        database.collection("user").getDocuments(completion: { [weak self] (querySnapshot, error) in
            guard error == nil else {
                self?.model.error.accept(error?.localizedDescription ?? "")
                return
            }
            for document in querySnapshot!.documents {
                guard let userNickname: String = document.data()["nickname"] as? String else { return }
                if nickname.lowercased() == userNickname.lowercased() {
                    nicknameStatus = false
                }
            }
            completion(nicknameStatus)
        })
    }
    
    func downloadUserImage(userId: String) {
        PhotoWorker.downloadPhotoFromDatabase(userId: userId) { [weak self] data in
            self?.model.imageData.accept(data)
        }
    }
    
    func uploadNewUserImage(userId: String, userNickname: String, imageData: Data) {
        PhotoWorker.uploadPhotoToDatabase(userId: userId, imageData: imageData) { [weak self] newURL in
            self?.model.database.collection("user").document(userId).updateData(["id":userId,
                                                                                 "nickname":userNickname,
                                                                                 "imageURL": newURL])
        }
        model.imageData.accept(imageData)
    }
    
    func deleteAccount(userId: String, completion: @escaping () -> ()) {
        let database = model.database
        database.collection("user").document(userId).collection("chats").getDocuments { [weak self] (querySnapshot, error) in
            guard error == nil else {
                self?.model.error.accept(error?.localizedDescription ?? "")
                return
            }
            for document in querySnapshot!.documents {
                guard let otherUserId: String = document.data()["otherUser"] as? String,
                      let chatId: String = document.data()["id"] as? String else { return }
                database.collection("user").document(userId).collection("chats").document(chatId).delete()
                database.collection("user").document(otherUserId).collection("chats").document(chatId).delete()
                database.collection("chat").document(chatId).collection("messages").getDocuments { [weak self] (querySnapshot, error) in
                    guard error == nil else {
                        self?.model.error.accept(error?.localizedDescription ?? "")
                        return
                    }
                    for document in querySnapshot!.documents {
                        let documentId = document.documentID
                        database.collection("chat").document(chatId).collection("messages").document(documentId).delete()
                    }
                }
                database.collection("chat").document(chatId).delete()
            }
            database.collection("user").document(userId).delete()
            UserDefaults.standard.set(nil, forKey: "userNickname")
            UserDefaults.standard.set(nil, forKey: "userId")
            Auth.auth().currentUser?.delete()
            PhotoWorker.deletePhotoFromDatabase(userId: userId)
            completion()
        }
    }
}
