//
//  RegistrationModel.swift
//  Messenger
//
//  Created by Артём Черныш on 3.11.23.
//
import FirebaseFirestore
import RxRelay

class RegistrationModel {
    
    let database = Firestore.firestore()
    let registrationIsSuccessful: BehaviorRelay<ResultOfRegistration> = BehaviorRelay(value: .other)
    let userEmail = BehaviorRelay(value: "")
    let userPassword = BehaviorRelay(value: "")
    let userNickname = BehaviorRelay(value: "")
    let error = BehaviorRelay(value: "")
}
