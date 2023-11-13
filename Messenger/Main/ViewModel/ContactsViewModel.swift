//
//  ContactsViewModel.swift
//  Messenger
//
//  Created by Артём Черныш on 3.11.23.
//

import Foundation
import UIKit

protocol ContactsViewModelInterface {
    var model: ContactsModel { get }
    func fillActualContacts(_ textField: UITextField)
    func addChat(numberOfUser: Int, completion: @escaping () -> ())
}

class ContactsViewModel: ContactsViewModelInterface {
    var model: ContactsModel
    
    init() { model = ContactsModel() }
    
    func fillActualContacts(_ textField: UITextField) {
        let searchText: String = textField.text?.lowercased() ?? ""
        let database = model.database
        database.collection("user").getDocuments { [weak self] (querySnapshot, error) in
            guard error == nil else {
                self?.model.error.accept(error?.localizedDescription ?? "")
                return
            }
            var actualArray: [User] = []
            for document in querySnapshot!.documents {
                guard let nickname: String = document.data()["nickname"] as? String else { return }
                if nickname.lowercased().contains(searchText) && document.documentID != self?.model.userId {
                    actualArray.append(User(id: document.documentID, nickname: nickname))
                }
            }
            self?.model.actualContacts.accept(actualArray)
        }
    }
    
    func addChat(numberOfUser: Int, completion: @escaping () -> ()) {
        checkCreationOfChat(numberOfContact: numberOfUser) { [weak self] result in
            guard result == false,
                  let userId = self?.model.userId,
                  let actualContacts = self?.model.actualContacts.value else { return }
            
            let doc = self?.model.database.collection("chat").addDocument(data:
                    ["firstUser": userId,
                    "secondUser" : actualContacts[numberOfUser].id])
            
            self?.model.database.collection("chat").document(doc?.documentID ?? "" ).getDocument { [weak self] document, error in
                guard error == nil else {
                    self?.model.error.accept(error?.localizedDescription ?? "")
                    return
                }
                
                guard let document,
                      document.exists,
                      let data = document.data(),
                      let firstUser = data["firstUser"] as? String,
                      let secondUser = data["secondUser"] as? String else { return }
                
                self?.model.database.collection("user").document(firstUser).collection("chats").document(document.documentID).setData(["id":document.documentID,
                              "otherUser": secondUser])
                self?.model.database.collection("user").document(secondUser).collection("chats").document(document.documentID).setData(["id":document.documentID,
                              "otherUser": firstUser])
                self?.model.database.collection("chat").document(document.documentID)
                    .setData(["id":document.documentID,
                             "firstUser":firstUser,
                             "secondUser":secondUser],
                completion: { error in
                    completion()
                })
                
            }
        }
    }
    
    func checkCreationOfChat(numberOfContact: Int, completion: @escaping (Bool) -> Void) {
        var chatExist: Bool = false
        let database = model.database
        database.collection("chat").getDocuments { [weak self] (querySnapshot, error) in
            guard error == nil else {
                self?.model.error.accept(error?.localizedDescription ?? "")
                return
            }
            for document in querySnapshot!.documents {
                guard let firstUser = document.data()["firstUser"] as? String,
                      let secondUser = document.data()["secondUser"] as? String else { return }
                if firstUser == self?.model.userId && secondUser == self?.model.actualContacts.value[numberOfContact].id {
                    chatExist = true
                    break
                }
            }
            completion(chatExist)
        }
    }
    
}
