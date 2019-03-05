//
//  URL.swift
//  SearchUser
//
//  Created by junwoo on 28/02/2019.
//  Copyright © 2019 samchon. All rights reserved.
//

import Foundation

extension URL {
  func appendingQueryParameters(_ parametersDictionary : Dictionary<String, String>) -> URL {
    let URLString : String = String(format: "%@?%@",
                                    self.absoluteString,
                                    parametersDictionary.queryParameters)
    return URL(string: URLString)!
  }
}

protocol URLQueryParameterStringConvertible {
  var queryParameters: String {get}
}

extension Dictionary : URLQueryParameterStringConvertible {
  
  var queryParameters: String {
    var parts: [String] = []
    for (key, value) in self {
      let part = String(format: "%@=%@",
                        String(describing: key).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
                        String(describing: value).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
      parts.append(part as String)
    }
    return parts.joined(separator: "&")
  }
  
}
