//
//  ViewModel.swift
//  SearchUser
//
//  Created by junwoo on 28/02/2019.
//  Copyright © 2019 samchon. All rights reserved.
//

import Foundation

protocol ViewModelDelegate: class {
  func onFetchCompleted()
  func onFetchFailed(with reason: String)
}

class ViewModel {
  private var shouldShowLoadingCell = false
  weak var delegate: ViewModelDelegate?
  private var currentPage = 1
  private var lastPage = 0
  private var networkManager: NetworkManager!
  private var userInfos: [UserInfo] = []
  
  init(networkManager: NetworkManager) {
    self.networkManager = networkManager
  }
  
  func getTotalCount() -> Int {
    return userInfos.count
  }
  
  func getShouldShowLoadingCell() -> Bool {
    return shouldShowLoadingCell
  }
  
  func getUserInfo(at index: Int) -> UserInfo {
    return userInfos[index]
  }
  
  func refreshList() {
    self.currentPage = 1
    self.userInfos = []
  }
  
  func fetchUsers(query: String) {
    print("Fetching page \(currentPage)/\(lastPage)")
    if let url = networkManager.getUrl(query: query, page: currentPage) {
      
      networkManager.loadData(url: url) { [weak self] result in
        guard let self = self else { return }
        switch result {
        case .success(let pagedResponse):
          if self.lastPage == 0 {
            self.lastPage = pagedResponse.0
          }
          let data = pagedResponse.1
          let pagedUserInfos = self.networkManager.convertDataToUserInfo(data: data)
          self.userInfos += pagedUserInfos
          self.shouldShowLoadingCell = self.currentPage < self.lastPage
          self.delegate?.onFetchCompleted()
          
        case .failure(let error):
          self.delegate?.onFetchFailed(with: error.localizedDescription)
        }
      }
      
    }
  }
  
  func fetchNextPage(query: String) {
    currentPage += 1
    fetchUsers(query: query)
  }
}
