//
//  ContactsViewModel.swift
//  Messenger
//
//  Created by Артём Черныш on 3.11.23.
//

import UIKit
import RxSwift
import RxCocoa

protocol ContactsViewModelInterface {
    var model: ContactsModel { get }
    func fillActualContacts(_ textField: UITextField)
    func addChat(numberOfUser: Int)
    func findContactImage(userId: String, completion: @escaping (UIImage) -> ())
}

class ContactsViewModel: ContactsViewModelInterface {
    
    var model: ContactsModel
    
    init() { model = ContactsModel() }
    
    func fillActualContacts(_ textField: UITextField) {
        let searchText: String = textField.text?.lowercased() ?? ""
        let database = model.database
        var isUsed = false
        database.collection("user").getDocuments { [weak self] (querySnapshot, error) in
            guard error == nil else {
                self?.model.error.accept(error?.localizedDescription ?? "")
                return
            }
            var actualArray: [User] = []
            for document in querySnapshot!.documents {
                guard let nickname: String = document.data()["nickname"] as? String,
                      let userId: String = document.data()["id"] as? String else { return }
                if nickname.lowercased().contains(searchText) && document.documentID != self?.model.userId {
                    isUsed = true
                    self?.checkCreationOfChat(otherUserId: userId) { isCreated in
                        guard isCreated == false else { return }
                        actualArray.append(User(id: document.documentID, nickname: nickname))
                        self?.model.actualContacts.accept(actualArray)
                    }
                }
            }
            if isUsed == false {
                self?.model.actualContacts.accept(actualArray)
            }
        }
    }
    
    func addChat(numberOfUser: Int) {
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
                             "secondUser":secondUser])
            }
        }
    }
    
    func findContactImage(userId: String, completion: @escaping (UIImage) -> ()) {
        PhotoWorker.downloadPhotoFromDatabase(userId: userId) { data in
            DispatchQueue.main.async {
                guard data != Data(),
                      let image = UIImage(data: data)
                else {
                    completion(UIImage(systemName: "camera.circle.fill") ?? UIImage())
                    return
                }
                completion(image)
            }
        }
    }
    
    private func checkCreationOfChat(numberOfContact: Int, completion: @escaping (Bool) -> Void) {
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
                let firstOption = firstUser == self?.model.userId && secondUser == self?.model.actualContacts.value[numberOfContact].id
                let secondOption = firstUser == self?.model.actualContacts.value[numberOfContact].id && secondUser == self?.model.userId
                if firstOption || secondOption {
                    chatExist = true
                    break
                }
            }
            completion(chatExist)
        }
    }
    
    private func checkCreationOfChat(otherUserId: String, completion: @escaping (Bool) -> Void) {
        var chatExist: Bool = false
        let database = model.database
        database.collection("chat").getDocuments { [weak self] (querySnapshot, error) in
            guard let countOfDocs = querySnapshot?.documents.count,
                  countOfDocs > 0 else {
                completion(chatExist)
                return
            }
            database.collection("chat").getDocuments { [weak self] (querySnapshot, error) in
                guard error == nil else {
                    self?.model.error.accept(error?.localizedDescription ?? "")
                    return
                }
                for document in querySnapshot!.documents {
                    guard let firstUser = document.data()["firstUser"] as? String,
                          let secondUser = document.data()["secondUser"] as? String else { return }
                    let firstOption = firstUser == self?.model.userId && secondUser == otherUserId
                    let secondOption = firstUser == otherUserId && secondUser == self?.model.userId
                    if firstOption || secondOption {
                        chatExist = true
                        break
                    }
                }
                completion(chatExist)
            }
        }
        
    }
    
}
