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
    tableView.estimatedRowHeight = 200
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
    
    //스크롤이벤트를 전달
    tableView.rx.willDisplayCell
      .map { return self.isLoadingIndexPath($0.indexPath) }
      .bind(to: viewModel.reachToBottom)
      .disposed(by: bag)
  }
  
  private func isLoadingIndexPath(_ indexPath: IndexPath) -> Bool {
    return indexPath.row == viewModel.userInfoList.value.count - 1
  }
}

extension ViewController: UserListCellDelegate {
  func requestUpdateTableView() {
    tableView.beginUpdates()
    tableView.endUpdates()
  }
  
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
