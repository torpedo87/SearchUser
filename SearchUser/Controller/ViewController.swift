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
  var currentPage: Int = 1
  private var shouldShowLoadingCell = false
  
  private lazy var searchController: UISearchController = {
    let controller = UISearchController(searchResultsController: nil)
    controller.obscuresBackgroundDuringPresentation = false
    controller.searchBar.placeholder = "Please enter keywords"
    definesPresentationContext = true
    controller.searchResultsUpdater = self
    return controller
  }()
  
  private lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.register(UserListCell.self,
                  forCellReuseIdentifier: UserListCell.reuseIdentifier)
    tableView.backgroundColor = UIColor.clear
    tableView.delegate = self
    tableView.dataSource = self
    tableView.rowHeight = 75
    
    return tableView
  }()
  
  init(manager: NetworkManager) {
    self.networkManager = manager
    super.init(nibName: nil, bundle: nil)
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white
    navigationItem.searchController = searchController
    view.addSubview(tableView)
    
    tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
    tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
    tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
  }
  
  func loadContent(searchText: String) {
    
    if let url = networkManager.getUrl(query: searchText, page: currentPage) {
      networkManager.loadData(url: url) { [weak self] result in
        guard let self = self else { return }
        self.handleResult(result: result)
      }
    }
  }
  
  func handleResult(result: Result<Data, LoadingError>) {
    switch result {
    case .success(let data):
      let userList = self.networkManager.convertDataToUserInfo(data: data)
      self.list = self.list + userList
      DispatchQueue.main.async {
        self.tableView.reloadData()
      }
      
    case .failure(let error):
      switch error {
      case .client:
        print("client error occured")
      case .server:
        print("server error occured")
      }
    }
  }
  
  func searchBarIsEmpty() -> Bool {
    return searchController.searchBar.text?.isEmpty ?? true
  }
}

extension ViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return list.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCell(withIdentifier: UserListCell.reuseIdentifier,
                                                for: indexPath) as? UserListCell {
      let userInfo = list[indexPath.row]
      cell.configure(userInfo: userInfo)
      return cell
    }
    return UITableViewCell()
  }
  
  
}

extension ViewController: UITableViewDelegate {
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    
    if ((tableView.contentOffset.y + tableView.frame.size.height) >= tableView.contentSize.height) {
      
      self.currentPage += 1
      guard !searchBarIsEmpty() else { return }
      self.loadContent(searchText: searchController.searchBar.text!)
    }
    
  }
  
}

extension ViewController: UISearchResultsUpdating {
  
  func updateSearchResults(for searchController: UISearchController) {
    
    guard !searchBarIsEmpty() else { return }
    loadContent(searchText: searchController.searchBar.text!)
  }
}
