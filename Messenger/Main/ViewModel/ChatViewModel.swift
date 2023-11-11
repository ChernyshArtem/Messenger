//
//  ChatViewModel.swift
//  Messenger
//
//  Created by Артём Черныш on 5.11.23.
//

import MessageKit
import FirebaseFirestore
import InputBarAccessoryView

protocol ChatViewModelInterface {
    var model: ChatModel { get }
    func isMessagesAreNeedToLoad()
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String)
    func editMessage(messageText: String, data: MessageType, newMessageText: String) 
    func deleteMessage(messageText: String, data: MessageType)
}

class ChatViewModel: ChatViewModelInterface {
    
    var model: ChatModel
    
    init() { model = ChatModel() }
    
    func isMessagesAreNeedToLoad() {
        model.database.collection("chat").document(model.chatId).collection("messages").getDocuments(completion: { [weak self] (querySnapshot, error) in
            guard error == nil else {
                self?.model.error.accept(error?.localizedDescription ?? "")
                return
            }
            guard let messages = self?.model.messages.value else { return }
            if querySnapshot?.documents.count ?? 0 != self?.model.messages.value.count ?? 0 {
                self?.loadMessages()
            } else {
                for (index, document) in querySnapshot!.documents.enumerated() {
                    let doc = document.data()
                    guard let databaseText = doc["text"] as? String else { return }
                    switch messages[index].kind {
                    case .text(let messageText):
                        if messageText != databaseText {
                            self?.loadMessages()
                        }
                    default:
                        break
                    }
                }
            }
        })
    }
    
    func loadMessages() {
        model.database.collection("chat").document(model.chatId).collection("messages").getDocuments() { [weak self] (querySnapshot, error) in
            guard error == nil else {
                self?.model.error.accept(error?.localizedDescription ?? "")
                return
            }
            self?.model.messages.accept([])
            for document in querySnapshot!.documents {
                let doc = document.data()
                guard let ownSender = self?.model.ownSender,
                      let otherSender = self?.model.otherSender,
                      let text = doc["text"] as? String,
                      let timestamp = doc["date"] as? Timestamp,
                      var messages = self?.model.messages.value else { return }
                let date = Date(timeIntervalSince1970: TimeInterval(timestamp.seconds))
                
                if doc["sender"] as? String == ownSender.senderId {
                    messages.append(Message(sender: ownSender, messageId: "\(messages.count + 1)", sentDate: date, kind: .text(text)))
                    self?.model.messages.accept(messages)
                } else {
                    messages.append(Message(sender: otherSender, messageId: "\(messages.count + 1)", sentDate: date, kind: .text(text)))
                    self?.model.messages.accept(messages)
                }
            }
            self?.loadFirstMessages()
        }
    }
    
    func loadFirstMessages() {
        var messages = model.messages.value
        messages.sort { messageOne, messageTwo in
            messageOne.sentDate < messageTwo.sentDate
        }
        model.messages.accept(messages)
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let dateOfSending = Date()
        inputBar.inputTextView.text = nil
        DispatchQueue.global().async { [weak self] in
            guard let database = self?.model.database,
                  let ownSender = self?.model.ownSender,
                  let chatId = self?.model.chatId else { return }
            database.collection("chat").document(chatId).collection("messages").addDocument(data: ["text":text,
                "chatId": chatId,
                "sender": ownSender.senderId,
                "date" : dateOfSending])
        }
        var messages = model.messages.value
        messages.append(Message(sender: model.ownSender, messageId: "\(messages.count + 1)", sentDate: dateOfSending, kind: .text(text)))
        model.messages.accept(messages)
        loadFirstMessages()
    }
    
    func editMessage(messageText: String, data: MessageType, newMessageText: String) {
        findMessageId(messageText: messageText, data: data) { [weak self] doucmentIdForUpdate in
            guard let chatId = self?.model.chatId else { return }
            self?.model.database.collection("chat").document(chatId).collection("messages").document(doucmentIdForUpdate).updateData(["text": newMessageText]) { [weak self] error in
                self?.loadMessages()
            }
        }
    }
    
    func deleteMessage(messageText: String, data: MessageType) {
        findMessageId(messageText: messageText, data: data) { [weak self] doucmentIdForUpdate in
            guard let chatId = self?.model.chatId else { return }
            self?.model.database.collection("chat").document(chatId).collection("messages").document(doucmentIdForUpdate).delete(completion: { [weak self] error in
                self?.loadMessages()
            })
        }
    }
    
    private func findMessageId(messageText: String, data: MessageType, completion: @escaping (String) -> ()) {
        var doucmentIdForResult = ""
        model.database.collection("chat").document(model.chatId).collection("messages").getDocuments { [weak self] (querySnapshot, error) in
            guard error == nil else {
                self?.model.error.accept(error?.localizedDescription ?? "")
                return
            }
            for document in querySnapshot!.documents {
                let documentId: String = document.documentID
                let doc = document.data()
                
                guard let databaseText = doc["text"] as? String,
                      let timestamp = doc["date"] as? Timestamp,
                      let sender = doc["sender"] as? String else { return }
                let date = Date(timeIntervalSince1970: TimeInterval(timestamp.seconds))
                if databaseText == messageText && sender == data.sender.senderId && date == data.sentDate {
                    doucmentIdForResult = documentId
                }
            }
            completion(doucmentIdForResult)
        }
    }
}
