//
//  LeftMenu.swift
//  LeftSlideoutMenu
//
//  Created by Robert Chen on 8/5/15.
//  Copyright (c) 2015 Thorn Technologies. All rights reserved.
//

import UIKit
import CoreData

class LeftMenu: UITableViewController {
    
    @IBOutlet weak var userTitleUINavigationItem: UINavigationItem!
    
    var menuOptions = ["Crear Oferta", "Ajustes", "Ayuda", "Validar Empresa", "Eliminar Usuario", "Cerrar Sesión"]
    
    override func viewDidLoad() {
        userTitleUINavigationItem.title = MainScreen.userData.userNickname
    }
}

// MARK: - UITableViewDelegate methods

extension LeftMenu {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            NSNotificationCenter.defaultCenter().postNotificationName("openAddOffer", object: nil)
        case 1:
            NSNotificationCenter.defaultCenter().postNotificationName("openSettings", object: nil)
        case 2:
            NSNotificationCenter.defaultCenter().postNotificationName("openHelp", object: nil)
        case 3:
            let email = "admin@ofertapp.com"
            let url = NSURL(string: "mailto:\(email)")
            UIApplication.sharedApplication().openURL(url!)
        case 4:
            NSNotificationCenter.defaultCenter().postNotificationName("deleteUser", object: nil)
        case 5:
            NSNotificationCenter.defaultCenter().postNotificationName("logout", object: nil)
        default:
            print("indexPath.row:: \(indexPath.row)")
        }
        
        // also close the menu
        NSNotificationCenter.defaultCenter().postNotificationName("closeMenuViaNotification", object: nil)
    }
    
}

// MARK: - UITableViewDataSource methods

extension LeftMenu {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuOptions.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        cell.textLabel?.text = menuOptions[indexPath.row]
        cell.textLabel?.textColor = UIColor(red: 39/255, green: 154/255, blue: 15/255, alpha: 1)

        return cell
    }
    
}