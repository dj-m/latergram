//
//  RegisterController.swift
//  Latergram
//
//  Created by Domingo José Moronta on 4/17/16.
//  Copyright © 2016 Domingo José Moronta. All rights reserved.
//

import UIKit

protocol RegisterControllerDelegate: class {
    func registerControllerDidCancel(controller: RegisterController)
    func registerControllerDidFinish(controller: RegisterController, withEmail email: String)
}

class RegisterController: UIViewController {
    @IBOutlet weak var emailField: TranslucentTextField!
    @IBOutlet weak var passwordField: TranslucentTextField!
    @IBOutlet weak var usernameField: TranslucentTextField!
    @IBOutlet weak var registerButton: UIButton!
    weak var delegate: RegisterControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.placeholderText = "email"
        passwordField.placeholderText = "password"
        usernameField.placeholderText = "username"
        
        registerButton.layer.borderWidth = 1
        registerButton.layer.cornerRadius = 5
        registerButton.layer.borderColor = UIColor.lightTextColor().CGColor
        
        emailField.addTarget(self, action: #selector(RegisterController.textFieldDidChange(_:)), forControlEvents: .EditingChanged)
        passwordField.addTarget(self, action: #selector(RegisterController.textFieldDidChange(_:)), forControlEvents: .EditingChanged)
        usernameField.addTarget(self, action: #selector(RegisterController.textFieldDidChange(_:)), forControlEvents: .EditingChanged)
    }
    
    func textFieldDidChange(textfield: UITextField) {
        if let username = usernameField.text where !username.isEmpty,
            let password = passwordField.text where !password.isEmpty,
        let email = emailField.text where !email.isEmpty {
            registerButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            registerButton.enabled = true
        } else {
            registerButton.setTitleColor(UIColor.lightTextColor(), forState: .Normal)
            registerButton.enabled = false
        }
    }
    
    @IBAction func registerTapped(button: UIButton!) {
        guard let email = emailField.text where !email.isEmpty,
            let password = passwordField.text where !password.isEmpty,
            let username = usernameField.text where !username.isEmpty else {
            return
        }
        firebase.createUser(email, password: password, withValueCompletionBlock: { error, result in
            if error != nil {
                print("Error occurred during registration: \(error.localizedDescription)")
                return
            }
            guard let uid = result["uid"] as? String else {
                print("Invalid uid for user \(email)")
                return
            }
            usernameRef.childByAppendingPath(uid).setValue(username)
            profileRef.childByAppendingPath(username).setValue(["username": username])
            let alertController = UIAlertController(title:"Registration Success!", message: "Your account was successfully created with email \n\(email)", preferredStyle: .Alert)
            let dismissAction = UIAlertAction(title: "Got it", style: .Default, handler: {alertAction in
            //Return to login screen. Pass email back
                self.delegate?.registerControllerDidFinish(self, withEmail: email)
            })
            alertController.addAction(dismissAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        })
    }
    
    @IBAction func loginTapped(button: UIButton!) {
        delegate?.registerControllerDidCancel(self)
    }
}
