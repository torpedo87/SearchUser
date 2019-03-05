//
//  ViewModel.swift
//  SearchUser
//
//  Created by junwoo on 28/02/2019.
//  Copyright © 2019 samchon. All rights reserved.
//

import Foundation
import RxSwift

class ViewModel {
  var searchInput = PublishSubject<String>()
  private var networkManager: NetworkManager!
  private var pagingManager: PagingManager!
  let userInfoList = Variable<[UserInfo]>([])
  private let bag = DisposeBag()
  
  init(networkManager: NetworkManager, pagingManager: PagingManager) {
    self.networkManager = networkManager
    self.pagingManager = pagingManager
    
    searchInput.asObservable()
      .do(onNext: { [unowned self] _ in
        self.refreshList()
      })
      .map({ [unowned self] query -> URL? in
        return self.getSearchUrl(query: query, page: self.pagingManager.getCurrentPage())
      })
      .filter{ $0 != nil }
      .flatMap({ [unowned self] finalUrl -> Observable<[UserInfo]> in
        guard let url = finalUrl else { return Observable.empty() }
        return self.fetchUserList(finalUrl: url)
      })
      .bind(to: userInfoList)
      .disposed(by: bag)
  }
  
  func fetchUserList(finalUrl: URL) -> Observable<[UserInfo]> {
    return networkManager.loadPagedData(finalUrl: finalUrl)
      .do(onNext: { [unowned self] result in
        switch result {
        case .success(let pagedResponse):
          if !self.pagingManager.isSetLastPage {
            self.pagingManager.setLastPage(last: pagedResponse.0)
          }
        case .failure(_):
          break
        }
      })
      .map({ [unowned self] result -> [UserInfo] in
        switch result {
        case .success(let pagedResponse):
          let data = pagedResponse.1
          let newList = self.convertDataToUserInfo(data: data)
          return newList
        case .failure(_):
          return []
        }
      })
  }
  
  func getShouldShowLoadingCell() -> Bool {
    return pagingManager.shouldShowLoadingCell
  }
  
  func refreshList() {
    pagingManager.reset()
    self.userInfoList.value = []
  }
  
  func fetchOrgUrls(username: String, index: Int) -> Observable<[String]> {
    if let finalUrl = getOrgUrl(username: username) {
      
      return networkManager.loadData(finalUrl: finalUrl)
        .map { [weak self] result in
          guard let self = self else { return [] }
          switch result {
          case .success(let data):
            let orgUrls = self.convertDataToOrgUrlString(data: data)
            return orgUrls
          case .failure(_):
            return []
          }
        }
    }
    return Observable.empty()
  }
  
  func fetchNextPage(query: String) {
    
    pagingManager.nextPage()
    if let finalUrl = getSearchUrl(query: query, page: pagingManager.getCurrentPage()) {
      fetchUserList(finalUrl: finalUrl)
        .do(onNext: { [unowned self] newList in
          self.userInfoList.value += newList
        })
        .subscribe()
        .disposed(by: bag)
    }
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
      let results = json as? [[String:Any]] {
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



