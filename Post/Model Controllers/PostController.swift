//
//  PostController.swift
//  Post
//
//  Created by Jordan Hendrickson on 5/13/19.
//  Copyright © 2019 DevMtnStudent. All rights reserved.
//

import Foundation

class PostController{
    
    let baseURL = URL(string: "http://devmtn-posts.firebaseio.com/posts")
    
    var posts: [Post] = []
    
    func fetchPosts(completion: @escaping () -> Void ){
        
        let reset: Bool = true
        guard let unwrappedURL = baseURL else {completion();return}
        let queryEndInterval = reset ? Date().timeIntervalSince1970 : posts.last?.timestamp ?? Date().timeIntervalSince1970
        
        let urlParameters = [
            "orderBy" : "\"timestamp\"",
            "endAt" : "\(queryEndInterval)",
            "limitToLast": "15"
        ]
        let queryItems = urlParameters.compactMap ( {URLQueryItem(name: $0.key, value: $0.value)})
        
        var urlComponents = URLComponents(url: unwrappedURL, resolvingAgainstBaseURL: true)
        
        urlComponents?.queryItems = queryItems
        
        guard let url = urlComponents?.url else {return}
        
        let getterEndpoint = url.appendingPathExtension("json")
        
        var request = URLRequest(url: getterEndpoint)
        request.httpBody = nil
        request.httpMethod = "GET"
        
        let dataTask = URLSession.shared.dataTask(with: getterEndpoint) { (data, _, error) in
            if let error = error {
                print(error.localizedDescription)
                completion()
                return
            }
            guard let data = data else {completion(); return}
            
            let jsonDecoder = JSONDecoder()
            do{
                let postsDictionary = try jsonDecoder.decode([String: Post].self , from: data)
                var posts = postsDictionary.compactMap({ $0.value })
                posts.sort(by: {(x,y) -> Bool in
                    if x.timestamp > y.timestamp {
                        return true
                    }else{
                        return false
                    }
                })
                self.posts = posts
                completion()
            }catch{
                print(error.localizedDescription)
                completion()
                return
            }
        }
        dataTask.resume()
    }
    
    func addNewPostWith(username: String , text: String , completion: @escaping () -> Void) {
        let post = Post(text: text, username: username)
        var postData: Data?
        do{
           postData = try JSONEncoder().encode(post)
//           completion()
        }catch{
            print("whoops there was an error! \(error.localizedDescription)")
            return
        }
        
        guard let url = baseURL else {completion();return}
        let postEndpoint = url.appendingPathExtension("json")
        
        print(postEndpoint)
        
        var request = URLRequest(url: postEndpoint)
        request.httpBody = postData
        request.httpMethod = "POST"
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error{
                print(error.localizedDescription)
                return
            }
            guard let data = data else {return}
            let dataString = String(data: data, encoding: .utf8)
//            print(dataString)
            self.fetchPosts {
                completion()
            }
        }
        dataTask.resume()
    }
}
