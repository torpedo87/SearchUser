//
//  ViewController.swift
//  SearchUser
//
//  Created by junwoo on 28/02/2019.
//  Copyright © 2019 samchon. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  var networkManager: NetworkManager!
  private var list: [UserInfo] = []
  
  private lazy var searchController: UISearchController = {
    let controller = UISearchController(searchResultsController: nil)
    controller.obscuresBackgroundDuringPresentation = false
    controller.searchBar.placeholder = "Please enter keywords"
    controller.searchResultsUpdater = self
    definesPresentationContext = true
    return controller
  }()
  
  private lazy var tableView: UITableView = {
    let view = UITableView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.register(UserListCell.self,
                  forCellReuseIdentifier: UserListCell.reuseIdentifier)
    view.backgroundColor = UIColor.clear
    view.delegate = self
    view.dataSource = self
    view.rowHeight = UITableView.automaticDimension
    view.estimatedRowHeight = 140
    return view
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white
    navigationItem.searchController = searchController
    navigationItem.hidesSearchBarWhenScrolling = false
    view.addSubview(tableView)
    
    tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
    tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
    tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
  }


}

extension ViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCell(withIdentifier: UserListCell.reuseIdentifier,
                                                for: indexPath) as? UserListCell {
      
      return cell
    }
    return UITableViewCell()
  }
  
  
}

extension ViewController: UITableViewDelegate {
  
}

extension ViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    
  }
  
  
}
