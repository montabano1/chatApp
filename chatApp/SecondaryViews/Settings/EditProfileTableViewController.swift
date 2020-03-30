//
//  EditProfileTableViewController.swift
//  chatApp
//
//  Created by michael montalbano on 3/29/20.
//  Copyright © 2020 michael montalbano. All rights reserved.
//

import UIKit
import ProgressHUD

class EditProfileTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var saveButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var firstNameLabel: UITextField!
    
    @IBOutlet weak var lastNameLabel: UITextField!
    
    @IBOutlet weak var phoneLabel: UITextField!
    
    @IBOutlet weak var emailLabel: UITextField!
    
    @IBOutlet var tapgestureitem: UITapGestureRecognizer!
    
    var avatarImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        avatarImageView.clipsToBounds = true
        navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView()
        setupUI()

    }

    // MARK: - Table view data source

    @IBAction func saveButtonPressed(_ sender: Any) {
        if firstNameLabel.text != "" && lastNameLabel.text != "" &&
        emailLabel.text != "" &&
            phoneLabel.text != "" {
            ProgressHUD.show("Saving...")
            
            //block save button
            saveButtonOutlet.isEnabled = false
            let fullname = firstNameLabel.text! + " " + lastNameLabel.text!
            
            var withValues = [kFIRSTNAME : firstNameLabel.text!, kLASTNAME : lastNameLabel.text!, kFULLNAME : fullname, kEMAIL : emailLabel.text!, kPHONE : phoneLabel.text!]
            if avatarImage != nil {
                let avatarData = avatarImage!.jpegData(compressionQuality: 0.7)!
                let avatarString = avatarData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                withValues[kAVATAR] = avatarString
            }
            updateCurrentUserInFirestore(withValues: withValues) { (error) in
                if error != nil {
                    DispatchQueue.main.async {
                        ProgressHUD.showError(error!.localizedDescription)
                        self.saveButtonOutlet.isEnabled = true
                        print("couldn't update user \(error!.localizedDescription)")
                    }
                    return
                }
                ProgressHUD.showSuccess("Saved")
                self.saveButtonOutlet.isEnabled = true
                self.navigationController?.popViewController(animated: true)
            }
            
        } else {
            ProgressHUD.showError("All fields are required")
        }
    }
    
    @IBAction func avatarTapped(_ sender: Any) {
        showChooseSourceTypeAlertController()
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    func setupUI() {
        let currentUser = FUser.currentUser()!
        avatarImageView.isUserInteractionEnabled = true
        firstNameLabel.text = currentUser.firstname
        lastNameLabel.text = currentUser.lastname
        emailLabel.text = currentUser.email
        phoneLabel.text = currentUser.phoneNumber
        if currentUser.avatar != "" {
            imageFromData(pictureData: currentUser.avatar) { (avatarImage) in
                if avatarImage != nil {
                    self.avatarImageView.image = avatarImage!.circleMasked
                }
            }
        }
    }
    
    func showChooseSourceTypeAlertController() {
        let photoLibraryAction = UIAlertAction(title: "Choose a Photo", style: .default) { (action) in
            self.showImagePickerController(sourceType: .photoLibrary)
        }
        let cameraAction = UIAlertAction(title: "Take a New Photo", style: .default) { (action) in
            self.showImagePickerController(sourceType: .camera)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        AlertService.showAlert(style: .actionSheet, title: nil, message: nil, actions: [photoLibraryAction, cameraAction, cancelAction], completion: nil)
    }
    
    func showImagePickerController(sourceType: UIImagePickerController.SourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = sourceType
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.avatarImageView.image = editedImage.withRenderingMode(.alwaysOriginal).circleMasked
            self.avatarImage = editedImage.withRenderingMode(.alwaysOriginal)
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.avatarImageView.image = originalImage.withRenderingMode(.alwaysOriginal).circleMasked
            self.avatarImage = originalImage.withRenderingMode(.alwaysOriginal)
        }
        dismiss(animated: true, completion: nil)
    }


}
