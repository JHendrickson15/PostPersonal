//
//  PostListTableViewController.swift
//  Post
//
//  Created by Jordan Hendrickson on 5/13/19.
//  Copyright © 2019 DevMtnStudent. All rights reserved.
//

import UIKit

class PostListTableViewController: UITableViewController {

    
    let postController = PostController()
    
    var refreshedControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 45
        tableView.rowHeight = UITableView.automaticDimension
        tableView.refreshControl = refreshedControl
        refreshedControl.addTarget(self, action: #selector(refreshControlPulled), for: .valueChanged)
        
        postController.fetchPosts {
            self.reloadTableView()
        }
    }
    @objc func refreshControlPulled() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        postController.fetchPosts {
            self.reloadTableView()
            DispatchQueue.main.async {
                self.refreshedControl.endRefreshing()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    func presentNewPostAlert(){//not sure how to make it print to my cell
        let alertController = UIAlertController(title: "Add Post", message: "Add a post to your feed", preferredStyle: .alert)
        alertController.addTextField { (usernameTextField) in
            usernameTextField.placeholder = "username"
        alertController.addTextField{ (textTextField) in
            textTextField.placeholder = "message"
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let addAction = UIAlertAction(title: "Add", style: .default) { (_) in
            guard let username = alertController.textFields?[0].text,
                let text = alertController.textFields?[1].text else {return}
            self.postController.addNewPostWith(username: username , text: text , completion: {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            })
        }
        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        self.present(alertController, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return postController.posts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        let post = postController.posts[indexPath.row]
        
        cell.textLabel?.text = post.text
        cell.detailTextLabel?.text = "\(post.timestamp)"

        return cell
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    @IBAction func addButtonTapped(_ sender: Any) {
        presentNewPostAlert()
    }
    

}
