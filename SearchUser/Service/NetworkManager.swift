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
  
  init(session: URLSession = .shared) {
    self.session = session
  }
  
  func loadData(url: URL,
                comopletionHandler: @escaping (Result<PagedResponse, LoadingError>) -> Void) {
    
    let task = session.dataTask(with: url) { (data, response, error) in
      
      if let _ = error {
        comopletionHandler(.failure(.client))
        return
      }
      
      if let httpResponse = response as? HTTPURLResponse {
        if let link = httpResponse.allHeaderFields["Link"] as? String {
          let lastPage = (self.getLastPageFromLinkHeader(link: link))
          if let data = data {
            let pagedResponse = (lastPage, data)
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
  
  private func getLastPageFromLinkHeader(link: String) -> Int {
    let strWithLastPage = link.components(separatedBy: "=")[4]
    let lastPage = strWithLastPage.components(separatedBy: "&")[0]
    return Int(lastPage) ?? 0
  }
  
  func convertDataToUserInfo(data: Data) -> [UserInfo] {
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
  
  func getUrl(query: String, page: Int) -> URL? {
    
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
}
