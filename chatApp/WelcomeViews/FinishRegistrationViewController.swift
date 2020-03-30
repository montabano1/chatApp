//
//  FinishRegistrationViewController.swift
//  chatApp
//
//  Created by michael montalbano on 3/19/20.
//  Copyright © 2020 michael montalbano. All rights reserved.
//

import UIKit
import ProgressHUD

class FinishRegistrationViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var titleView = UIView()
    var titleLabel = UILabel()
    var cancelButton = UIButton()
    var doneButton = UIButton()
    var separatorView = UIView()
    var avatarImageView = UIImageView()
    var choosePictureButton = UIButton()
    var firstNameTextField = UITextField()
    var lastNameTextField = UITextField()
    var phoneLabel = UILabel()
    var phoneNumberTextField = UITextField()
    var organizationLabel = UILabel()
    var organizationTextField = UITextField()
    var teamLabel = UILabel()
    var teamTextField = UITextField()
    var email: String?
    var password: String?
    var termsLabel = UILabel()
    var termsSwitch = UISwitch()
    var termsButton = UIButton()
    var avatarImage: UIImage?
    
    var width: Double = 0
    var height: Double = 0
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return .portrait
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(email, password)
        width = Double(view.bounds.width)
        height = Double(view.bounds.height)
        titleView.frame = CGRect(x: 0, y: 0, width: width, height: height * 0.15)
        titleView.backgroundColor = #colorLiteral(red: 0.9410942197, green: 0.9412292838, blue: 0.9410645366, alpha: 1)
        view.addSubview(titleView)
        titleLabel.frame = CGRect(x: 0, y: 0, width: width/2, height: 50)
        titleLabel.text = "Profile"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 40)
        titleLabel.textAlignment = .center
        titleLabel.sizeToFit()
        titleLabel.center = titleView.center
        titleView.addSubview(titleLabel)
        cancelButton.frame = CGRect(x: 25, y: 0, width: 100, height: 50)
        cancelButton.setTitle("Cancel", for: [])
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        cancelButton.sizeToFit()
        cancelButton.setTitleColor(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), for: [])
        cancelButton.center.x = titleLabel.frame.minX / 2
        cancelButton.center.y = titleView.center.y
        cancelButton.addTarget(self, action: #selector(cancelButtonPressed), for: .touchUpInside)
        cancelButton.isUserInteractionEnabled = true
        titleView.addSubview(cancelButton)
        doneButton.frame = CGRect(x: width - 100, y: 0, width: 100, height: 50)
        doneButton.setTitle("Register", for: [])
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        doneButton.sizeToFit()
        doneButton.setTitleColor(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), for: [])
        doneButton.center.x = (titleLabel.frame.maxX + CGFloat(width)) / 2
        doneButton.center.y = titleView.center.y
        doneButton.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
        doneButton.isUserInteractionEnabled = true
        titleView.addSubview(doneButton)
        var separatorY = Double(titleView.frame.maxY)
        separatorView.frame = CGRect(x: 0, y: separatorY, width: width, height: 20)
        separatorView.backgroundColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        view.addSubview(separatorView)
        
        var avatarY = Double(separatorView.frame.maxY)
        avatarImageView.frame = CGRect(x: 30, y: avatarY + 20, width: width / 4, height: width / 4)
        avatarImageView.image = UIImage(named: "avatarPlaceholder")
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        avatarImageView.layer.masksToBounds = true
        view.addSubview(avatarImageView)
        
        firstNameTextField.frame = CGRect(x: Double(avatarImageView.frame.maxX) + 40, y: avatarY + 20, width: Double(width / 2), height: 40)
        firstNameTextField.layer.borderWidth = 1
        firstNameTextField.placeholder = "First Name"
        firstNameTextField.layer.cornerRadius = 5
        firstNameTextField.setLeftPaddingPoints(10)
        firstNameTextField.keyboardType = .namePhonePad
        firstNameTextField.autocorrectionType = .no
        view.addSubview(firstNameTextField)
        
        lastNameTextField.frame = CGRect(x: Double(avatarImageView.frame.maxX) + 40, y: Double(firstNameTextField.frame.maxY + 20), width: Double(width / 2), height: 40)
        lastNameTextField.layer.borderWidth = 1
        lastNameTextField.placeholder = "Last Name"
        lastNameTextField.layer.cornerRadius = 5
        lastNameTextField.setLeftPaddingPoints(10)
        lastNameTextField.keyboardType = .namePhonePad
        lastNameTextField.autocorrectionType = .no
        view.addSubview(lastNameTextField)
        
        choosePictureButton.frame = CGRect(x: 0, y: Double(avatarImageView.frame.maxY + 5), width: width / 4, height: 20)
        choosePictureButton.setTitle("Choose Picture", for: [])
        choosePictureButton.setTitleColor(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), for: [])
        choosePictureButton.titleLabel?.textAlignment = .center
        choosePictureButton.sizeToFit()
        choosePictureButton.center.x = avatarImageView.center.x
        choosePictureButton.addTarget(self, action: #selector(profileImageButtonTapped), for: .touchUpInside)
        view.addSubview(choosePictureButton)
        
        phoneLabel.frame = CGRect(x: Double(choosePictureButton.frame.minX), y: Double(choosePictureButton.frame.maxY + 20), width: width/4, height: 40)
        phoneLabel.text = "Phone Number:"
        phoneLabel.font = UIFont.systemFont(ofSize: 20)
        phoneLabel.sizeToFit()
        view.addSubview(phoneLabel)
        phoneNumberTextField.frame = CGRect(x: Double(avatarImageView.frame.maxX) + 40, y: 0, width: Double(width / 2), height: 40)
        phoneNumberTextField.center.y = phoneLabel.center.y
        phoneNumberTextField.layer.borderWidth = 1
        phoneNumberTextField.placeholder = "123456789"
        phoneNumberTextField.layer.cornerRadius = 5
        phoneNumberTextField.setLeftPaddingPoints(10)
        phoneNumberTextField.keyboardType = .numberPad
        view.addSubview(phoneNumberTextField)
        
        organizationLabel.frame = CGRect(x: Double(choosePictureButton.frame.minX), y: Double(phoneLabel.frame.maxY + 30), width: width/4, height: 40)
        organizationLabel.text = "Organization:"
        organizationLabel.font = UIFont.systemFont(ofSize: 20)
        organizationLabel.sizeToFit()
        view.addSubview(organizationLabel)
        organizationTextField.frame = CGRect(x: Double(avatarImageView.frame.maxX) + 40, y: 0, width: Double(width / 2), height: 40)
        organizationTextField.center.y = organizationLabel.center.y
        organizationTextField.layer.borderWidth = 1
        organizationTextField.placeholder = "Not Required"
        organizationTextField.layer.cornerRadius = 5
        organizationTextField.setLeftPaddingPoints(10)
        organizationTextField.keyboardType = .namePhonePad
        organizationTextField.autocorrectionType = .no
        view.addSubview(organizationTextField)
        
        teamLabel.frame = CGRect(x: Double(choosePictureButton.frame.minX), y: Double(organizationLabel.frame.maxY + 30), width: width/4, height: 40)
        teamLabel.text = "Team:"
        teamLabel.font = UIFont.systemFont(ofSize: 20)
        teamLabel.sizeToFit()
        view.addSubview(teamLabel)
        teamTextField.frame = CGRect(x: Double(avatarImageView.frame.maxX) + 40, y: 0, width: Double(width / 2), height: 40)
        teamTextField.center.y = teamLabel.center.y
        teamTextField.layer.borderWidth = 1
        teamTextField.placeholder = "Not Required"
        teamTextField.layer.cornerRadius = 5
        teamTextField.setLeftPaddingPoints(10)
        teamTextField.keyboardType = .namePhonePad
        teamTextField.autocorrectionType = .no
        view.addSubview(teamTextField)
        
        termsLabel.frame = CGRect(x: Double(choosePictureButton.frame.minX), y: Double(teamLabel.frame.maxY + 30), width: 1, height: 40)
        termsLabel.text = "I agree to the "
        termsLabel.font = UIFont.systemFont(ofSize: 20)
        termsLabel.sizeToFit()
        view.addSubview(termsLabel)
        termsButton.frame = CGRect(x: Double(choosePictureButton.frame.minX), y: Double(termsLabel.frame.maxY), width: 1, height: 1)
        termsButton.setTitle("Terms & Conditions", for: [])
        termsButton.setTitleColor(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), for: [])
        termsButton.sizeToFit()
        termsButton.addTarget(self, action: #selector(goToTerms), for: .touchUpInside)
        view.addSubview(termsButton)
        termsSwitch.frame = CGRect(x: Int(width * 0.65), y: Int(termsLabel.frame.minY + 5), width: Int(width * 0.65), height: 50)
        view.addSubview(termsSwitch)
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.outsideTapped))
        view.addGestureRecognizer(tap)
        
    }
    
    @objc func goToTerms() {
        let vc1 = self.storyboard!.instantiateViewController(withIdentifier: "terms") as! TCViewController
        let navController = UINavigationController(rootViewController: vc1) //
        let backItem = UIBarButtonItem(title: "< Back", style: .plain, target: self, action: #selector(backAction))
        vc1.navigationItem.leftBarButtonItems = [backItem]
        self.present(navController, animated:true, completion: nil)
    }
    
    @objc func backAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func outsideTapped() {
        print("outside tapped")
        self.view.endEditing(true)
    }
    
        @objc func cancelButtonPressed() {
            cleanTextFields()
            self.dismiss(animated: true, completion: nil)
        }
    
        func cleanTextFields() {
            firstNameTextField.text = ""
            lastNameTextField.text = ""
            phoneNumberTextField.text = ""
            organizationTextField.text = ""
            teamTextField.text = ""
        }
        @IBAction func doneButtonPressed(_ sender: Any) {
            
            
            if !termsSwitch.isOn {
                ProgressHUD.showError("You must agree to terms and conditions")
                return
            } else {
                ProgressHUD.show("Registering...")
            
            if firstNameTextField.text != "" && lastNameTextField.text != "" && phoneNumberTextField.text != ""  {
                FUser.registerUserWith(email: email!, password: password!, firstName: firstNameTextField.text!, lastName: lastNameTextField.text!) { (error) in
                    if error != nil {
                        ProgressHUD.dismiss()
                        ProgressHUD.showError(error?.localizedDescription)
                        return
                    }
    
                    self.registerUser()
                }
            } else {
                ProgressHUD.showError("First name, last name and phone number are required")
            }
            }
        }
    
        func registerUser() {
            let fullname = firstNameTextField.text! + " " + lastNameTextField.text!
    
            var tempDictionary : Dictionary = [kFIRSTNAME : firstNameTextField.text!,
                                               kLASTNAME : lastNameTextField.text!,
                                               kFULLNAME : fullname,
                                               kORGANIZATION : organizationTextField.text!,
                                               kTEAM  : teamTextField.text!,
                                               kPHONE : phoneNumberTextField.text!] as [String:Any]
    
            if avatarImage == nil {
                imageFromInitials(firstName: firstNameTextField.text!, lastName: lastNameTextField.text!) { (avatarInitials) in
    
                    let avatarIMG = avatarInitials.jpegData(compressionQuality: 0.7)
                    let avatar = avatarIMG?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
    
                    tempDictionary[kAVATAR] = avatar
    
                    self.finishRegistration(withValues: tempDictionary)
                }
            } else {
    
                let avatarData = avatarImage?.jpegData(compressionQuality: 0.7)
                let avatar = avatarData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
    
                tempDictionary[kAVATAR] = avatar
    
                self.finishRegistration(withValues: tempDictionary)
    
            }
        }
    
        func finishRegistration(withValues: [String:Any]) {
            updateCurrentUserInFirestore(withValues: withValues) { (error) in
                if error != nil {
                    DispatchQueue.main.async {
                        ProgressHUD.showError(error!.localizedDescription)
                    }
                    print(error!.localizedDescription)
                    return
                }
    
                ProgressHUD.dismiss()
                self.goToApp()
            }
        }
    
        func goToApp() {
            cleanTextFields()
            dismissKeyboard()
    
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID : FUser.currentId()])
    
            let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "mainApplication") as! UITabBarController
    
            self.present(mainView, animated: true, completion: nil)
        }
    
        func dismissKeyboard() {
            self.view.endEditing(false)
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
            self.avatarImageView.image = editedImage.withRenderingMode(.alwaysOriginal)
            self.avatarImage = editedImage.withRenderingMode(.alwaysOriginal)
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.avatarImageView.image = originalImage.withRenderingMode(.alwaysOriginal)
            self.avatarImage = originalImage.withRenderingMode(.alwaysOriginal)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func profileImageButtonTapped() {
        print("Tapped button")
        showChooseSourceTypeAlertController()
    }
}
