//
//  Login.swift
//  Ofertapp
//
//  Created by Ernesto Fdez on 7/5/16.
//  Copyright © 2016 AE. All rights reserved.
//

import UIKit
import CoreData

class Login : UIViewController {
    
    @IBOutlet weak var nickNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var accessButton: UIButton!
    @IBOutlet weak var registrationButton: UIButton!
    
    @IBOutlet weak var passwordRecoveryButton: UIButton!
    
    var userModel = UserModel!()
    
    override func viewDidLoad() {
        accessButton.layer.cornerRadius = 15
        accessButton.layer.borderWidth = 2
        accessButton.layer.borderColor = UIColor(red: 0/255, green: 107/255, blue: 14/255, alpha: 1).CGColor
        
        registrationButton.layer.cornerRadius = 15
        registrationButton.layer.borderWidth = 2
        registrationButton.layer.borderColor = UIColor(red: 0/255, green: 107/255, blue: 14/255, alpha: 1).CGColor
        
        passwordRecoveryButton.layer.cornerRadius = 15
        passwordRecoveryButton.layer.borderWidth = 2
        passwordRecoveryButton.layer.borderColor = UIColor(red: 0/255, green: 107/255, blue: 14/255, alpha: 1).CGColor
    }
    
    @IBAction func access(sender: UIButton) {
        var acceso : Bool = true
        
        if nickNameTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            acceso = false
            
            let alertController = UIAlertController(title: "¡Atención!", message:
                "Hay campos sin rellenar.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            
            userModel = UserModel.loadUser(nickNameTextField.text!)
            if userModel.nickName != "" {
                if userModel.password != passwordTextField.text {
                    acceso = false
                    
                    let alertController = UIAlertController(title: "¡Atención!", message:
                        "La contraseña es incorrecta.", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default,handler: nil))
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            } else {
                acceso = false
                
                let alertController = UIAlertController(title: "¡Atención!", message:
                    "El nombre de usuario no existe.", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default,handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
        
        if acceso == true {
            
            // create an instance of our managedObjectContext
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let user = appDelegate.managedObjectContext
            
            // we set up our entity by selecting the entity and context that we're targeting
            let entity = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext: user) as! User
            
            // add our data
            entity.setValue(userModel.nickName, forKey: "nickname")
            entity.setValue(userModel.email, forKey: "email")
            entity.setValue(userModel.enterprise, forKey: "enterprise")
            entity.setValue(userModel.admin, forKey: "admin")
            entity.setValue(userModel.version, forKey: "version")
            entity.setValue(userModel.id, forKey: "id")
            
            // we save our entity
            do {
                try user.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
            
            performSegueWithIdentifier("openMainScreen", sender: nil)
        }
    }
    
    @IBAction func registration(sender: UIButton) {
        performSegueWithIdentifier("openRegistration", sender: nil)
    }
    
    @IBAction func recoveryPassword(sender: UIButton) {
        let email = "issues@ofertapp.com"
        let url = NSURL(string: "mailto:\(email)")
        UIApplication.sharedApplication().openURL(url!)
    }
}