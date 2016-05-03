//
//  LoginController.swift
//  Latergram
//
//  Created by Domingo José Moronta on 4/17/16.
//  Copyright © 2016 Domingo José Moronta. All rights reserved.
//

import UIKit

class LoginController: UIViewController {
    @IBOutlet weak var usernameField: TranslucentTextField!
    @IBOutlet weak var passwordField: TranslucentTextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameField.placeholderText = "username"
        passwordField.placeholderText = "password"
        
        loginButton.layer.borderWidth = 1
        loginButton.layer.cornerRadius = 5
        loginButton.layer.borderColor = UIColor.lightTextColor().CGColor
        
        usernameField.addTarget(self, action: #selector(LoginController.textFieldDidChange(_:)), forControlEvents: .EditingChanged)
        passwordField.addTarget(self, action: #selector(LoginController.textFieldDidChange(_:)), forControlEvents: .EditingChanged)
    }
    
    func textFieldDidChange(textfield: UITextField) {
        if let username = usernameField.text where !username.isEmpty,
            let password = passwordField.text where !password.isEmpty {
            loginButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            loginButton.enabled = true
        } else {
            loginButton.setTitleColor(UIColor.lightTextColor(), forState: .Normal)
            loginButton.enabled = false
        }
    }
    
    func login(email: String, password: String) {
        firebase.authUser(email, password: password, withCompletionBlock: {error, result in if error != nil {
            print(error.localizedDescription)
            self.activityIndicator.stopAnimating()
            return
            }
            let uid = result.uid
            usernameRef.childByAppendingPath(uid).observeSingleEventOfType(.Value, withBlock: {snapshot in
                guard let username = snapshot.value as? String else {
                    print("No user found for \(email)")
                    self.activityIndicator.stopAnimating()
                    return
                }
                profileRef.childByAppendingPath(username).observeSingleEventOfType(.Value, withBlock: { snapshot in
                    self.activityIndicator.stopAnimating()
                    guard let profile = snapshot.value as? [String: AnyObject] else {
                        print("No profile found for the user")
                        return
                    }
                    Profile.currentUser = Profile.initWithUsername(username, profileDict: profile)
                    let mainSB = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                    let rootController = mainSB.instantiateViewControllerWithIdentifier("Tabs") // Initialize CenterTabBarController
                    self.presentViewController(rootController, animated: true, completion: nil)
                })
            })
        })
    }
    
    @IBAction func loginTapped(button: UIButton!) {
        guard let username = usernameField.text where !username.isEmpty,
            let password = passwordField.text where !password.isEmpty else {
                return
        }
        activityIndicator.startAnimating()
        login(username, password:password)
    }
    @IBAction func signupTapped(button: UIButton!) {
        let mainSB = UIStoryboard(name:"Main", bundle: NSBundle.mainBundle())
        let registerController = mainSB.instantiateViewControllerWithIdentifier("Register") as! RegisterController
        //Make sure to set register view controller id to 'Register'
        registerController.delegate = self
        presentViewController(registerController, animated: true, completion: nil)
    }
}

extension LoginController: RegisterControllerDelegate {
    func registerControllerDidCancel(controller: RegisterController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func registerControllerDidFinish(controller: RegisterController, withEmail email: String) {
        usernameField.text = email
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}