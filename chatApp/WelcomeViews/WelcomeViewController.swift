//
//  WelcomeViewController.swift
//  chatApp
//
//  Created by michael montalbano on 3/19/20.
//  Copyright © 2020 michael montalbano. All rights reserved.
//

import UIKit
import ProgressHUD

class WelcomeViewController: UIViewController {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    //MARK: IBActions
    
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        dismissKeyboard()
        
        if emailTextField.text != "" && passwordTextField.text != "" {
        } else {
            ProgressHUD.showError("Email and/or Password is missing")
        }
        
        loginUser()
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        dismissKeyboard()
        if emailTextField.text != "" && passwordTextField.text != "" && repeatTextField.text != "" {
            
            if passwordTextField.text == repeatTextField.text {
                registerUser()
            } else {
                ProgressHUD.showError("Passwords don't match")
            }
            
            
        } else {
            ProgressHUD.showError("All fields are required!")
        }
    }
    
    
    @IBAction func backgroundTouched(_ sender: Any) {
        dismissKeyboard()
    }
    
    //MARK: HelperFunctions
    
    func loginUser() {
        ProgressHUD.show("Login...")
        
        FUser.loginUserWith(email: emailTextField.text!, password: passwordTextField.text!) { (error) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            self.goToApp()
        }
    }
    
    func registerUser() {
        
        
        performSegue(withIdentifier: "welcomeToFinishReg", sender: self)
        cleanTextFields()
        dismissKeyboard()
        
    }
    
    func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    func cleanTextFields() {
        emailTextField.text = ""
        passwordTextField.text = ""
        repeatTextField.text = ""
    }
    
    //MARK: GoToApp
    
    func goToApp() {
        ProgressHUD.dismiss()
        
        cleanTextFields()
        dismissKeyboard()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID : FUser.currentId()])
        
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "mainApplication") as! UITabBarController
        
        self.present(mainView, animated: true, completion: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "welcomeToFinishReg" {
            let vc = segue.destination as! FinishRegistrationViewController
            vc.email = emailTextField.text!
            vc.password = passwordTextField.text!
        }
    }
    
}
