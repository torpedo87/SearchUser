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
  var last = PublishSubject<Int>()
  
  init() {
    Observable.combineLatest(current.asObservable(), last.asObservable())
      .map { current, last -> Bool in
        return current < last
      }
      .bind(to: hasNext)
      .disposed(by: bag)
    
    current.onNext(1)
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
    self.last.onNext(last)
  }
  
  func getCurrentPage() -> Int {
    return self.currentPage
  }
}

