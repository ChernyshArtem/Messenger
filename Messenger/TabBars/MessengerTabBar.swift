//
//  MessengerTabBar.swift
//  Messenger
//
//  Created by Артём Черныш on 2.11.23.
//

import UIKit

class MessengerTabBar: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarItems()
        tabBar.barStyle = .default
        self.selectedIndex = 1
    }
    private func setupTabBarItems() {
        let contactsVC = createVC(nameVC: ContactsView(), title: "Contacts", image: UIImage(systemName: "person.crop.circle.fill"))
        let chatVC = createVC(nameVC: ChatroomsView(), title: "Chats", image: UIImage(systemName: "message"))
        let settingsVC = createVC(nameVC: SettingsView(), title: "Settings", image: UIImage(systemName: "gear"))
   
        setViewControllers([contactsVC,chatVC,settingsVC], animated: true)
    }
    private func createVC(nameVC: UIViewController, title: String, image: UIImage?) -> UINavigationController {
        let vc = UINavigationController(rootViewController: nameVC)
        vc.tabBarItem.title = title
        vc.tabBarItem.image = image
        vc.viewControllers.first?.navigationItem.title = title
        return vc
    }
}
