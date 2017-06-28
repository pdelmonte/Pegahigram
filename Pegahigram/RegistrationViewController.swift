//
//  RegistrationViewController.swift
//  Pegahigram
//
//  Created by Pedro Delmonte on 25/05/17.
//  Copyright © 2017 BTS. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class RegistrationViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var db: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Database.database().reference()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
               // Dispose of any resources that can be recreated.
    }
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text, let _ = userNameTextField.text {
            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                if let user = user {
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = self.userNameTextField.text ?? ""
                    changeRequest.commitChanges(completion: nil)
                    let userInfo = ["uid": user.uid,
                                    "username": self.userNameTextField.text ?? "",
                                    "email": self.emailTextField.text ?? ""
                    ]
                    self.db.child("user").child(user.uid).setValue(userInfo)
                    UserDefaults.standard.set(Auth.auth().currentUser?.uid, forKey: "userLoggedIn")
                    UserDefaults.standard.synchronize()
                    let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    delegate.rememberLogin()
                    self.view.endEditing(true)
                    
                } else {
                    self.showMessage(message: "Could not Login, please try again")
                    print("error: \(String(describing: error))")
                }
            }
        }
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func showMessage(message: String) {
        let alert = UIAlertController(title: "Message", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
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
