//
//  RegistrationViewModel.swift
//  Messenger
//
//  Created by Артём Черныш on 3.11.23.
//

import FirebaseAuth

protocol RegistrationViewModelInterface {
    
    func registerNewUser()
    var model: RegistrationModel { get }
    
}

class RegistrationViewModel: RegistrationViewModelInterface {
    
    var model: RegistrationModel
    
    init() { model = RegistrationModel() }
    
    func registerNewUser() {
        let email: String = model.userEmail.value
        let password: String = model.userPassword.value
        let nickname: String = model.userNickname.value
        checkFreeStatusOfNickname(nickname) { nicknameStatus in
            guard nicknameStatus == true else { return }
            Auth.auth().createUser(withEmail: email, password: password, completion: { [weak self] authDataResult, error in
                guard error == nil else {
                    self?.model.error.accept(error?.localizedDescription ?? "")
                    return
                }
                let userId: String = authDataResult?.user.uid ?? "error"
                self?.model.database.collection("user").document("\(userId)").setData(["id":"\(userId)","nickname":"\(nickname)"])
                self?.model.registrationIsSuccessful.accept(.success)
            })
        }
    }
    
    private func checkFreeStatusOfNickname(_ nickname: String, completion: @escaping (Bool) -> ()) {
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
                    self?.model.registrationIsSuccessful.accept(.nicknameError)
                    nicknameStatus = false
                }
            }
            completion(nicknameStatus)
        })
    }
}
