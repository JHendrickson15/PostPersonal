//
//  Post.swift
//  Post
//
//  Created by Jordan Hendrickson on 5/13/19.
//  Copyright © 2019 DevMtnStudent. All rights reserved.
//

import Foundation

class Post: Codable {
    
    let text: String
    var timestamp: TimeInterval
    let username: String
    
    init(text: String , timestamp: TimeInterval = Date().timeIntervalSince1970 , username: String) {
        self.text = text
        self.timestamp = timestamp
        self.username = username
    }
}
