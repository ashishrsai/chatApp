//
//  ViewController.swift
//  chatApp
//
//  Created by Ashutosh Kumar sai on 17/02/18.
//  Copyright © 2018 Ashish Kumar sai. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var userNameTextField: UITextField!
    
    var username : String = ""
    var users = [[String: AnyObject]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destination = segue.destination as? tableViewController {
            destination.username = userNameTextField.text
        }
    }
        
    
    @IBAction func chatButtonAction(_ sender: Any) {
        if(userNameTextField.text?.isEmpty)!{
            print("It is empty can not do anything")
        }else{
            username = userNameTextField.text!
            print("USername is equal to",username)
            socketManager.sockets.connectUserToServer(nickname: username, completionHandler: { (userList) -> Void in
                DispatchQueue.main.async {
                    if userList != nil {
                        self.users = userList!
                    }
                }
            })
            
            performSegue(withIdentifier: "chatButtonSegue", sender: self)
            
        }
    }
    

}

