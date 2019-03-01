//
//  ViewModel.swift
//  SearchUser
//
//  Created by junwoo on 28/02/2019.
//  Copyright © 2019 samchon. All rights reserved.
//

import Foundation

protocol ViewModelDelegate: class {
  func userFetchCompleted(_ list: [UserInfo])
  func orgFetchCompleted(_ list: [String], cell: UserListCell)
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
  
  func fetchOrg(username: String, cell: UserListCell) {
    if let url = getOrgUrl(username: username) {
      networkManager.loadOrgData(url: url) { [weak self] (result) in
        guard let self = self else { return }
        switch result {
        case .success(let data):
          let orgUrls = self.convertDataToOrgUrlString(data: data)
          self.delegate?.orgFetchCompleted(orgUrls, cell: cell)
        case .failure(let error):
          print(error.localizedDescription)
        }
      }
    }
  }
  
  func fetchUsers(query: String) {
    print("Fetching page \(currentPage)/\(lastPage)")
    if let url = getSearchUrl(query: query, page: currentPage) {
      
      networkManager.loadUserData(url: url) { [weak self] result in
        guard let self = self else { return }
        switch result {
        case .success(let pagedResponse):
          if self.lastPage == 0 {
            self.lastPage = pagedResponse.0
          }
          let data = pagedResponse.1
          let pagedUserInfos = self.convertDataToUserInfo(data: data)
          self.userInfos += pagedUserInfos
          self.shouldShowLoadingCell = self.currentPage < self.lastPage
          self.delegate?.userFetchCompleted(self.userInfos)
          
        case .failure(let error):
          print(error.localizedDescription)
        }
      }
      
    }
  }
  
  func fetchNextPage(query: String) {
    currentPage += 1
    fetchUsers(query: query)
  }
  
  private func convertDataToUserInfo(data: Data) -> [UserInfo] {
    if let json = try? JSONSerialization.jsonObject(with: data, options: []),
      let dict = json as? [String: Any],
      let results = dict["items"] as? [[String:Any]] {
      var list: [UserInfo] = []
      for result in results {
        if let userInfo = UserInfo(result: result) {
          list.append(userInfo)
        }
      }
      return list
    }
    return []
  }
  
  private func convertDataToOrgUrlString(data: Data) -> [String] {
    if let json = try? JSONSerialization.jsonObject(with: data, options: []),
      let dict = json as? [String: Any],
      let results = dict["result"] as? [[String:Any]] {
      var list: [String] = []
      for result in results {
        if let orgUrlString = result["avatar_url"] as? String {
          list.append(orgUrlString)
        }
      }
      return list
    }
    return []
  }
  
  private func getSearchUrl(query: String, page: Int) -> URL? {
    
    guard var url = URL(string: "https://api.github.com/search/users") else {
      return nil
    }
    let urlParams = [
      "q": query,
      "page": "\(page)"
    ]
    
    url = url.appendingQueryParameters(urlParams)
    return url
  }
  
  private func getOrgUrl(username: String) -> URL? {
    guard let url = URL(string: "https://api.github.com/users/\(username)/orgs") else {
      return nil
    }
    return url
  }
}
