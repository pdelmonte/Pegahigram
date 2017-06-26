//
//  SecondViewController.swift
//  Pegahigram
//
//  Created by Pedro Delmonte on 18/05/17.
//  Copyright © 2017 BTS. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class SecondViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var picker = UIImagePickerController()
    var db: DatabaseReference!
    var databaseStorage: StorageReference!
    //var pictureURLs = [String]()
    var image: UIImage?
    
    
    
    @IBOutlet weak var picturePreview: UIImageView!
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            picker.sourceType = .camera
            picker.cameraDevice = .front
            present(picker, animated: true, completion: nil)
        }
    }
    
    func openGallery(){
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true)
        image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        if (image != nil) {
            self.picturePreview.image = image
            UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        }
    }
    
    
    
    @IBAction func selectAnotherMedia(_ sender: Any) {
        let alertViewController  = UIAlertController(title: "Want to display a pic?", message: "You can either select it or snap it", preferredStyle: .actionSheet)
        let galleryAction = UIAlertAction(title: "Choose from Gallery", style: .default, handler: { action in
            self.openGallery()
        })
        let cameraAction = UIAlertAction(title: "Take photo", style: .default, handler: { action in
            self.openCamera()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            print("Cancel")
        })
        alertViewController.addAction(galleryAction)
        alertViewController.addAction(cameraAction)
        alertViewController.addAction(cancelAction)
        present(alertViewController, animated: true, completion: nil)

    }
    
    @IBAction func postButtonPressed(_ sender: Any) {
        
        if (image != nil) {
        //upload picture to storage
            let jpeg = UIImageJPEGRepresentation(image!, 0.8)
            let name = self.db.child("picture").childByAutoId().key
            let timestamp = String(UInt64(NSDate().timeIntervalSince1970 * 1000.0))
            let imageRef = self.databaseStorage.child("\(name).jpg")
            let userId = Auth.auth().currentUser?.uid
            let username = Auth.auth().currentUser?.displayName
            //Get userID from Firebase
            let uploadTask = imageRef.putData(jpeg!, metadata: nil, completion: { (metadata, error) in
                imageRef.downloadURL(completion: {(url, error) in
                    self.db.child("picture").child(userId!).updateChildValues([timestamp: ["url": url?.absoluteURL.absoluteString, "username": username]])
                })
            })
            uploadTask.resume()
            self.performSegue(withIdentifier: "UploadToFeed", sender: nil)

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        
        db = Database.database().reference()
        let storage = Storage.storage().reference(forURL: "gs://pegahigram.appspot.com")
        databaseStorage = storage.child("picture")
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

