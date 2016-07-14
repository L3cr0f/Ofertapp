//
//  Register.swift
//  Ofertapp
//
//  Created by Ernesto Fdez on 5/5/16.
//  Copyright © 2016 AE. All rights reserved.
//

import UIKit
import Alamofire

class Registration : UIViewController {
    
    @IBOutlet weak var nickNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    var userModel = UserModel!()
    let url: String = "https://users-ofertapp.herokuapp.com/todo"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func nicknameIsCorrect (nickname: String) -> Bool {
        var validNickname = false
        
        if !nickname.isEmpty {
            userModel = UserModel.loadUser(nickNameTextField.text!)
            
            //Comprobamos que no existe en la base de datos
            if userModel.nickName == "" {
                validNickname = true
            }
        }
        
        return validNickname
    }
    
    func emailIsCorrect (email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(email)
    }
    
    func passwordIsCorrect() -> Bool{
        var validPassword = true
        
        if passwordTextField.text != repeatPasswordTextField.text {
            validPassword = false
        } else if passwordTextField.text!.characters.count < 6 {
            validPassword = false
        }
        
        return validPassword
    }
    
    @IBAction func accept(sender: UIButton) {
        
        var createUser = true
        
        if !nicknameIsCorrect(nickNameTextField.text!) || emailTextField.text!.isEmpty || !emailIsCorrect(self.emailTextField.text!) || passwordTextField.text!.isEmpty || repeatPasswordTextField.text!.isEmpty || !passwordIsCorrect() {
            createUser = false
        }
        
        //Si los datos son validos crear la oferta, sino lanzar una alarma
        if createUser {
            //Guardar la informacion en la base de datos
            
            let parameters : [String: AnyObject] = [
                "Name" : nickNameTextField.text!,
                "Email" : emailTextField.text!,
                "Password" : passwordTextField.text!,
                "Enterprise" : false,
                "Admin": false
            ]
            
            Alamofire.request(.POST, url, parameters: parameters) .responseJSON { response in
            }
            
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "¡Atención!", message:
                "Hay campos con errores o que se encuentran incompletos", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func cancel(sender: UIButton) {
        if !nickNameTextField.text!.isEmpty || !emailTextField.text!.isEmpty || !passwordTextField.text!.isEmpty || !repeatPasswordTextField.text!.isEmpty {
            let alertController = UIAlertController(title: "¡Atención!", message:
                "Tienes campos con información, ¿seguro que desea continuar?", preferredStyle: UIAlertControllerStyle.Alert)
            //Llamo a finalizar edición para bloquear todos los campos
            alertController.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default,handler: {(alert: UIAlertAction!) in self.dismissViewControllerAnimated(true, completion: nil)}))
            //Si cancela no se pierde la edición
            alertController.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func close(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}