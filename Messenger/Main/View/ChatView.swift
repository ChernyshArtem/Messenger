//
//  ChatView.swift
//  Messenger
//
//  Created by Артём Черныш on 5.11.23.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import RxSwift
import RxCocoa

class ChatView: MessagesViewController {
    
    private let formatter: DateFormatter = {
      let formatter = DateFormatter()
      formatter.dateStyle = .medium
      return formatter
    }()
    
    let bag = DisposeBag()
    let viewModel: ChatViewModelInterface = ChatViewModel()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
        setRefreshedTabBar()
    }
    
    private func setRefreshedTabBar() {
        guard let window = self.view.window else { return }
        
        window.rootViewController = MessengerTabBar()
        window.makeKeyAndVisible()
        UIView.transition(with: window,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: nil)
    }
    
    private func setupView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        navigationItem.title = viewModel.model.otherNickname
        let deleteButton = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(deleteChat))
        deleteButton.tintColor = .red
        navigationItem.rightBarButtonItem = deleteButton
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.viewModel.checkIsChatAreNotDeleted(notExist: {
                self?.navigationController?.popViewController(animated: true)
            })
            self?.viewModel.isMessagesAreNeedToLoad()
        }
        setupBindings()
    }
    
    private func setupBindings() {
        viewModel.model.error.bind { [weak self] errorDescription in
            guard errorDescription != "" else { return }
            let alert = CustomAlert.makeCustomAlert(title: "Error", message: errorDescription)
            self?.present(alert, animated: true, completion: nil)
        }.disposed(by: bag)
        viewModel.model.messages.bind { [weak self] model in
            DispatchQueue.main.async {
                self?.messagesCollectionView.reloadData()
                //MARK: скролл вниз фиг знает как сделать на 1 раз а не при каждом шаге messagesCollectionView.scrollToLastItem(animated: false)
            }
        }.disposed(by: bag)
    }
    
    @objc
    private func deleteChat() {
        let alert = CustomAlert.makeCustomAlertWithResult(title: "Warning", message: "Are you sure that you want to delete this chat?") { [weak self] deleteChat in
            if deleteChat == true {
                self?.viewModel.deleteChat { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
        self.present(alert, animated: true, completion: nil)
    }
}

extension ChatView: MessagesLayoutDelegate, MessagesDataSource  {
    var currentSender: MessageKit.SenderType {
        return viewModel.model.ownSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return viewModel.model.messages.value[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return viewModel.model.messages.value.count
    }
}

extension ChatView: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        viewModel.inputBar(inputBar, didPressSendButtonWith: text)
    }
}

extension ChatView: MessageCellDelegate {
    func didTapMessage(in cell: MessageCollectionViewCell) {
        let arrayOfMessages = viewModel.model.messages.value
        let ownSender = viewModel.model.ownSender
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
              arrayOfMessages[indexPath.section].sender.senderId == ownSender.senderId else { return }
        
        switch arrayOfMessages[indexPath.section].kind {
        case .text(let messageText):
           changeTextMessage(messageText: messageText, data: arrayOfMessages[indexPath.section])
        default:
             break
        }
    }
    
    private func changeTextMessage(messageText: String, data: MessageType) {
        let alert = CustomAlert.makeMessageChangerAlertWithResult(title: "Select what you want to do with:", message: messageText) { [weak self] result in
            switch result {
            case .edit:
                self?.present(self?.makeAlertWithNickname(messageText: messageText, data: data) ?? UIAlertController(), animated: true, completion: nil)
            case .delelte:
                self?.viewModel.deleteMessage(messageText: messageText, data: data)
            }
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    private func makeAlertWithNickname(messageText: String, data: MessageType) -> UIAlertController {
        let alertWithNickname = UIAlertController(title: "Enter new message text", message: nil, preferredStyle: .alert)
        alertWithNickname.addTextField()
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned alertWithNickname] _ in
            guard let newText = alertWithNickname.textFields![0].text else { return }
            self.viewModel.editMessage(messageText: messageText, data: data, newMessageText: newText)
        }
        alertWithNickname.addAction(submitAction)
        return alertWithNickname
    }
}

extension ChatView: MessagesDisplayDelegate {
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
      if indexPath.section % 3 == 0 {
        return NSAttributedString(
            string: MessageKitDateFormatter.shared.string(from: message.sentDate),
          attributes: [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
            NSAttributedString.Key.foregroundColor: UIColor.darkGray,
          ])
      }
      return nil
    }
    
    func cellBottomLabelAttributedText(for _: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let messages = viewModel.model.messages.value
        let ownSender = viewModel.model.ownSender
        let otherSender = viewModel.model.otherSender
        var name = ""
        if messages[indexPath.section].sender.senderId == ownSender.senderId {
            name = "Me"
        } else {
            name = otherSender.displayName
        }
        
        return  NSAttributedString(
            string: name,
            attributes: [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
                NSAttributedString.Key.foregroundColor: UIColor.darkGray,
            ])
    }
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        20
    }
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        20
    }
    
}
