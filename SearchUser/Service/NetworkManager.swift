//
//  NetworkManager.swift
//  SearchUser
//
//  Created by junwoo on 28/02/2019.
//  Copyright © 2019 samchon. All rights reserved.
//

import Foundation

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
                comopletionHandler: @escaping (Result<Data, LoadingError>) -> Void) {
    
    let task = session.dataTask(with: url) { (data, response, error) in
      
      if let _ = error {
        comopletionHandler(.failure(.client))
        return
      }
      
      if let httpResponse = response as? HTTPURLResponse {
        if !(200...299).contains(httpResponse.statusCode) {
          comopletionHandler(.failure(.server))
          return
        }
      }
      if let data = data {
        comopletionHandler(.success(data))
      }
    }
    task.resume()
  }
  
  func convertDataToUserInfo(data: Data) -> [UserInfo] {
    if let json = try? JSONSerialization.jsonObject(with: data, options: []),
      let dict = json as? [String: Any],
      let results = dict["results"] as? [[String:Any]] {
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
  
  func getUrl(query: String) -> URL? {
    
    guard var url = URL(string: "https://api.github.com/search/users") else {
      return nil
    }
    let urlParams = [
      "q": query,
      ]
    
    url = url.appendingQueryParameters(urlParams)
    return url
  }
}
