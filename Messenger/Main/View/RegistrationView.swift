//
//  RegistrationView.swift
//  Messenger
//
//  Created by Артём Черныш on 2.11.23.
//

import UIKit
import RxCocoa
import RxSwift

class RegistrationView: UIViewController {
    
    let infoLabel: UILabel = {
        let infoLabel = UILabel()
        infoLabel.text = "Info"
        infoLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        return infoLabel
    }()
    let nicknameTextField: UITextField = {
        let nicknameTextField = UITextField()
        nicknameTextField.placeholder = "Your nickname"
        return nicknameTextField
    }()
    let emailTextField: UITextField = {
        let emailTextField = UITextField()
        emailTextField.placeholder = "Enter your email"
        return emailTextField
    }()
    let passwordTextField: UITextField = {
        let passwordTextField = UITextField()
        passwordTextField.placeholder = "Enter your password"
        return passwordTextField
    }()
    let userImageButton: UIButton = {
        let userImageButton = UIButton(type: .system)
        return userImageButton
    }()
    let userImage: UIImageView = {
        let userImage = UIImageView()
        userImage.image = UIImage(systemName: "camera.circle.fill")
        userImage.layer.cornerRadius = 50
        userImage.clipsToBounds = true
        userImage.tintColor = .gray
        return userImage
    }()
    let registerButton: UIButton = {
        let registerButton = UIButton(type: .system)
        registerButton.setTitle("REGISTER", for: .normal)
        registerButton.backgroundColor = UIColor(red: 45/255, green: 119/255, blue: 231/255, alpha: 1)
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.layer.cornerRadius = 15
        return registerButton
    }()
    
    let bag = DisposeBag()
    let viewModel: RegistrationViewModelInterface = RegistrationViewModel()
    
    override func viewDidLoad() {
         
        setupView()
        
    }
    
    private func setupView() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        view.backgroundColor = .systemBackground
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tap)
        
        view.addSubview(infoLabel)
        view.addSubview(nicknameTextField)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(userImage)
        view.addSubview(userImageButton)
        view.addSubview(registerButton)
        
        setupSubviews()
        setupBindings()
        setupTargets()
        registerKeyboardNotifications()
    }
    
    private func setupSubviews() {
        let screenWidth = view.frame.width * 0.75
        
        infoLabel.snp.remakeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
        }
        userImage.snp.remakeConstraints { make in
            make.top.equalTo(infoLabel.snp.bottom).offset(40)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.width.height.equalTo(100)
        }
        userImageButton.snp.remakeConstraints { make in
            make.edges.equalTo(userImage)
        }
        nicknameTextField.snp.remakeConstraints { make in
            make.top.equalTo(userImage.snp.bottom).offset(40)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.width.equalTo(screenWidth)
        }
        emailTextField.snp.remakeConstraints { make in
            make.top.equalTo(nicknameTextField.snp.bottom).offset(40)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.width.equalTo(screenWidth)
        }
        passwordTextField.snp.remakeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(40)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.width.equalTo(screenWidth)
        }
        registerButton.snp.remakeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(40)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.width.equalTo(screenWidth)
        }
    }
    
    private func setupTargets() {
        registerButton.addTarget(self, action: #selector(registerNewUser), for: .touchUpInside)
        userImageButton.addTarget(self, action: #selector(uploadPhoto), for: .touchUpInside)
    }
    
    private func setupBindings() {
        viewModel.model.registrationIsSuccessful.bind { [weak self] result in
            switch result {
            case .nicknameError:
                self?.present(CustomAlert.makeCustomAlert(title: "Warning", message: "Your account hasn't been registered. This nickname is occupied"), animated: true, completion: nil)
            case .success:
                self?.present(CustomAlert.makeCustomAlert(title: "Congratuations", message: "Your account has been registered"), animated: true, completion: nil)
                
            case .other: break
            }
        }.disposed(by: bag)
        viewModel.model.error.bind { [weak self] errorDescription in
            guard errorDescription != "" else { return }
            self?.present(CustomAlert.makeCustomAlert(title: "Error", message: errorDescription), animated: true, completion: nil)
        }.disposed(by: bag)
        emailTextField.rx.text.bind { [weak self] model in
            self?.viewModel.model.userEmail.accept(model ?? "")
        }.disposed(by: bag)
        passwordTextField.rx.text.bind { [weak self] model in
            self?.viewModel.model.userPassword.accept(model ?? "")
        }.disposed(by: bag)
        nicknameTextField.rx.text.bind { [weak self] model in
            self?.viewModel.model.userNickname.accept(model ?? "")
        }.disposed(by: bag)
    }
    
    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    private func setupSubviewsForKeyboard(keyboardHeight: Double) {
        let screenWidth = view.frame.width * 0.75
        registerButton.snp.remakeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20 + keyboardHeight)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.width.equalTo(screenWidth)
        }
        passwordTextField.snp.remakeConstraints { make in
            make.bottom.equalTo(registerButton.snp.top).inset(-20)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.width.equalTo(screenWidth)
        }
        emailTextField.snp.remakeConstraints { make in
            make.bottom.equalTo(passwordTextField.snp.top).inset(-20)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.width.equalTo(screenWidth)
        }
        nicknameTextField.snp.remakeConstraints { make in
            make.bottom.equalTo(emailTextField.snp.top).inset(-20)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.width.equalTo(screenWidth)
        }
        userImage.snp.remakeConstraints { make in
            make.bottom.equalTo(nicknameTextField.snp.top).inset(-20)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.width.height.equalTo(100)
        }
        userImageButton.snp.remakeConstraints { make in
            make.edges.equalTo(userImage)
        }
        infoLabel.snp.remakeConstraints { make in
            make.bottom.equalTo(userImage.snp.top).inset(-20)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    @objc
    private func registerNewUser() {
        viewModel.registerNewUser()
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
    func keyboardWillShow(_ notification: Foundation.Notification) {
        guard let userInfo = notification.userInfo else { return }
        let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size.height
        setupSubviewsForKeyboard(keyboardHeight: keyboardHeight)
        view.layoutIfNeeded()
    }
        
    @objc
    func keyboardWillHide(_ notification: Foundation.Notification) {
        setupSubviews()
        view.layoutIfNeeded()
    }
    
    @objc
    func hideKeyboard() {
        view.endEditing(true)
    }
    
}

extension RegistrationView: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        guard let imageData = image.pngData() else { return }
        userImage.image = image
        viewModel.model.actualImageData.accept(imageData)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
}
