//
//  UserListCell.swift
//  SearchUser
//
//  Created by junwoo on 28/02/2019.
//  Copyright © 2019 samchon. All rights reserved.
//

import UIKit

class UserListCell: UITableViewCell {
  
  static let reuseIdentifier: String = "UserListCell"
  
  private let containerLayoutGuide = UILayoutGuide()
  private lazy var imgView: UIImageView = {
    let imgView = UIImageView()
    imgView.translatesAutoresizingMaskIntoConstraints = false
    imgView.contentMode = .scaleAspectFill
    return imgView
  }()
  private lazy var labelStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.spacing = 3
    return stackView
  }()
  private lazy var usernameLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont.boldSystemFont(ofSize: 14)
    label.textColor = UIColor.black
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
    containerLayoutGuide.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: edgeInset).isActive = true
    containerLayoutGuide.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: edgeInset).isActive = true
    containerLayoutGuide.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -edgeInset).isActive = true
    containerLayoutGuide.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -edgeInset).isActive = true
    
    imgView.widthAnchor.constraint(equalToConstant: 50).isActive = true
    imgView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    imgView.leadingAnchor.constraint(equalTo: containerLayoutGuide.leadingAnchor).isActive = true
    imgView.topAnchor.constraint(equalTo: containerLayoutGuide.topAnchor).isActive = true
    imgView.bottomAnchor.constraint(equalTo: containerLayoutGuide.bottomAnchor).isActive = true
    
    labelStackView.leadingAnchor.constraint(equalTo: imgView.trailingAnchor, constant: 5).isActive = true
    labelStackView.topAnchor.constraint(equalTo: containerLayoutGuide.topAnchor).isActive = true
    labelStackView.trailingAnchor.constraint(equalTo: containerLayoutGuide.trailingAnchor).isActive = true
    labelStackView.bottomAnchor.constraint(equalTo: containerLayoutGuide.bottomAnchor).isActive = true
  }
  
  func configure(userInfo: UserInfo) {
    addLayoutGuide(containerLayoutGuide)
    addSubview(imgView)
    addSubview(labelStackView)
    
    imgView.loadImageWithUrlString(urlString: userInfo.avatar_url)
    labelStackView.addArrangedSubview(usernameLabel)
    labelStackView.addArrangedSubview(scoreLabel)
    
    usernameLabel.text = userInfo.login
    scoreLabel.text = "score : \(userInfo.score)"
    
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
  }
}
