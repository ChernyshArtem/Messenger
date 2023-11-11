//
//  AuthorizationViewModel.swift
//  Messenger
//
//  Created by Артём Черныш on 2.11.23.
//

import FirebaseFirestore
import RxRelay

class AuthorizationModel {
    
    let database = Firestore.firestore()
    let authorizationIsSuccessful = BehaviorRelay(value: false)
    let userEmail = BehaviorRelay(value: "")
    let userPassword = BehaviorRelay(value: "")
    let error = BehaviorRelay(value: "")
    
}
