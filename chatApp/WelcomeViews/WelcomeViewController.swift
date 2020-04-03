//
//  WelcomeViewController.swift
//  chatApp
//
//  Created by michael montalbano on 3/19/20.
//  Copyright © 2020 michael montalbano. All rights reserved.
//

import UIKit
import ProgressHUD

class WelcomeViewController: UIViewController, UITextFieldDelegate {
    
    var titleImageView = UIImageView()
    var titleLabel = UILabel()
    
    var emailTextField = UITextField()
    var passwordTextField = UITextField()
    var confirmTextField = UITextField()
    var loginButton = UIButton()
    var registerButton = UIButton()
    var width = 0
    var height = 0
    var registering = false
    var loggingIn = true
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return .portrait
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        width = Int(view.bounds.width)
        height = Int(view.bounds.height)
        let safeArea = UIApplication.shared.statusBarFrame.height
        titleImageView.frame = CGRect(x: 0, y: 30 + Int(safeArea), width: width/3, height: width/3)
        titleImageView.image = UIImage(named: "monTalkIcon")
        titleImageView.center.x = view.center.x
        view.addSubview(titleImageView)
        
        let titleLabelY = titleImageView.frame.maxY
        titleLabel.frame = CGRect(x: 0, y: Int(titleLabelY) + 5, width: width/3, height: 100)
        titleLabel.text = "monTalk"
        titleLabel.font = UIFont(name: "Chalkduster", size: 25)
        titleLabel.textAlignment = .center
        titleLabel.sizeToFit()
        titleLabel.center.x = view.center.x
        view.addSubview(titleLabel)
        
        let emailY = titleLabel.frame.maxY
        emailTextField.frame = CGRect(x: 0, y: Int(emailY) + 20, width: width - 50, height: 30)
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.cornerRadius = 5
        emailTextField.placeholder = "Email"
        emailTextField.center.x = view.center.x
        emailTextField.setLeftPaddingPoints(10)
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        view.addSubview(emailTextField)
        
        var passwordY = emailTextField.frame.maxY
        passwordTextField.frame = CGRect(x: 0, y: Int(passwordY) + 15, width: width - 50, height: 30)
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.cornerRadius = 5
        passwordTextField.placeholder = "Password"
        passwordTextField.center.x = view.center.x
        passwordTextField.setLeftPaddingPoints(10)
        passwordTextField.isSecureTextEntry = true
        passwordTextField.autocapitalizationType = .none
        view.addSubview(passwordTextField)
        
        var confirmY = passwordTextField.frame.maxY
        confirmTextField.frame = CGRect(x: 0, y: Int(confirmY) + 15, width: width - 50, height: 30)
        confirmTextField.layer.borderWidth = 1
        confirmTextField.layer.cornerRadius = 5
        confirmTextField.placeholder = "Confirm Password"
        confirmTextField.center.x = view.center.x
        confirmTextField.setLeftPaddingPoints(10)
        confirmTextField.isSecureTextEntry = true
        confirmTextField.isHidden = true
        confirmTextField.autocapitalizationType = .none
        view.addSubview(confirmTextField)
        
        var loginY = confirmTextField.frame.maxY
        loginButton.frame = CGRect(x: width / 4 - 15, y: Int(loginY) + 15, width: width/4, height: 50)
        loginButton.layer.borderWidth = 2
        loginButton.layer.borderColor = #colorLiteral(red: 0.5222101808, green: 0.9658307433, blue: 0.7536280751, alpha: 1)
        loginButton.layer.cornerRadius = 5
        loginButton.setTitle("Login", for: .normal)
        loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        loginButton.backgroundColor = #colorLiteral(red: 0.5222101808, green: 0.9658307433, blue: 0.7536280751, alpha: 1)
        loginButton.addTarget(self, action: #selector(loginHit), for: .touchUpInside)
        view.addSubview(loginButton)
        
        registerButton.frame = CGRect(x: width / 2 + 15, y: Int(loginY) + 15, width: width/4, height: 50)
        registerButton.layer.borderWidth = 2
        registerButton.layer.borderColor = #colorLiteral(red: 0.9931543469, green: 0.709420085, blue: 0.327634573, alpha: 1)
        registerButton.layer.cornerRadius = 5
        registerButton.setTitle("Register", for: .normal)
        registerButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        registerButton.setTitleColor(#colorLiteral(red: 0.9931543469, green: 0.709420085, blue: 0.327634573, alpha: 1), for: [])
        registerButton.addTarget(self, action: #selector(registerHit), for: .touchUpInside)
        view.addSubview(registerButton)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    @objc func loginHit() {
        self.view.endEditing(true)
        UIView.animate(withDuration: 0.5) {
            self.confirmTextField.isHidden = true
            self.registerButton.backgroundColor = .white
            self.registerButton.setTitleColor(#colorLiteral(red: 0.9931543469, green: 0.709420085, blue: 0.327634573, alpha: 1), for: [])
            self.loginButton.setTitleColor(.white, for: [])
            self.loginButton.backgroundColor = #colorLiteral(red: 0.5222101808, green: 0.9658307433, blue: 0.7536280751, alpha: 1)
        }
        if loggingIn {
            if emailTextField.text != "" && passwordTextField.text != "" {
            } else {
                ProgressHUD.showError("Email and/or Password is missing")
            }
            loginUser()
        }
        loggingIn = true
        registering = false
    }
    
    @objc func registerHit() {
        self.view.endEditing(true)
        UIView.animate(withDuration: 0.5) {
            self.confirmTextField.isHidden = false
            self.registerButton.backgroundColor = #colorLiteral(red: 0.9931543469, green: 0.709420085, blue: 0.327634573, alpha: 1)
            self.registerButton.setTitleColor(.white, for: [])
            self.loginButton.setTitleColor(#colorLiteral(red: 0.5222101808, green: 0.9658307433, blue: 0.7536280751, alpha: 1), for: [])
            self.loginButton.backgroundColor = .white
        }
        if registering {
            if emailTextField.text != "" && passwordTextField.text != "" && confirmTextField.text != "" {
                if passwordTextField.text == confirmTextField.text {
                    registerUser()
                } else {
                    ProgressHUD.showError("Passwords don't match")
                }
            } else {
                ProgressHUD.showError("All fields are required!")
            }
        }
        registering = true
        loggingIn = false
    }
    
    func loginUser() {
        ProgressHUD.show("Login...")
        
        FUser.loginUserWith(email: emailTextField.text!, password: passwordTextField.text!) { (error) in
            if error != nil {
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
        confirmTextField.text = ""
    }
    
    //MARK: GoToApp
    
    func goToApp() {
        ProgressHUD.dismiss()
        
        cleanTextFields()
        dismissKeyboard()
        
        
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID : FUser.currentId()])
        
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "initialOptions") as! UINavigationController
        
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

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
