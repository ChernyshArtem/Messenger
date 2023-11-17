//
//  ChatroomsViewModel.swift
//  Messenger
//
//  Created by Артём Черныш on 5.11.23.
//

import Foundation
import MessageKit
import FirebaseFirestore

protocol ChatroomsViewModelInterface {
    var model: ChatroomsModel { get }
    func reloadActualChats()
}

class ChatroomsViewModel: ChatroomsViewModelInterface {
    
    var model: ChatroomsModel
    
    init() { model = ChatroomsModel() }
    
    func reloadActualChats() {
        var chats: [ChatInfo] = []
        let database = model.database
        var documentsAreExists = false
        database.collection("user").document(model.userId.value ?? "").collection("chats").getDocuments { [weak self]
            (querySnapshot, error) in
            guard error == nil else {
                self?.model.error.accept(error?.localizedDescription ?? "")
                return
            }
            for document in querySnapshot!.documents {
                documentsAreExists = true
                guard let otherUserId = document.data()["otherUser"] as? String,
                      let chatId = document.data()["id"] as? String else { return }
                self?.model.database.collection("user").document(otherUserId).getDocument { document, error in
                    guard let document,
                          document.exists,
                          let data = document.data(),
                          let otherUserNickname = data["nickname"] as? String else { return }
                     self?.loadLastMessage(chatId: chatId, completion: { lastMessage in
                         chats.append(ChatInfo(otherUserNickname: otherUserNickname, otherUserId: otherUserId, lastMessage: lastMessage, chatId: chatId))
                         self?.model.chatsInfoArray.accept(chats)
                    })
                }
            }
            if documentsAreExists == false {
                self?.model.chatsInfoArray.accept([])
            }
        }
    }
    
    private func loadLastMessage(chatId: String, completion: @escaping (String) -> ()) {
        let database = model.database
        database.collection("chat").document(chatId).collection("messages").getDocuments { (querySnapshot, error) in
            var messages: [(String,Date)] = []
            for document in querySnapshot!.documents {
                let doc = document.data()
                guard let text = doc["text"] as? String,
                      let timestamp = doc["date"] as? Timestamp else { return }
                let date = Date(timeIntervalSince1970: TimeInterval(timestamp.seconds))
            
                messages.append((text,date))
            }
            if messages.count > 0 {
                let sorted = messages.sorted { first, second in
                    first.1 > second.1
                }
                completion(sorted[0].0)
            }
            else {
                completion(" ")
            }
        }
    }
    
}
