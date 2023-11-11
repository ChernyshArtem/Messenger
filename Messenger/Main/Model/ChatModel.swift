//
//  ChatModel.swift
//  Messenger
//
//  Created by Артём Черныш on 5.11.23.
//

import FirebaseFirestore
import RxRelay
import MessageKit

class ChatModel {
    
    let database = Firestore.firestore()
    var userId = String()
    var userNickname = String()
    var otherId = String()
    var otherNickname = String()
    var chatId = String()
    lazy var ownSender = Sender(senderId: userId, displayName: userNickname)
    lazy var otherSender = Sender(senderId: otherId, displayName: otherNickname)
   
    var messages: BehaviorRelay<[MessageType]> = BehaviorRelay(value: [])
    var error = BehaviorRelay(value: "")
}

