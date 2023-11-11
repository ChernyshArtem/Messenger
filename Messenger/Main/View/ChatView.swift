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
    }
    
    private func setupView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
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
}

extension ChatView: MessagesDisplayDelegate, MessagesLayoutDelegate, MessagesDataSource  {
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
