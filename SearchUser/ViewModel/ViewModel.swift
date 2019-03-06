//
//  ViewModel.swift
//  SearchUser
//
//  Created by junwoo on 28/02/2019.
//  Copyright © 2019 samchon. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ViewModel {
  var searchInput = PublishSubject<String>()
  var reachToBottom = PublishSubject<Bool>()
  var hasNext = PublishSubject<Bool>()
  private var networkManager: NetworkManager!
  private var pagingManager: PagingManager!
  let userInfoList = BehaviorRelay<[UserInfo]>(value: [])
  private let bag = DisposeBag()
  private let globalScheduler = ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global())
  
  init(networkManager: NetworkManager, pagingManager: PagingManager) {
    self.networkManager = networkManager
    self.pagingManager = pagingManager
    
    //검색어 변경시 페이지 리셋
    searchInput.asObservable()
      .subscribe(onNext: { _ in
        pagingManager.current.onNext(1)
      })
      .disposed(by: bag)
    
    //검색어와 페이지를 통해 url 요청해서 유저 정보 가져오기
    Observable.combineLatest(searchInput.asObservable(),
                             pagingManager.current.asObservable())
      .map { [unowned self] query, page -> URL? in
        return self.getSearchUrl(query: query, page: page)
      }
      .filter{ $0 != nil }
      .subscribeOn(globalScheduler)
      .flatMap({ [unowned self] finalUrl -> Observable<[UserInfo]> in
        return self.fetchUserList(finalUrl: finalUrl!)
      })
      .map({ newList in
        if pagingManager.getCurrentPage() == 1 {
          return newList
        } else {
          return self.userInfoList.value + newList
        }
      })
      .bind(to: userInfoList)
      .disposed(by: bag)
    
    //스크롤이 밑바닥에 도달하고 다음 페이지가 있으면 다음 페이지로
    reachToBottom.asObservable()
      .filter{ $0 && pagingManager.shouldLoading }
      .bind(to: hasNext)
      .disposed(by: bag)
    
    hasNext.asObservable()
      .subscribe(onNext: { [unowned self] _ in
        self.pagingManager.nextPage()
      })
      .disposed(by: bag)
  }
  
  func fetchUserList(finalUrl: URL) -> Observable<[UserInfo]> {
    return networkManager.loadPagedData(finalUrl: finalUrl)
      .do(onNext: { [unowned self] result in
        switch result {
        case .success(let pagedResponse):
          //lastpage 한번 가져오기
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



