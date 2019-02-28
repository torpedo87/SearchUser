//
//  ViewController.swift
//  SearchUser
//
//  Created by junwoo on 28/02/2019.
//  Copyright © 2019 samchon. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  private var viewModel: ViewModel!
  private lazy var indicatorView: UIActivityIndicatorView = {
    let spinner = UIActivityIndicatorView()
    spinner.translatesAutoresizingMaskIntoConstraints = false
    spinner.hidesWhenStopped = true
    spinner.color = UIColor.blue
    return spinner
  }()
  
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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let networkManager = NetworkManager()
    viewModel = ViewModel(networkManager: networkManager, delegate: self)
    view.backgroundColor = .white
    navigationItem.searchController = searchController
    view.addSubview(tableView)
    view.addSubview(indicatorView)
    
    tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
    tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
    tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    
    NSLayoutConstraint.activate([
        indicatorView.widthAnchor.constraint(equalToConstant: 30),
        indicatorView.heightAnchor.constraint(equalToConstant: 30),
        indicatorView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
        indicatorView.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
    ])
  }
  
  
  
  func searchBarIsEmpty() -> Bool {
    return searchController.searchBar.text?.isEmpty ?? true
  }
}

extension ViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.totalCount
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCell(withIdentifier: UserListCell.reuseIdentifier,
                                                for: indexPath) as? UserListCell {
      let userInfo = viewModel.userInfo(at: indexPath.row)
      cell.configure(userInfo: userInfo)
      return cell
    }
    return UITableViewCell()
  }
  
}

extension ViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard !searchBarIsEmpty() else { return }
    let lastElement = viewModel.totalCount - 1
    if indexPath.row == lastElement {
      indicatorView.startAnimating()
      viewModel.fetchUsers(query: searchController.searchBar.text!)
    }
  }
}

extension ViewController: UISearchResultsUpdating {
  
  func updateSearchResults(for searchController: UISearchController) {
    
    guard !searchBarIsEmpty() else { return }
    indicatorView.startAnimating()
    viewModel.fetchUsers(query: searchController.searchBar.text!)
  }
}

extension ViewController: ViewModelDelegate {
  
  func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?) {
    guard let newIndexPathsToReload = newIndexPathsToReload else {
      indicatorView.stopAnimating()
      tableView.reloadData()
      return
    }
    let indexPathsToReload = visibleIndexPathsToReload(intersecting: newIndexPathsToReload)
    tableView.reloadRows(at: indexPathsToReload, with: .automatic)
  }
  
  func onFetchFailed(with reason: String) {
    indicatorView.stopAnimating()
    print("fetch fail")
  }
  
  private func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
    let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows ?? []
    let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
    return Array(indexPathsIntersection)
  }
}
