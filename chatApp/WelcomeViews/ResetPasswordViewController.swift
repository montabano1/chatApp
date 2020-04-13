//
//  ResetPasswordViewController.swift
//  monTalk
//
//  Created by michael montalbano on 4/8/20.
//  Copyright © 2020 michael montalbano. All rights reserved.
//

import UIKit
import ProgressHUD
import FirebaseAuth

class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var cancelbutton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetButton.layer.cornerRadius = 5
        resetButton.setTitle("Reset Password", for: .normal)
        resetButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        resetButton.backgroundColor = #colorLiteral(red: 0.5222101808, green: 0.9658307433, blue: 0.7536280751, alpha: 1)
        resetButton.setTitleColor(.white, for: [])
        
        cancelbutton.layer.cornerRadius = 5
        cancelbutton.setTitle("Cancel", for: .normal)
        cancelbutton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        cancelbutton.backgroundColor = #colorLiteral(red: 0.9931543469, green: 0.709420085, blue: 0.327634573, alpha: 1)
        cancelbutton.setTitleColor(.white, for: [])
       
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func resetPassword(_ sender: Any) {
        if emailField.text != "" {
            resetPassword(email: emailField.text!, onSuccess: {
                self.view.endEditing(true)
                ProgressHUD.showSuccess("A password reset email has been sent to \(self.emailField.text!)")
                self.dismiss(animated: true)
                
            }) { (errorMessage) in
                ProgressHUD.showError(errorMessage)
            }
        } else {
            ProgressHUD.showError("Email text field can not be blank")
        }
    }
    
    func resetPassword(email: String, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if error == nil {
                onSuccess()
            } else {
                onError(error!.localizedDescription)
            }
        }
    }

    @IBAction func cancelMe(_ sender: Any) {
        self.dismiss(animated: true)
    }
    

}
