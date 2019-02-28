//
//  UserInfo.swift
//  SearchUser
//
//  Created by junwoo on 28/02/2019.
//  Copyright © 2019 samchon. All rights reserved.
//

import Foundation

struct UserInfo {
  var avatar_url: String
  var score: Double
  var login: String
}

extension UserInfo {
  
  init?(result: [String: Any]) {
    
    guard let avatarUrl = result["avatar_url"] as? String,
      let userScore = result["score"] as? Double,
      let username = result["login"] as? String else {
        return nil
    }
    
    self.avatar_url = avatarUrl
    self.score = userScore
    self.login = username
    
  }
}
