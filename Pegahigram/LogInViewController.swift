//
//  LogInViewController.swift
//  Pegahigram
//
//  Created by Pedro Delmonte on 25/05/17.
//  Copyright © 2017 BTS. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FBSDKLoginKit

class LogInViewController: UIViewController, FBSDKLoginButtonDelegate {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    var db: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Database.database().reference()
        if Auth.auth().currentUser != nil {
            performSegue(withIdentifier: "LoginToMain", sender: nil)
        }

        let loginButton = FBSDKLoginButton()
        loginButton.readPermissions = ["email", "public_profile"]
        loginButton.center = view.center
        view.addSubview(loginButton)
        loginButton.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password, completion: {(user, error) in
                if user != nil {
                    UserDefaults.standard.set(Auth.auth().currentUser?.uid, forKey: "userLoggedIn")
                    UserDefaults.standard.synchronize()
                    let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    delegate.rememberLogin()
                }
            })
        }
    }
    
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error)
            return
        }
        getFacebookInfo()
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {        
    }
    
    func getFacebookInfo() {
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else { return }
        
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        
        Auth.auth().signIn(with: credentials, completion: { (user, error) in
            if error != nil {
                print("--------------", error)
                return
            }
            print("Succesful", user)
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"]).start { (connection, result, error) in
                if error != nil {
                    print("Facebook Graph exploded", error)
                } else {
                    if let resultDict = result as? NSDictionary{
                        if let userId = Auth.auth().currentUser?.uid  {
                            let userInfo = [
                                "uid": userId,
                                "username": resultDict["name"],
                                "email": resultDict["email"]
                            ]
                            
                            self.db.child("user").child(userId).setValue(userInfo)
                            UserDefaults.standard.set(Auth.auth().currentUser?.uid, forKey: "userLoggedIn")
                            UserDefaults.standard.synchronize()
                            let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                            delegate.rememberLogin()
                        }
                    }
                }
            }
        })
    }
}


