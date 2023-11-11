//
//  CustomAlert.swift
//  Messenger
//
//  Created by Артём Черныш on 3.11.23.
//

import UIKit

class CustomAlert {
    static public func makeCustomAlert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
        }))
        return alert
    }
    
    static public func makeCustomAlertWithResult(title: String, message: String, completion: @escaping (Bool) -> ()) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "First action"), style: .cancel, handler: { _ in
            completion(true)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: "Second action"), style: .default, handler: { _ in
            completion(false)
        }))
        return alert
    }
    
    static public func makeMessageChangerAlertWithResult(title: String, message: String, completion: @escaping (ResultOfChangingMessage) -> ()) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: { _ in
            completion(.edit)
        }))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            completion(.delelte)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
        }))
        return alert
    }
}
