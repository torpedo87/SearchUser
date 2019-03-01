//
//  NetworkManager.swift
//  SearchUser
//
//  Created by junwoo on 28/02/2019.
//  Copyright © 2019 samchon. All rights reserved.
//

import Foundation

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
  
  private let session: URLSession
  var gotLastPage: Bool = false
  init(session: URLSession = .shared) {
    self.session = session
  }
  
  func loadUserData(url: URL,
                comopletionHandler: @escaping (Result<PagedResponse, LoadingError>) -> Void) {
    
    let task = session.dataTask(with: url) { [weak self] (data, response, error) in
      guard let self = self else { return }
      if let _ = error {
        comopletionHandler(.failure(.client))
        return
      }
      
      if let httpResponse = response as? HTTPURLResponse {
        if !self.gotLastPage {
          if let link = httpResponse.allHeaderFields["Link"] as? String {
            let lastPage = (self.getLastPageFromLinkHeader(link: link))
            self.gotLastPage = true
            if let data = data {
              let pagedResponse = (lastPage, data)
              comopletionHandler(.success(pagedResponse))
            }
          }
        } else {
          if let data = data {
            let pagedResponse = (-1, data)
            comopletionHandler(.success(pagedResponse))
          }
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
          comopletionHandler(.failure(.server))
          return
        }
      }
      
    }
    task.resume()
  }
  
  func loadOrgData(url: URL,
                    comopletionHandler: @escaping (Result<Data, LoadingError>) -> Void) {
    
    let task = session.dataTask(with: url) { (data, response, error) in
      if let _ = error {
        comopletionHandler(.failure(.client))
        return
      }
      
      if let httpResponse = response as? HTTPURLResponse {
        if let data = data {
          comopletionHandler(.success(data))
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
          comopletionHandler(.failure(.server))
          return
        }
      }
      
    }
    task.resume()
  }
  
  private func getLastPageFromLinkHeader(link: String) -> Int {
    let strWithLastPage = link.components(separatedBy: "=")[4]
    let lastPage = strWithLastPage.components(separatedBy: "&")[0]
    return Int(lastPage) ?? 0
  }
}
