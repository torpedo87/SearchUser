//
//  ViewController.swift
//  SearchUser
//
//  Created by junwoo on 28/02/2019.
//  Copyright © 2019 samchon. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  var viewModel: ViewModel!
  var userList: [UserInfo] = []
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
    tableView.estimatedRowHeight = 75
    tableView.rowHeight = UITableView.automaticDimension
    return tableView
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    navigationItem.searchController = searchController
    view.addSubview(tableView)
    viewModel.delegate = self
    
    tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
    tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
    tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
  }
  
  func searchBarIsEmpty() -> Bool {
    return searchController.searchBar.text?.isEmpty ?? true
  }
}

extension ViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let totalCount = userList.count
    return viewModel.getShouldShowLoadingCell() ? totalCount + 1 : totalCount
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if isLoadingIndexPath(indexPath) {
      return LoadingCell(style: .default, reuseIdentifier: "LoadingCell")
    } else {
      if let cell = tableView.dequeueReusableCell(withIdentifier: UserListCell.reuseIdentifier,
                                                  for: indexPath) as? UserListCell {
        let userInfo = viewModel.getUserInfo(at: indexPath.row)
        cell.configure(userInfo: userInfo)
        cell.delegate = self
        return cell
      }
      return UITableViewCell()
    }
  }
  
  private func isLoadingIndexPath(_ indexPath: IndexPath) -> Bool {
    guard viewModel.getShouldShowLoadingCell() else { return false }
    return indexPath.row == userList.count
  }
}

extension ViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard isLoadingIndexPath(indexPath) else { return }
    guard !searchBarIsEmpty() else { return }
    viewModel.fetchNextPage(query: searchController.searchBar.text!)
  }
}

extension ViewController: UISearchResultsUpdating {
  
  func updateSearchResults(for searchController: UISearchController) {
    
    guard !searchBarIsEmpty() else { return }
    viewModel.refreshList()
    viewModel.fetchUsers(query: searchController.searchBar.text!)
  }
}

extension ViewController: ViewModelDelegate {
  func orgFetchCompleted(_ list: [String], cell: UserListCell) {
    cell.updateOrgImgViews(imgUrls: list)
  }
  
  func userFetchCompleted(_ list: [UserInfo]) {
    DispatchQueue.main.async {
      self.userList = list
      self.tableView.reloadData()
    }
  }
}

extension ViewController: UserListCellDelegate {
  func requestOrgUrls(cell: UserListCell, username: String) {
    viewModel.fetchOrg(username: username, cell: cell)
  }
}
