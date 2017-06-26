//
//  FeedViewController.swift
//  Pegahigram
//
//  Created by Pedro Delmonte on 29/05/17.
//  Copyright © 2017 BTS. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FBSDKLoginKit
import FBSDKCoreKit


class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var pictureTableView: UITableView!
    var pictures = [Picture]()
    var db: DatabaseReference!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        pictures = [Picture]()
        pictureTableView.dataSource = self
        pictureTableView.delegate = self
        db = Database.database().reference()
        retrievePictures()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func retrievePictures() {
        let userId = Auth.auth().currentUser?.uid
        self.db.child("following").queryOrderedByKey().queryEqual(toValue: userId!).observe(.value, with: { snapshot in
            var followedUsers = snapshot.value as? [String: [String: String]]
            if followedUsers != nil {
                followedUsers!["includeMyself"] = [userId!: userId!]
            } else {
                followedUsers = [userId!: [userId!: userId!]]
            }
                self.pictures.removeAll()
                for (_, followedUser) in followedUsers! {
                    for(_, followedUserId) in followedUser {
                        self.db.child("picture").queryOrderedByKey().queryEqual(toValue: followedUserId).observe(.value, with: { snapshot in
                            if let pictures = snapshot.value as? [String: [String: [String: String]]] {
                                for (_, value) in pictures {
                                    for (picId, pictureInfo) in value {
                                        let picture = Picture()
                                        picture.url = pictureInfo["url"]
                                        picture.username = pictureInfo["username"]
                                        picture.timestamp = CLong(picId)!
                                        if !self.pictures.contains(where: { (p) -> Bool in
                                            return p.url == picture.url
                                        }) {
                                            self.pictures.append(picture)
                                        }
                                    }
                                }
                            }
                            self.pictures = self.pictures.sorted(by: { $0.timestamp > $1.timestamp })
                            self.pictureTableView.reloadData()
                        })
                    }
                }
            
        })
    }
    
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        defer {
            let manager = FBSDKLoginManager()
            manager.logOut()
            
            UserDefaults.standard.removeObject(forKey: "userLoggedIn")
            UserDefaults.standard.synchronize()
            
            let signUp = self.storyboard?.instantiateViewController(withIdentifier: "LogInViewController") as! LogInViewController
            let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
            
            delegate.window?.rootViewController = signUp
            delegate.rememberLogin()
            
            
        }
        do {
            try Auth.auth().signOut()
        } catch {
            print("error: can not log out")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictures.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PictureCell") as! PictureTableViewCell
        let picture = pictures[indexPath.item]
        
        cell.pictureImageView.image = UIImage()
        cell.username.text = picture.username
        cell.pictureImageView.downloadImage(from: picture.url!)
    
        return cell
    }
}
