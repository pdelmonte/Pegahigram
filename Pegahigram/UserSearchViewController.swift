//
//  UserSearchViewController.swift
//  Pegahigram
//
//  Created by Pedro Delmonte on 01/06/17.
//  Copyright © 2017 BTS. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase


class UserSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UserTableViewCellDelegate {
    
    var users = [User]()
    var db: DatabaseReference!
    var filteredData = [User]()
    var isSearching = false
    @IBOutlet weak var userTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        userTableView.dataSource = self
        userTableView.delegate = self
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        
        db = Database.database().reference()
        retrieveUsers()
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func retrieveUsers() {
        let userId = Auth.auth().currentUser?.uid
        db.child("user").queryOrderedByKey().observe(.value, with: { snapshot in
            if let users = snapshot.value as? [String: [String: String]] {
                self.db.child("following").queryOrderedByKey().queryEqual(toValue: userId!).observe(.value, with: { snapshot in
                    self.users.removeAll()
                    for (_, value) in users {
                        if (value["uid"] != userId) {
                            let user = User()
                            user.uid = value["uid"]
                            user.username = value["username"]
                            if let following = snapshot.value as? [String: [String: String]] {
                                if  (following[userId!]?[value["uid"]!] != nil) {
                                    user.follow = true
                                }
                            }
                            self.users.append(user)
                        }
                    }
                self.userTableView.reloadData()
                })
            }
        })
        
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isSearching {
            return filteredData.count
        }
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as! UserTableViewCell
        
        var user = users[indexPath.row]
        
        if isSearching {
            user = filteredData[indexPath.row]
        }
        
        cell.usernameLabel.text = user.username
        cell.selectionStyle = .none
        cell.delegate = self
        if user.follow {
            cell.followButton.setTitle("Unfollow", for: .normal)
        } else {
            cell.followButton.setTitle("Follow", for: .normal)
        }

        return cell
    }

    func userCellFollowButtonPressed(sender: UserTableViewCell) {
        if let indexPath = userTableView.indexPath(for: sender) {
            let user = users[indexPath.row]
            user.follow = !user.follow
            userTableView.reloadData()
            
            //Now we need to save the follow info in the database
            let userId = Auth.auth().currentUser?.uid
            
            if user.follow == true {
                self.db.child("following").child(userId!).updateChildValues([user.uid!: user.uid!])
            } else {
                self.db.child("following").child(userId!).child(user.uid!).removeValue()
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            isSearching = false
            view.endEditing(true)
        } else {
            isSearching = true
            filteredData = users.filter({ (mod) -> Bool in
                return (mod.username!.lowercased()).contains(searchText.lowercased())
            })
        }
        userTableView.reloadData()
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
