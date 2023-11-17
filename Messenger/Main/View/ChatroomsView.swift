//
//  ChatroomsView.swift
//  Messenger
//
//  Created by Артём Черныш on 3.11.23.
//

import UIKit
import RxSwift
import RxCocoa

class ChatroomsView: UIViewController {
    
    var userId = UserDefaults.standard.string(forKey: "userId")
    var userNickname = UserDefaults.standard.string(forKey: "userNickname")
    let chatsTableView = UITableView(frame: .zero, style: .plain)
    
    let bag = DisposeBag()
    let viewModel: ChatroomsViewModelInterface = ChatroomsViewModel()
    
    override func viewDidLoad() {
  
        setupView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.reloadActualChats()
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.viewModel.reloadActualChats()
        }
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        view.addSubview(chatsTableView)
        setupSubviews()
        setupBindigs()
        viewModel.reloadActualChats()
    }
    
    private func setupSubviews() {
        if userId == nil || userNickname == nil {
            userId = UserDefaults.standard.string(forKey: "userId")
            viewModel.model.userId.accept(userId)
            userNickname = UserDefaults.standard.string(forKey: "userNickname")
            viewModel.model.userNickname.accept(userNickname)
        }
        chatsTableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        chatsTableView.dataSource = self
        chatsTableView.delegate = self
        chatsTableView.register(ChatCell.self, forCellReuseIdentifier: ChatCell.identifeier)
    }
    
    private func setupBindigs() {
        viewModel.model.chatsInfoArray.bind { [weak self] _ in
            self?.chatsTableView.reloadData()
        }.disposed(by: bag)
        viewModel.model.error.bind { [weak self] errorDescription in
            guard errorDescription != "" else { return }
            self?.present(CustomAlert.makeCustomAlert(title: "Error", message: errorDescription), animated: true, completion: nil)
        }.disposed(by: bag)
    }
    
}

extension ChatroomsView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.model.chatsInfoArray.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatCell.identifeier, for: indexPath) as? ChatCell else { return UITableViewCell() }
        let chatInfo = viewModel.model.chatsInfoArray.value[indexPath.row]
        cell.configure(userName: chatInfo.otherUserNickname, lastMessage: chatInfo.lastMessage)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        UIView.animate(withDuration: 0.2) {
            cell?.selectionStyle = .default
        } completion: { _ in
            cell?.selectionStyle = .none
        }
        let chat = viewModel.model.chatsInfoArray.value[indexPath.row]
        let vc = ChatView()
        let model = vc.viewModel.model
        model.chatId = chat.chatId
        model.userId = userId ?? ""
        model.userNickname = userNickname ?? ""
        model.otherId = chat.otherUserId
        model.otherNickname = chat.otherUserNickname
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }
}
