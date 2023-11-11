//
//  SettingsModel.swift
//  Messenger
//
//  Created by Артём Черныш on 5.11.23.
//

import FirebaseFirestore
import RxRelay

class SettingsModel {
    let database = Firestore.firestore()
    let error = BehaviorRelay(value: "")
}
