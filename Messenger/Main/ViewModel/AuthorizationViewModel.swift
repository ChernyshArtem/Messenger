//
//  AuthorizationViewModel.swift
//  Messenger
//
//  Created by Артём Черныш on 2.11.23.
//

import UIKit
import FirebaseAuth

protocol AuthorizationViewModelInterface {
    
    func loginUser()
    var model: AuthorizationModel { get }
    
}

class AuthorizationViewModel: AuthorizationViewModelInterface {
    
    let model: AuthorizationModel
    
    init() {
        model = AuthorizationModel()
    }
    
    func loginUser() {
        let email: String = model.userEmail.value
        let password: String = model.userPassword.value
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authDataResult, error in
            guard error == nil else {
                self?.model.error.accept(error?.localizedDescription ?? "")
                return
            }
            let userId: String = authDataResult?.user.uid ?? ""
            self?.model.database.collection("user").document(userId).getDocument { document, error in
                guard let document,
                      document.exists,
                      let data = document.data() else { return }
                let userNickname: String = data["nickname"] as? String ?? ""
                UserDefaults.standard.set(userNickname, forKey: "userNickname")
                UserDefaults.standard.set(userId, forKey: "userId")
                self?.model.authorizationIsSuccessful.accept(true)
            }
        }
    }
}
