//
//  Ajustes.swift
//  Ofertapp
//
//  Created by Ernesto Fdez on 3/5/16.
//  Copyright © 2016 AE. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class Settings : UIViewController {
    
    @IBOutlet weak var nickNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var repeatNewPasswordTextField: UITextField!
    
    var id : String = ""
    var oldNickname : String = ""
    var version : Int = 0
    
    var userModel = UserModel!()
    let url: String = "https://users-ofertapp.herokuapp.com/todo/"
    
    override func viewDidLoad() {
        
        nickNameTextField.text = MainScreen.userData.userNickname
        oldNickname = MainScreen.userData.userNickname
        emailTextField.text = MainScreen.userData.userEmail
        version = MainScreen.userData.userVersion
        id = MainScreen.userData.userID        
    }
    
    func emailIsCorrect (email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(email)
    }
    
    func nicknameIsCorrect (nickname: String) -> Bool {
        var validNickname = true
        
        if !nickname.isEmpty && nickNameTextField.text != oldNickname {
            userModel = UserModel.loadUser(nickNameTextField.text!)
            
            //Comprobamos que no existe en la base de datos
            if userModel.nickName != "" {
                validNickname = false
            }
        }
        
        return validNickname
    }
    
    func passwordIsCorrect() -> Bool{
        var validPassword = true
        
        if !oldPasswordTextField.text!.isEmpty {
            userModel = UserModel.loadUser(oldNickname)
            
            if userModel.password == oldPasswordTextField.text {
                
                if !newPasswordTextField.text!.isEmpty && !repeatNewPasswordTextField.text!.isEmpty {
                    if newPasswordTextField.text != repeatNewPasswordTextField.text {
                        validPassword = false
                    } else if newPasswordTextField.text!.characters.count < 6 {
                        validPassword = false
                    } else {
                        validPassword = true
                    }
                } else {
                    validPassword = false
                }
            } else {
                validPassword = false
            }
        } else {
            validPassword = false
        }
        
        return validPassword
    }
    
    @IBAction func accept(sender: UIButton) {
        
        var updateUser = true
        
        if !nicknameIsCorrect(nickNameTextField.text!) || emailTextField.text!.isEmpty || !emailIsCorrect(self.emailTextField.text!) || !passwordIsCorrect() {
            updateUser = false
        }
        
        //Si los datos son validos crear la oferta, sino lanzar una alarma
        if updateUser {
            //Guardar la informacion en la base de datos
            
            let parameters : [String: AnyObject] = [
                "Name" : nickNameTextField.text!,
                "Email" : emailTextField.text!,
                "Password" : newPasswordTextField.text!,
                "Enterprise" : false,
                "__v": version
            ]
            
            Alamofire.request(.PUT, url + id, parameters: parameters) .responseJSON { response in
            }
            
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "¡Atención!", message:
                "Hay campos con errores o que se encuentran incompletos", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            
        }
    }
    
    @IBAction func close(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancel(sender: UIButton) {
        if !nickNameTextField.text!.isEmpty || !emailTextField.text!.isEmpty || !oldPasswordTextField.text!.isEmpty || !newPasswordTextField.text!.isEmpty || !repeatNewPasswordTextField.text!.isEmpty {
            let alertController = UIAlertController(title: "¡Atención!", message:
                "Tienes campos con información, ¿seguro que desea continuar?", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default,handler: {(alert: UIAlertAction!) in self.dismissViewControllerAnimated(true, completion: nil)}))
            alertController.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
}