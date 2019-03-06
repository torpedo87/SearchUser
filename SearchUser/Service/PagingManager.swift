//
//  PagingManager.swift
//  SearchUser
//
//  Created by junwoo on 05/03/2019.
//  Copyright © 2019 samchon. All rights reserved.
//

import Foundation
import RxSwift

class PagingManager {
  private let bag = DisposeBag()
  private var currentPage = 1
  private var lastPage = 0
  var hasNext = PublishSubject<Bool>()
  var current = PublishSubject<Int>()
  
  init() {
    current.asObservable()
      .map { [unowned self] page -> Bool in
        return page < self.lastPage
      }
      .bind(to: hasNext)
      .disposed(by: bag)
  }
  
  func nextPage() {
    currentPage += 1
    current.onNext(currentPage)
  }
  
  var isSetLastPage: Bool {
    return lastPage != 0
  }
  
  func setLastPage(last: Int) {
    self.lastPage = last
  }
  
  func getCurrentPage() -> Int {
    return self.currentPage
  }
}

