//
//  ChatCell.swift
//  Messenger
//
//  Created by Артём Черныш on 5.11.23.
//

import UIKit
import SnapKit

class ChatCell: UITableViewCell {
    static let identifeier = "ChatCell"
    
    private let userName: UILabel = {
        let label = UILabel()
        label.text = "User Name"
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    private let userImage: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName:"camera.circle.fill")
        iv.tintColor = .gray
        return iv
    }()
    
    private let lastMessage: UILabel = {
        let label = UILabel()
        label.text = "last message"
        label.numberOfLines = 2
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userName)
        contentView.addSubview(userImage)
        contentView.addSubview(lastMessage)
        userImage.snp.makeConstraints { make in
            make.top.left.equalTo(contentView).offset(20)
            make.bottom.equalTo(contentView).inset(20)
            make.width.equalTo(userImage.snp.height)
        }
        userName.snp.makeConstraints { make in
            make.left.equalTo(userImage.snp.right).offset(20)
            make.top.equalTo(contentView).offset(20)
        }
        lastMessage.snp.makeConstraints { make in
            make.left.equalTo(userImage.snp.right).offset(20)
            make.top.equalTo(userName.snp.bottom).offset(8)
            make.bottom.equalTo(contentView).inset(20)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(userName: String) {
        self.userName.text = userName
    }
}
