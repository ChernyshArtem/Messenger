//
//  ChatroomsViewModel.swift
//  Messenger
//
//  Created by Артём Черныш on 5.11.23.
//

protocol ChatroomsViewModelInterface {
    var model: ChatroomsModel { get }
    func reloadActualChats()
}

class ChatroomsViewModel: ChatroomsViewModelInterface {
    
    var model: ChatroomsModel
    
    init() { model = ChatroomsModel() }
    
    func reloadActualChats() {
        var chats: [ChatInfo] = []
        model.database.collection("user").document(model.userId.value ?? "").collection("chats").getDocuments { [weak self] (querySnapshot, error) in
            guard error == nil else {
                self?.model.error.accept(error?.localizedDescription ?? "")
                return
            }
            for document in querySnapshot!.documents {
                guard let otherUserId = document.data()["otherUser"] as? String,
                      let chatId = document.data()["id"] as? String else { return }
                self?.model.database.collection("user").document(otherUserId).getDocument { document, error in
                    guard let document,
                          document.exists,
                          let data = document.data(),
                          let otherUserNickname = data["nickname"] as? String else { return }
                    chats.append(ChatInfo(otherUserNickname: otherUserNickname, otherUserId: otherUserId, chatId: chatId))
                    self?.model.chatsInfoArray.accept(chats)
                }
            }
        }
    }
    
}
