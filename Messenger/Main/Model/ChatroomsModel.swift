//
//  ChatroomsModel.swift
//  Messenger
//
//  Created by Артём Черныш on 5.11.23.
//

import FirebaseFirestore
import RxRelay

class ChatroomsModel {
    
    let database = Firestore.firestore()
    var chatsInfoArray: BehaviorRelay<[ChatInfo]> = BehaviorRelay(value: [])
    var error = BehaviorRelay(value: "")
    var userId = BehaviorRelay(value: UserDefaults.standard.string(forKey: "userId"))
    var userNickname = BehaviorRelay(value: UserDefaults.standard.string(forKey: "userNickname"))
    
}
