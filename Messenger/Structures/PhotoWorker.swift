//
//  PhotoWorker.swift
//  Messenger
//
//  Created by Артём Черныш on 16.11.23.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

class PhotoWorker {
    
    static let storage = Storage.storage().reference()
    
    static public func uploadPhotoToDatabase(userId: String, imageData: Data, completion: @escaping (String) -> ()) {
        
        storage.child("images/\(userId).png").putData(imageData, metadata: nil) { result, error in
            guard error == nil else {
                print("Failed to upload")
                return
            }
            storage.child("images/\(userId).png").downloadURL(completion: { url, error in
                guard let url, error == nil else {
                    print("Failed to download URL")
                    return
                }
                let urlString = url.absoluteString
                completion(urlString)
            })
        }
    }
    
    static public func downloadPhotoFromDatabase(userId: String, completion: @escaping (Data) -> ()) {
        Firestore.firestore().collection("user").document(userId).getDocument { document, error in
            guard let document,
                  document.exists,
                  let data = document.data(),
                  let urlString = data["imageURL"] as? String,
                  let imageURL = URL(string: urlString)  
            else {
                completion(Data())
                return
            }
            URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
                guard let data else {
                    return
                }
                completion(data)
            }.resume()
        }
    }
    
    static public func deletePhotoFromDatabase(userId: String) {
        storage.child("images/\(userId).png").delete { _ in
        }
    }
    
}
