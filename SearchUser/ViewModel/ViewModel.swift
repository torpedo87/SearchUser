//
//  ViewModel.swift
//  SearchUser
//
//  Created by junwoo on 28/02/2019.
//  Copyright © 2019 samchon. All rights reserved.
//

import Foundation

protocol ViewModelDelegate: class {
  func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?)
  func onFetchFailed(with reason: String)
}

class ViewModel {
  private weak var delegate: ViewModelDelegate?
  private var currentPage = 1
  private var lastPage = 0
  private var isFetchInProgress = false
  private var networkManager: NetworkManager!
  private var userInfos: [UserInfo] = []
  
  init(networkManager: NetworkManager, delegate: ViewModelDelegate) {
    self.networkManager = networkManager
    self.delegate = delegate
  }
  
  var totalCount: Int {
    return userInfos.count
  }
  
  func userInfo(at index: Int) -> UserInfo {
    return userInfos[index]
  }
  
  func fetchUsers(query: String) {
    
    guard !isFetchInProgress else {
      return
    }
    
    isFetchInProgress = true
    
    if let url = networkManager.getUrl(query: query, page: currentPage) {
      
      networkManager.loadData(url: url) { result in
        switch result {
        case .success(let pagedResponse):
          DispatchQueue.main.async {
            self.currentPage += 1
            self.isFetchInProgress = false
            self.lastPage = pagedResponse.0
            let data = pagedResponse.1
            let pagedUserInfos = self.networkManager.convertDataToUserInfo(data: data)
            self.userInfos += pagedUserInfos
            
            if self.lastPage > self.currentPage {
              let indexPathsToReload = self.calculateIndexPathsToReload(from: pagedUserInfos)
              self.delegate?.onFetchCompleted(with: indexPathsToReload)
            } else {
              self.delegate?.onFetchCompleted(with: .none)
            }
          }
        case .failure(let error):
          DispatchQueue.main.async {
            self.isFetchInProgress = false
            self.delegate?.onFetchFailed(with: error.localizedDescription)
          }
        }
      }
      
    }
  }
  
  private func calculateIndexPathsToReload(from newUserInfos: [UserInfo]) -> [IndexPath] {
    let startIndex = userInfos.count - newUserInfos.count
    let endIndex = startIndex + newUserInfos.count
    return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
  }
}
