//
//  UserListCell.swift
//  SearchUser
//
//  Created by junwoo on 28/02/2019.
//  Copyright © 2019 samchon. All rights reserved.
//

import UIKit

protocol UserListCellDelegate: class {
  func requestOrgUrls(username: String, indexPath: IndexPath)
}

class UserListCell: UITableViewCell {
  static let reuseIdentifier: String = "UserListCell"
  private var indexPath: IndexPath?
  private var orgImgViews = [UIImageView]()
  weak var delegate: UserListCellDelegate?
  
  private lazy var outerStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.spacing = 3
    stackView.distribution = .fillProportionally
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
    stackView.distribution = .fillProportionally
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
  
  private func configureOrgImgViews(orgImgUrls: [String]) {
    
    orgImgUrls.forEach { urlString in
      let orgImgView = UIImageView()
      orgImgView.widthAnchor.constraint(equalToConstant: 40).isActive = true
      orgImgView.heightAnchor.constraint(equalToConstant: 40).isActive = true
      orgImgView.contentMode = .scaleAspectFit
      orgImgView.layer.borderWidth = 0.5
      orgImgView.layer.borderColor = UIColor.lightGray.cgColor
      orgImgView.layer.cornerRadius = 20
      orgImgView.loadImageWithUrlString(urlString: urlString)
      orgImgViews.append(orgImgView)
    }
    
    orgImgViews.forEach {
      bottomView.addSubview($0)
    }
    
    var lastImgView: UIImageView?
    for i in 0..<orgImgViews.count {
      let orgImgView = orgImgViews[i]
      if i == 0 {
        orgImgView.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor).isActive = true
        orgImgView.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor).isActive = true
      } else {
        if let last = lastImgView {
          orgImgView.leadingAnchor.constraint(equalTo: last.trailingAnchor, constant: 5).isActive = true
          orgImgView.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor).isActive = true
        }
      }
      lastImgView = orgImgView
    }
  }
  
  func configure(userInfo: UserInfo, indexPath: IndexPath) {
    selectionStyle = .none
    self.indexPath = indexPath
    imgView.loadImageWithUrlString(urlString: userInfo.avatar_url)
    usernameLabel.text = userInfo.login
    scoreLabel.text = "score : \(userInfo.score)"
    
    addSubview(outerStackView)
    outerStackView.addArrangedSubview(topView)
    outerStackView.addArrangedSubview(bottomView)
    topView.addSubview(imgView)
    topView.addSubview(labelStackView)
    labelStackView.addArrangedSubview(usernameLabel)
    labelStackView.addArrangedSubview(scoreLabel)
    
    let edgeInset: CGFloat = 25
    outerStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: edgeInset).isActive = true
    outerStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: edgeInset).isActive = true
    outerStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -edgeInset).isActive = true
    outerStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -edgeInset).isActive = true
    
    imgView.widthAnchor.constraint(equalToConstant: 50).isActive = true
    imgView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    imgView.leadingAnchor.constraint(equalTo: topView.leadingAnchor).isActive = true
    imgView.topAnchor.constraint(equalTo: topView.topAnchor).isActive = true
    imgView.bottomAnchor.constraint(equalTo: topView.bottomAnchor).isActive = true
    
    labelStackView.leadingAnchor.constraint(equalTo: imgView.trailingAnchor, constant: 5).isActive = true
    labelStackView.topAnchor.constraint(equalTo: topView.topAnchor).isActive = true
    labelStackView.trailingAnchor.constraint(equalTo: topView.trailingAnchor).isActive = true
    labelStackView.bottomAnchor.constraint(equalTo: topView.bottomAnchor).isActive = true
    
    let orgUrls = userInfo.org_urls
    if orgUrls.count != 0 {
      self.configureOrgImgViews(orgImgUrls: orgUrls)
    }
    addTapGesture()
  }
  
  private func addTapGesture() {
    let tap = UITapGestureRecognizer(target: self, action: #selector(imgViewOrUsernameTapped(recognizer:)))
    imgView.addGestureRecognizer(tap)
    usernameLabel.addGestureRecognizer(tap)
  }
  
  func toggleBottomView() {
    bottomView.isHidden = !bottomView.isHidden
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    usernameLabel.text = nil
    imgView.image = nil
    scoreLabel.text = nil
    orgImgViews.removeAll()
  }
  
  @objc func imgViewOrUsernameTapped(recognizer: UITapGestureRecognizer) {
    guard let indexPath = self.indexPath else { return }
    guard let username = self.usernameLabel.text else { return }
    delegate?.requestOrgUrls(username: username, indexPath: indexPath)
  }
}
