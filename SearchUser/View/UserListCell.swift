//
//  UserListCell.swift
//  SearchUser
//
//  Created by junwoo on 28/02/2019.
//  Copyright © 2019 samchon. All rights reserved.
//

import UIKit
import RxSwift

protocol UserListCellDelegate: class {
  func requestOrgUrls(username: String, index: Int)
  func requestUpdateTableView()
}

class UserListCell: UITableViewCell {
  var isFetched = false
  var isExpanded = false
  private let bag = DisposeBag()
  static let reuseIdentifier: String = "UserListCell"
  private var row: Int?
  private var orgImgViews = [UIImageView]()
  weak var delegate: UserListCellDelegate?
  
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
  var org_Urls = PublishSubject<[String]>()
  private lazy var bottomViewHeightConstraint: NSLayoutConstraint = {
    let heightConstraint = NSLayoutConstraint(
      item: bottomView,
      attribute: .height,
      relatedBy: .equal,
      toItem: nil,
      attribute: .height,
      multiplier: 1.0,
      constant: 40)
    heightConstraint.priority = UILayoutPriority(rawValue: 1000)
    return heightConstraint
  }()
  
  func configure(userInfo: UserInfo, index: Int) {
    selectionStyle = .none
    self.row = index
    imgView.loadImageWithUrlString(urlString: userInfo.avatar_url)
    usernameLabel.text = userInfo.login
    scoreLabel.text = "score : \(userInfo.score)"
    
    setupView()
    addTapGesture()
    bind()
  }
  
  private func bind() {
    
    org_Urls
      .asDriver(onErrorJustReturn: [])
      .do(onNext: { _ in
        self.isFetched = true
      })
      .drive(onNext: { [unowned self] urls in
        self.setupOrgImgViews(orgImgUrls: urls)
        self.delegate?.requestUpdateTableView()
      })
      .disposed(by: bag)
    
  }
  
  private func setupView() {
    addSubview(outerStackView)
    outerStackView.addArrangedSubview(topView)
    outerStackView.addArrangedSubview(bottomView)
    topView.addSubview(imgView)
    topView.addSubview(labelStackView)
    labelStackView.addArrangedSubview(usernameLabel)
    labelStackView.addArrangedSubview(scoreLabel)
    
    let edgeInset: CGFloat = 25
    NSLayoutConstraint.activate([
      outerStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor,
                                          constant: edgeInset),
      outerStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor,
                                              constant: edgeInset),
      outerStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor,
                                               constant: -edgeInset),
      outerStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor,
                                             constant: -edgeInset),
      imgView.widthAnchor.constraint(equalToConstant: 50),
      imgView.heightAnchor.constraint(equalToConstant: 50),
      imgView.leadingAnchor.constraint(equalTo: topView.leadingAnchor),
      imgView.topAnchor.constraint(equalTo: topView.topAnchor),
      imgView.bottomAnchor.constraint(equalTo: topView.bottomAnchor),
      labelStackView.leadingAnchor.constraint(equalTo: imgView.trailingAnchor,
                                              constant: 5),
      labelStackView.topAnchor.constraint(equalTo: topView.topAnchor),
      labelStackView.trailingAnchor.constraint(equalTo: topView.trailingAnchor),
      labelStackView.bottomAnchor.constraint(equalTo: topView.bottomAnchor),
      bottomViewHeightConstraint,
      bottomView.widthAnchor.constraint(equalTo: topView.widthAnchor)
    ])
  }
  
  private func setupOrgImgViews(orgImgUrls: [String]) {
    
    orgImgUrls.forEach { urlString in
      let orgImgView = UIImageView()
      orgImgView.translatesAutoresizingMaskIntoConstraints = false
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
  
  private func addTapGesture() {
    let tap = UITapGestureRecognizer(target: self,
                                     action: #selector(imgViewOrUsernameTapped(recognizer:)))
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
    bottomView.isHidden = !bottomView.isHidden
    //bottomViewHeightConstraint.isActive = !bottomView.isHidden
    if isFetched {
      delegate?.requestUpdateTableView()
    } else {
      guard let index = self.row else { return }
      guard let username = self.usernameLabel.text else { return }
      self.delegate?.requestOrgUrls(username: username, index: index)
    }
  }
}
