//
//  ContactsView.swift
//  Messenger
//
//  Created by Артём Черныш on 3.11.23.
//

import UIKit
import RxSwift
import RxCocoa

class ContactsView: UIViewController {
    
    let searchField: UITextField = {
        let searchField = UITextField()
        searchField.placeholder = "Enter user nickname"
        return searchField
    }()
    let cancelButton: UIButton = {
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Отмена", for: .normal)
        cancelButton.setTitleColor(.systemBlue, for: .normal)
        return cancelButton
    }()
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = view.frame.width
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom : 0, right: 8)
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    let bag = DisposeBag()
    let viewModel: ContactsViewModelInterface = ContactsViewModel()
    
    override func viewDidLoad() {
        
        setupView()
        
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(searchField)
        view.addSubview(collectionView)
        view.addSubview(cancelButton)
        setupSubviews()
        setupTargets()
        setupBindings()
        registerKeyboardNotifications()
    }
    
    private func setupSubviews() {
        searchField.snp.remakeConstraints { make in
            make.left.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.right.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        collectionView.snp.remakeConstraints { make in
            make.top.equalTo(searchField.snp.bottom).offset(16)
            make.left.right.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(8)
        }
        cancelButton.snp.remakeConstraints { make in
            make.right.equalTo(view.safeAreaLayoutGuide).offset(1000)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
        }
        cancelButton.isHidden = true
    }
    
    private func setupSubviewsForKeyboard(keyboardHeight: Double) {
        searchField.snp.remakeConstraints { make in
            make.left.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.right.equalTo(cancelButton.snp.left).inset(16)
        }
        collectionView.snp.remakeConstraints { make in
            make.top.equalTo(searchField.snp.bottom).offset(16)
            make.left.right.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view).inset(8 + keyboardHeight)
        }
        cancelButton.snp.remakeConstraints { make in
            make.right.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
        }
        cancelButton.isHidden = false
    }
    
    private func setupTargets() {
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(ContactsCell.self, forCellWithReuseIdentifier: ContactsCell.identifeier)
        cancelButton.addTarget(self, action: #selector(hideKeyboard), for: .touchUpInside)
    }
    
    private func setupBindings() {
        searchField.rx.text.bind { [weak self] model in
            self?.viewModel.fillActualContacts(self?.searchField ?? UITextField())
        }.disposed(by: bag)
        viewModel.model.actualContacts.bind { [weak self] _ in
            self?.collectionView.reloadData()
        }.disposed(by: bag)
        viewModel.model.error.bind { [weak self] errorDescription in
            guard errorDescription != "" else { return }
            self?.present(CustomAlert.makeCustomAlert(title: "Error", message: errorDescription), animated: true, completion: nil)
        }.disposed(by: bag)
    }
    
    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
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

extension ContactsView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.model.actualContacts.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContactsCell.identifeier, for: indexPath) as? ContactsCell else { return UICollectionViewCell() }
        let actualContact = viewModel.model.actualContacts.value[indexPath.row]
        viewModel.findContactImage(userId: actualContact.id) { image in
            cell.configure(userImage: image, userNickname: actualContact.nickname)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ContactsCell else { return }
        let userNickname = cell.userNickname.text ?? ""
        let alert = CustomAlert.makeCustomAlertWithResult(title: "Attention", message: "Do you want to create chat with user \(userNickname)?") { [weak self] chatWillBeCreate in
            if chatWillBeCreate == true {
                self?.viewModel.addChat(numberOfUser: indexPath.row)
            }
        }
        self.present(alert, animated: true, completion: nil)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let widthForCell: Double = view.frame.width
        return CGSize(width: widthForCell - 16, height: 100)
    }
}
