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
  private var currentPage = 1
  private var lastPage = 0
  
  func nextPage() {
    currentPage += 1
  }
  
  var isSetLastPage: Bool {
    return lastPage != 0
  }
  
  var shouldShowLoadingCell: Bool {
    return self.currentPage < self.lastPage
  }
  
  func setLastPage(last: Int) {
    self.lastPage = last
  }
  
  func getCurrentPage() -> Int {
    return self.currentPage
  }
  
  func reset() {
    self.currentPage = 1
    self.lastPage = 0
  }
}

