//
//  Message.swift
//  Messenger
//
//  Created by Артём Черныш on 5.11.23.
//

import Foundation
import MessageKit

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}
