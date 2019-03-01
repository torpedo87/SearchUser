//
//  UserListCell.swift
//  SearchUser
//
//  Created by junwoo on 28/02/2019.
//  Copyright © 2019 samchon. All rights reserved.
//

import UIKit

protocol UserListCellDelegate: class {
  func requestOrgUrls(cell: UserListCell, username: String)
}

class UserListCell: UITableViewCell {
  static let reuseIdentifier: String = "UserListCell"
  private var orgImgViews = [UIImageView]()
  weak var delegate: UserListCellDelegate?
  var orgImgUrls: [String] = []
  private lazy var outerStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.spacing = 3
    stackView.distribution = .fill
    return stackView
  }()
  private lazy var topView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  private lazy var bottomView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .green
    view.isHidden = true
    return view
  }()
  private lazy var imgView: UIImageView = {
    let imgView = UIImageView()
    imgView.translatesAutoresizingMaskIntoConstraints = false
    imgView.isUserInteractionEnabled = true
    imgView.contentMode = .scaleAspectFill
    return imgView
  }()
  private lazy var labelStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.spacing = 3
    stackView.distribution = .fill
    return stackView
  }()
  private lazy var usernameLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont.boldSystemFont(ofSize: 14)
    label.textColor = UIColor.black
    label.isUserInteractionEnabled = true
    return label
  }()
  private lazy var scoreLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont.systemFont(ofSize: 12)
    label.textColor = UIColor.gray
    return label
  }()
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    let edgeInset: CGFloat = 25
    outerStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: edgeInset).isActive = true
    outerStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: edgeInset).isActive = true
    outerStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -edgeInset).isActive = true
    outerStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -edgeInset).isActive = true
    
    topView.topAnchor.constraint(equalTo: outerStackView.topAnchor).isActive = true
    topView.leadingAnchor.constraint(equalTo: outerStackView.leadingAnchor).isActive = true
    topView.trailingAnchor.constraint(equalTo: outerStackView.trailingAnchor).isActive = true
    topView.bottomAnchor.constraint(equalTo: bottomView.topAnchor).isActive = true
    
    bottomView.leadingAnchor.constraint(equalTo: outerStackView.leadingAnchor).isActive = true
    bottomView.trailingAnchor.constraint(equalTo: outerStackView.trailingAnchor).isActive = true
    bottomView.bottomAnchor.constraint(equalTo: outerStackView.bottomAnchor).isActive = true
    
    imgView.widthAnchor.constraint(equalToConstant: 50).isActive = true
    imgView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    imgView.leadingAnchor.constraint(equalTo: topView.leadingAnchor).isActive = true
    imgView.topAnchor.constraint(equalTo: topView.topAnchor).isActive = true
    imgView.bottomAnchor.constraint(equalTo: topView.bottomAnchor).isActive = true
    
    labelStackView.leadingAnchor.constraint(equalTo: imgView.trailingAnchor, constant: 5).isActive = true
    labelStackView.topAnchor.constraint(equalTo: topView.topAnchor).isActive = true
    labelStackView.trailingAnchor.constraint(equalTo: topView.trailingAnchor).isActive = true
    labelStackView.bottomAnchor.constraint(equalTo: topView.bottomAnchor).isActive = true
  }
  
  func configureOrgImgViews(orgImgUrls: [String]) {
    orgImgUrls.forEach { urlString in
      let orgImgView = UIImageView()
      orgImgView.loadImageWithUrlString(urlString: urlString)
      orgImgViews.append(orgImgView)
    }
    
    orgImgViews.forEach {
      bottomView.addSubview($0)
    }
    
    var lastImgView: UIImageView?
    for i in 0..<orgImgViews.count {
      let orgImgView = orgImgViews[i]
      orgImgView.widthAnchor.constraint(equalToConstant: 40).isActive = true
      orgImgView.heightAnchor.constraint(equalToConstant: 40).isActive = true
      orgImgView.layer.borderWidth = 0.5
      orgImgView.layer.borderColor = UIColor.lightGray.cgColor
      orgImgView.layer.cornerRadius = 20
      
      if i == 0 {
        orgImgView.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor).isActive = true
        orgImgView.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor).isActive = true
      } else {
        if let last = lastImgView {
          orgImgView.leadingAnchor.constraint(equalTo: last.trailingAnchor, constant: 5).isActive = true
          orgImgView.centerYAnchor.constraint(equalTo: last.centerYAnchor).isActive = true
        }
      }
      lastImgView = orgImgView
    }
  }
  
  func updateOrgImgViews(imgUrls: [String]) {
    self.orgImgUrls = imgUrls
    configureOrgImgViews(orgImgUrls: orgImgUrls)
    DispatchQueue.main.async {
      self.layoutIfNeeded()
      self.bottomView.isHidden = !self.bottomView.isHidden
    }
    
  }
  
  func configure(userInfo: UserInfo) {
    selectionStyle = .none
    addSubview(outerStackView)
    outerStackView.addArrangedSubview(topView)
    outerStackView.addArrangedSubview(bottomView)
    topView.addSubview(imgView)
    topView.addSubview(labelStackView)
    labelStackView.addArrangedSubview(usernameLabel)
    labelStackView.addArrangedSubview(scoreLabel)
    
    imgView.loadImageWithUrlString(urlString: userInfo.avatar_url)
    usernameLabel.text = userInfo.login
    scoreLabel.text = "score : \(userInfo.score)"
    
    addTapGesture()
    
    self.layoutIfNeeded()
  }
  
  private func addTapGesture() {
    let tap = UITapGestureRecognizer(target: self, action: #selector(imgViewOrUsernameTapped(recognizer:)))
    imgView.addGestureRecognizer(tap)
    usernameLabel.addGestureRecognizer(tap)
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    usernameLabel.text = nil
    imgView.image = nil
    scoreLabel.text = nil
    orgImgViews.removeAll()
  }
  
  @objc func imgViewOrUsernameTapped(recognizer: UITapGestureRecognizer) {
    delegate?.requestOrgUrls(cell: self, username: usernameLabel.text ?? "")
  }
}
