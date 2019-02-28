//
//  LoadingCell.swift
//  SearchUser
//
//  Created by junwoo on 01/03/2019.
//  Copyright © 2019 samchon. All rights reserved.
//

import UIKit

class LoadingCell: UITableViewCell {
  
  private lazy var indicatorView: UIActivityIndicatorView = {
    let spinner = UIActivityIndicatorView()
    spinner.translatesAutoresizingMaskIntoConstraints = false
    spinner.hidesWhenStopped = true
    spinner.color = UIColor.blue
    return spinner
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupUI()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setupUI() {
    contentView.addSubview(indicatorView)
    indicatorView.widthAnchor.constraint(equalToConstant: 30).isActive = true
    indicatorView.heightAnchor.constraint(equalToConstant: 30).isActive = true
    indicatorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
    indicatorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    
    indicatorView.startAnimating()
  }
}
