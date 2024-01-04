//
//  ViewController.swift
//  Messenger
//
//  Created by Артём Черныш on 31.10.23.
//

import UIKit
import SnapKit

class StartView: UIViewController {
    
    let logoImage: UIImageView = {
        let logoImage = UIImage(named: "launchIcon")
        return UIImageView(image: logoImage)
    }()
    let nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.text = String(localized: "Messenger")
        nameLabel.font = UIFont.systemFont(ofSize: 35)
        return nameLabel
    }()
    let descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.text = String(localized: "The best messenger in the world")
        descriptionLabel.font = UIFont.systemFont(ofSize: 25, weight: .thin)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        return descriptionLabel
    }()
    let startButton: UIButton = {
        let startButton = UIButton(type: .system)
        startButton.setTitle(String(localized: "Start Messanging"), for: .normal)
        startButton.titleLabel?.font = UIFont.systemFont(ofSize: 30, weight: .thin)
        startButton.setTitleColor(.white, for: .normal)
        startButton.backgroundColor = UIColor(red: 45/255, green: 119/255, blue: 231/255, alpha: 1)
        startButton.layer.cornerRadius = 25
        return startButton
    }()
    override func viewDidLoad() {
        view.backgroundColor = .systemBackground
        let logoHeight = view.frame.height / 3
        let screenWidth = view.frame.width - 32
        view.addSubview(logoImage)
        view.addSubview(nameLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(startButton)
        logoImage.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.centerX.equalTo(view.safeAreaLayoutGuide).offset(2)
            make.height.width.equalTo(logoHeight)
        }
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImage.snp.bottom).offset(16)
            make.centerX.equalTo(logoImage.snp.centerX)
        }
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(16)
            make.centerX.equalTo(logoImage.snp.centerX)
            make.width.equalTo(screenWidth)
        }
        startButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.centerX.equalTo(descriptionLabel.snp.centerX)
            make.width.equalTo(screenWidth*0.75)
        }
        startButton.addTarget(self, action: #selector(goToAuthorizationViewController), for: .touchUpInside)
    }
    
    @objc
    private func goToAuthorizationViewController() {
        navigationController?.pushViewController(AuthorizationView(), animated: true)
    }
    
}

