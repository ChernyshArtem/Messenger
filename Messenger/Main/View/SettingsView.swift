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
        userImage.layer.cornerRadius = 50
        userImage.clipsToBounds = true
        userImage.tintColor = .gray
        return userImage
    }()
    let userImageButton: UIButton = {
        let userImageButton = UIButton(type: .system)
        return userImageButton
    }()
    let exitButton: UIButton = {
        let exitButton = UIButton(type: .system)
        exitButton.setTitle(String(localized: "🚪 exit"), for: .normal)
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
        view.addSubview(userImageButton)
        view.addSubview(userName)
        view.addSubview(exitButton)
        setupSubviews()
        setupBindings()
        viewModel.downloadUserImage(userId: userId ?? "")
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
        userImageButton.snp.makeConstraints { make in
            make.edges.equalTo(userImageView)
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
        userImageButton.addTarget(self, action: #selector(uploadPhoto), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: String(localized: "Change"), style: .plain, target: self, action: #selector(changeNickname))
        let deleteButton = UIBarButtonItem(title: String(localized: "Delete"), style: .plain, target: self, action: #selector(deleteAccount))
        deleteButton.tintColor = .red
        navigationItem.leftBarButtonItem = deleteButton
    }
    
    private func setupBindings() {
        viewModel.model.error.bind { [weak self] errorDescription in
            guard errorDescription != "" else { return }
            self?.present(CustomAlert.makeCustomAlert(title: String(localized: "Error"), message: errorDescription), animated: true, completion: nil)
        }.disposed(by: bag)
        viewModel.model.imageData.bind { [weak self] imageData in
            if imageData != Data() {
                DispatchQueue.main.async {
                    self?.userImageView.image = UIImage(data: imageData)
                }
            }
        }.disposed(by: bag)
    }
    
    private func makeAlertWithNickname() -> UIAlertController {
        let alertWithNickname = UIAlertController(title: String(localized: "Enter your new nickname"), message: nil, preferredStyle: .alert)
        alertWithNickname.addTextField()
        let submitAction = UIAlertAction(title: String(localized: "Submit"), style: .default) { [unowned alertWithNickname] _ in
            guard let newNickname = alertWithNickname.textFields![0].text else { return }
            self.viewModel.checkFreeStatusOfNickname(newNickname) { [weak self] freeNicknameStatus in
                if freeNicknameStatus == true {
                    self?.viewModel.changeNickname(newNickname: newNickname, userId: self?.userId ?? "", userNameLabel: self?.userName ?? UILabel())
                } else {
                    self?.present(CustomAlert.makeCustomAlert(title: String(localized: "Error"), message: String(localized: "This nickname is occupied")), animated: true, completion: nil)
                }
            }
           
        }
        alertWithNickname.addAction(submitAction)
        return alertWithNickname
    }
    
    @objc
    private func uploadPhoto() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    @objc
    func changeNickname() {
        let alert = CustomAlert.makeCustomAlertWithResult(title: String(localized: "Attention"), message: String(localized: "Do you really want to change your nickname?")) { [weak self] wantToChangeNickname in
             if wantToChangeNickname == true {
                 guard let alertWithNickname = self?.makeAlertWithNickname() else { return }
                 self?.present(alertWithNickname, animated: true)
            }
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc
    func deleteAccount() {
        let alert = CustomAlert.makeCustomAlertWithResult(title: String(localized: "Warning"), message: String(localized: "Are you sure you want to delete your account?")) { [weak self] deleteAccount in
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

extension SettingsView: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        guard let imageData = image.pngData(),
              let userId = userId,
              let userNickname = userName.text else { return }
        viewModel.uploadNewUserImage(userId: userId, userNickname: userNickname, imageData: imageData)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
