//
//  ViewController.swift
//  SearchUser
//
//  Created by junwoo on 28/02/2019.
//  Copyright © 2019 samchon. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
  
  var viewModel: ViewModel!
  private let bag = DisposeBag()
  private lazy var searchController: UISearchController = {
    let controller = UISearchController(searchResultsController: nil)
    controller.obscuresBackgroundDuringPresentation = false
    controller.searchBar.placeholder = "Please enter keywords"
    definesPresentationContext = true
    return controller
  }()
  
  private lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.register(UserListCell.self,
                  forCellReuseIdentifier: UserListCell.reuseIdentifier)
    tableView.backgroundColor = UIColor.clear
    tableView.estimatedRowHeight = 44
    tableView.rowHeight = UITableView.automaticDimension
    return tableView
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    navigationItem.searchController = searchController
    view.addSubview(tableView)
    
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
    ])
    
    bind()
    bindTableView()
  }
  
  func bind() {
    
    //검색어 전달
    searchController.searchBar.rx.text.orEmpty
      .asObservable()
      .debounce(0.5, scheduler: MainScheduler.instance)
      .bind(to: viewModel.searchInput)
      .disposed(by: bag)
  }
  
  func bindTableView() {
    
    //결과값 받아서 테이블에 뿌리기
    viewModel.userInfoList
      .asObservable()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.tableView.reloadData()
      })
      .disposed(by: bag)
    
    viewModel.userInfoList
      .asObservable()
      .bind(to: tableView.rx.items) {
        (tableView: UITableView, index: Int, element: UserInfo) in
        if let cell = tableView.dequeueReusableCell(withIdentifier: UserListCell.reuseIdentifier) as? UserListCell {
          cell.configure(userInfo: element, index: index)
          cell.delegate = self
          return cell
        }
        return UserListCell()
      }
      .disposed(by: bag)
    
    //스크롤해서 하단에 도착하는 경우 다음 페이지 요청
    tableView.rx.willDisplayCell
      .subscribe(onNext: { [unowned self] cell, indexPath in
        guard self.isLoadingIndexPath(indexPath) else { return }
        guard !self.searchBarIsEmpty() else { return }
        self.viewModel.fetchNextPage(query: self.searchController.searchBar.text!)
      })
      .disposed(by: bag)
  }
  
  private func searchBarIsEmpty() -> Bool {
    return searchController.searchBar.text?.isEmpty ?? true
  }
  
  private func isLoadingIndexPath(_ indexPath: IndexPath) -> Bool {
    guard viewModel.getShouldShowLoadingCell() else { return false }
    return indexPath.row == viewModel.userInfoList.value.count
  }
}

extension ViewController: UserListCellDelegate {
  
  //셀 클릭이벤트 받아서 뷰모델에 요청한 후 받은 결과를 다시 셀에 전달
  func requestOrgUrls(username: String, index: Int) {
    let indexPath = IndexPath(row: index, section: 0)
    if let cell = tableView.cellForRow(at: indexPath) as? UserListCell {
      viewModel.fetchOrgUrls(username: username, index: index)
        .bind(to: cell.org_Urls)
        .disposed(by: bag)
    }
  }
}
