//
//  SettingsView.swift
//  Messenger
//
//  Created by Артём Черныш on 3.11.23.
//

import UIKit
import RxSwift
import RxCocoa

class SettingsView: UIViewController {

    var userId = UserDefaults.standard.string(forKey: "userId")
    var userName: UILabel = {
        let userName = UILabel()
        userName.text = UserDefaults.standard.string(forKey: "userNickname")
        userName.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        userName.numberOfLines = 0
        userName.textAlignment = .center
        return userName
    }()
    let userImageView: UIImageView = {
        let userImage = UIImageView()
        userImage.image = UIImage(systemName: "camera.circle.fill")
        userImage.tintColor = .gray
        return userImage
    }()
    let exitButton: UIButton = {
        let exitButton = UIButton(type: .system)
        exitButton.setTitle("🚪 exit", for: .normal)
        exitButton.setTitleColor(.red, for: .normal)
        return exitButton
    }()
    
    let bag = DisposeBag()
    let viewModel: SettingsViewModelInterface = SettingsViewModel()
    
    override func viewDidLoad() {
    
        setupView()
        
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        view.addSubview(userImageView)
        view.addSubview(userName)
        view.addSubview(exitButton)
        setupSubviews()
        setupBindings()
    }
    
    private func setupSubviews() {
        if userId == nil || userName.text == nil {
            userId = UserDefaults.standard.string(forKey: "userId")
            userName.text = UserDefaults.standard.string(forKey: "userNickname")
        }
        userImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.width.height.equalTo(100)
        }
        userName.snp.makeConstraints { make in
            make.top.equalTo(userImageView.snp.bottom).offset(16)
            make.left.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.right.equalTo(view.safeAreaLayoutGuide).inset(8)
        }
        exitButton.snp.makeConstraints { make in
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        
        exitButton.addTarget(self, action: #selector(exitFromAccount), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Change", style: .plain, target: self, action: #selector(changeNickname))
        let deleteButton = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(deleteAccount))
        deleteButton.tintColor = .red
        navigationItem.leftBarButtonItem = deleteButton
    }
    
    private func setupBindings() {
        viewModel.model.error.bind { [weak self] errorDescription in
            guard errorDescription != "" else { return }
            self?.present(CustomAlert.makeCustomAlert(title: "Error", message: errorDescription), animated: true, completion: nil)
        }.disposed(by: bag)
    }
    
    private func makeAlertWithNickname() -> UIAlertController {
        let alertWithNickname = UIAlertController(title: "Enter your new nickname", message: nil, preferredStyle: .alert)
        alertWithNickname.addTextField()
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned alertWithNickname] _ in
            guard let newNickname = alertWithNickname.textFields![0].text else { return }
            self.viewModel.checkFreeStatusOfNickname(newNickname) { [weak self] freeNicknameStatus in
                if freeNicknameStatus == true {
                    self?.viewModel.changeNickname(newNickname: newNickname, userId: self?.userId ?? "", userNameLabel: self?.userName ?? UILabel())
                } else {
                    self?.present(CustomAlert.makeCustomAlert(title: "Error", message: "This nickname is occupied"), animated: true, completion: nil)
                }
            }
           
        }
        alertWithNickname.addAction(submitAction)
        return alertWithNickname
    }
    
    @objc
    func changeNickname() {
        let alert = CustomAlert.makeCustomAlertWithResult(title: "Attention", message: "Do you really want to change your nickname?") { [weak self] wantToChangeNickname in
             if wantToChangeNickname == true {
                 guard let alertWithNickname = self?.makeAlertWithNickname() else { return }
                 self?.present(alertWithNickname, animated: true)
            }
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc
    func deleteAccount() {
        let alert = CustomAlert.makeCustomAlertWithResult(title: "Warning", message: "Are you sure you want to delete your account?") { [weak self] deleteAccount in
            if deleteAccount == true {
                self?.viewModel.deleteAccount(userId: self?.userId ?? "", completion: {
                    self?.view.window?.rootViewController = UINavigationController(rootViewController: StartView())
                })
            }
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc
    func exitFromAccount() {
        UserDefaults.standard.set(nil, forKey: "userNickname")
        UserDefaults.standard.set(nil, forKey: "userId")
        self.view.window?.rootViewController = UINavigationController(rootViewController: StartView())
    }

}
