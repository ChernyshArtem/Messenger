//
//  ContactsModel.swift
//  Messenger
//
//  Created by Артём Черныш on 3.11.23.
//

import FirebaseFirestore
import RxRelay

class ContactsModel {
    
    let database = Firestore.firestore()
    var error = BehaviorRelay(value: "")
    let userId: String = UserDefaults.standard.string(forKey: "userId") ?? ""
    var actualContacts: BehaviorRelay<[User]> = BehaviorRelay(value: [])
    
}
