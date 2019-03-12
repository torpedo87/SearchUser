//
//  NetworkManager.swift
//  SearchUser
//
//  Created by junwoo on 28/02/2019.
//  Copyright © 2019 samchon. All rights reserved.
//

import Foundation
import RxSwift

typealias PagedResponse = (Int, Data)

enum Result<Value, Error: Swift.Error> {
  case success(Value)
  case failure(Error)
}

extension Result {
  func resolve() throws -> Value {
    switch self {
    case .success(let value):
      return value
    case .failure(let error):
      throw error
    }
  }
}

enum LoadingError: Error {
  case client
  case server
}

class NetworkManager {
  
  static var shared: NetworkManager {
    return NetworkManager.init()
  }
  
  private let session: URLSession
  init(session: URLSession = .shared) {
    self.session = session
  }
  
  func loadData(finalUrl: URL) -> Observable<Result<Data, LoadingError>> {

    let request: Observable<URLRequest> = Observable.create{ observer in
      let request: URLRequest = {
        var request = URLRequest(url: $0)
        request.httpMethod = "GET"
        return request
      }(finalUrl)
      observer.onNext(request)
      observer.onCompleted()
      return Disposables.create()
    }

    return request.flatMap{
      URLSession.shared.rx.response(request: $0)
      }
      .map({ (response, data) -> Result<Data, LoadingError> in
        if 200 ..< 300 ~= response.statusCode {
          return Result.success(data)
        } else {
          return Result.failure(LoadingError.client)
        }
      })
      .catchError({ _ -> Observable<Result<Data, LoadingError>> in
        return Observable.just(Result.failure(LoadingError.server))
      })
  }
  
  func loadPagedData(finalUrl: URL) -> Observable<Result<PagedResponse, LoadingError>> {
    
    let request: Observable<URLRequest> = Observable.create{ observer in
      let request: URLRequest = {
        var request = URLRequest(url: $0)
        request.httpMethod = "GET"
        return request
      }(finalUrl)
      observer.onNext(request)
      observer.onCompleted()
      return Disposables.create()
    }
    
    return request.flatMap{
      URLSession.shared.rx.response(request: $0)
      }
      .map({ [unowned self] (response, data) -> Result<PagedResponse, LoadingError> in
        if 200 ..< 300 ~= response.statusCode {
          if let link = response.allHeaderFields["Link"] as? String {
            let lastPage = self.getLastPage(link: link)
            let pagedResponse = (lastPage, data)
            return Result.success(pagedResponse)
          }
          return Result.success((0, data))
        } else {
          return Result.failure(LoadingError.client)
        }
      })
      .catchError({ _ -> Observable<Result<PagedResponse, LoadingError>> in
        return Observable.just(Result.failure(LoadingError.server))
      })
  }
  
  private func getLastPage(link: String) -> Int {
    guard link.contains("last") else { return 0 }
    let last = link.trimmingCharacters(in: .whitespaces)
      .components(separatedBy: ",")
      .filter { $0.contains("last") }.first!
      .filter { char in
        CharacterSet.decimalDigits
          .contains(Unicode.Scalar(String(char))!)
      }
    return Int(last) ?? 0
  }
}
