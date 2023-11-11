//
//  ContactsCell.swift
//  Messenger
//
//  Created by Артём Черныш on 3.11.23.
//

import UIKit
import SnapKit

class ContactsCell: UICollectionViewCell {
    
    static let identifeier = "ContactsCell"
    
    let userImage: UIImageView = {
        let userImage = UIImageView()
        userImage.image = UIImage(systemName: "camera.circle.fill")
        userImage.tintColor = .white
        return userImage
    }()
    let userNickname: UILabel = {
        let userNickname = UILabel()
        userNickname.text = "error"
        userNickname.numberOfLines = 0
        return userNickname
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(userImage)
        contentView.addSubview(userNickname)
        userImage.snp.makeConstraints { make in
            make.left.top.equalTo(contentView).offset(8)
            make.height.width.equalTo(contentView.frame.height - 16)
        }
        userNickname.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.left.equalTo(userImage.snp.right).offset(8)
            make.right.equalTo(contentView).inset(8)
            make.width.equalTo(contentView.frame.width - contentView.frame.height - 32)
        }
        contentView.backgroundColor = .gray
        contentView.layer.cornerRadius = 10
    }
    
    public func configure(userImage: UIImage, userNickname: String) {
        self.userImage.image = userImage
        self.userNickname.text = userNickname
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
