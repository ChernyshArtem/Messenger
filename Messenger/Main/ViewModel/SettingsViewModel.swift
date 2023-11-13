//
//  SettingsViewModel.swift
//  Messenger
//
//  Created by Артём Черныш on 5.11.23.
//

import UIKit

protocol SettingsViewModelInterface {
    var model: SettingsModel { get }
    func changeNickname(newNickname: String, userId: String, userNameLabel: UILabel)
    func checkFreeStatusOfNickname(_ nickname: String, completion: @escaping (Bool) -> ())
    func deleteAccount()
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
    
    func deleteAccount() {
         
    }
}
