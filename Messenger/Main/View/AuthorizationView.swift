//
//  AuthorizationView.swift
//  Messenger
//
//  Created by Артём Черныш on 2.11.23.
//

import UIKit
import RxCocoa
import RxSwift

class AuthorizationView: UIViewController {
    
    let emailTextField: UITextField = {
        let emailTextField = UITextField()
        emailTextField.placeholder = "Your email"
        return emailTextField
    }()
    let passwordTextField: UITextField = {
        let passwordTextField = UITextField()
        passwordTextField.placeholder = "Your password"
        passwordTextField.isSecureTextEntry = true
        return passwordTextField
    }()
    let loginButton: UIButton = {
        let loginButton = UIButton(type: .system)
        loginButton.setTitle("LOGIN", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.backgroundColor = UIColor(red: 45/255, green: 119/255, blue: 231/255, alpha: 1)
        loginButton.layer.cornerRadius = 15
        return loginButton
    }()
    let registrationButton: UIButton = {
        let registrationButton = UIButton()
        let text = "Not registered? Click here"
        let attributedText = NSMutableAttributedString(string: text)
        let textRange = NSRange(location: 0, length: text.count)
        attributedText.addAttribute(.underlineStyle,
                                    value: NSUnderlineStyle.single.rawValue,
                                    range: textRange)
        registrationButton.setAttributedTitle(attributedText, for: .normal)
        registrationButton.setTitleColor(.black, for: .normal)
        registrationButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        registrationButton.backgroundColor = .systemBackground
        return registrationButton
    }()
    let secureEyeButton: UIButton = {
        let secureEyeButton = UIButton(type: .system)
        let image = UIImage(systemName: "eye")
        secureEyeButton.tintColor = .black
        secureEyeButton.setBackgroundImage(image, for: .normal)
        return secureEyeButton
    }()
    
    let bag = DisposeBag()
    let viewModel: AuthorizationViewModelInterface = AuthorizationViewModel()
    
    override func viewDidLoad() {
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tap)
        
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        view.addSubview(registrationButton)
        view.addSubview(secureEyeButton)
        
        setupSubviews()
        setupBindings()
        setupTargets()
    }
    
    private func setupSubviews() {
        let thirdPartOfScreenHeight = view.frame.height / 3
        let screenWidth = view.frame.width * 0.75
        
        emailTextField.snp.remakeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(thirdPartOfScreenHeight)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.width.equalTo(screenWidth)
        }
        passwordTextField.snp.remakeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(40)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.width.equalTo(screenWidth)
        }
        secureEyeButton.snp.remakeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(40)
            make.left.equalTo(passwordTextField.snp.right).offset(8)
        }
        loginButton.snp.remakeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(40)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.width.equalTo(screenWidth)
        }
        registrationButton.snp.remakeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(8)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.width.equalTo(screenWidth)
        }
    }
    
    private func setupBindings() {
        viewModel.model.authorizationIsSuccessful.bind { [weak self] result in
            if result == true {
                self?.view.window?.rootViewController = MessengerTabBar()
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
    }
    
    private func setupTargets() {
        secureEyeButton.addTarget(self, action: #selector(changeStatusOfSecureEye), for: .touchUpInside)
        registrationButton.addTarget(self, action: #selector(goToRegistrationViewController), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginUser), for: .touchUpInside)
    }
    
    @objc func changeStatusOfSecureEye() {
        if secureEyeButton.currentBackgroundImage == UIImage(systemName: "eye.slash") {
            secureEyeButton.setBackgroundImage(UIImage(systemName: "eye"), for: .normal)
            passwordTextField.isSecureTextEntry = true
        } else {
            secureEyeButton.setBackgroundImage(UIImage(systemName: "eye.slash"), for: .normal)
            passwordTextField.isSecureTextEntry = false
        }
    }
    
    @objc private func goToRegistrationViewController() {
        navigationController?.pushViewController(RegistrationView(), animated: true)
    }
    
    @objc private func loginUser() {
        viewModel.loginUser()
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
}
