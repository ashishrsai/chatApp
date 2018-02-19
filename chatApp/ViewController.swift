//
//  ViewController.swift
//  chatApp
//
//  Created by Ashutosh Kumar sai on 17/02/18.
//  Copyright © 2018 Ashish Kumar sai. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var encryptionOn: UISwitch!
    @IBOutlet weak var userNameTextField: UITextField!
    var isEncryptionOn = 0
    var username : String = ""
    var users = [[String: AnyObject]]()
    var keyMessages = [[String : AnyObject]]()
    var keyMessageString = " "
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        socketManager.sockets.getMutualKeyMessage { (messageInfo) -> Void in
            DispatchQueue.main.async {
                self.keyMessages.append(messageInfo as [String : AnyObject])
                self.keyMessageString = self.keyMessages[0].description
                self.callTheRightMethod()
            }
        }

        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destination = segue.destination as? tableViewController {
            destination.username = userNameTextField.text
            destination.checkEncryption = isEncryptionOn
        }
    }
        
    
    @IBAction func chatButtonAction(_ sender: Any) {
        if(userNameTextField.text?.isEmpty)!{
            print("It is empty can not do anything")
        }else{
            if(encryptionOn.isOn){
                isEncryptionOn = 1
            }else{
                isEncryptionOn = 0
            }
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
    
    
    //Action for Mutual Key Generation
    @IBAction func mutualKeyGeneration(_ sender: Any) {
            username = userNameTextField.text!
            let challengeByUserA = "asdfghjk"
            let integrityForMesssageOne = cryptographicModel.cryptoModel.asymmetricRSASign(key: "private", message: challengeByUserA)
            let finalOutputOfStepOne = cryptographicModel.cryptoModel.asymmetricRSAEncryption(key: "public1", message: integrityForMesssageOne)
            print("NOTE THIS TOO",finalOutputOfStepOne)
            let everythingAppendedString = "1"+","+username+","+finalOutputOfStepOne
        socketManager.sockets.establishMutualKeys(message: everythingAppendedString)
    }
    
    func callTheRightMethod(){
        
        print("Check this out",keyMessageString)
        
        let currentMutualKeyMessage = keyMessages[keyMessages.count-1]
        let idtype = currentMutualKeyMessage["idtype"] as! String
        let usernameFromServer = currentMutualKeyMessage["username"] as! String
        let message = currentMutualKeyMessage["message"] as! String
        
        if(usernameFromServer != username){
            if(idtype == "1"){
                performStepTwo()
            }else if(idtype == "2"){
                print("Type 2 called")
            }else if(idtype == "3"){
                print("Type 3 called")
            }else if(idtype == "4"){
                print("Type 4 called")
            }
    }
    

}
    func performStepTwo(){
        let challengeByUserB = "qwertyui"
        //Step 1 is to decrypt the message we just recieved from User A
        let currentMutualKeyMessage = keyMessages[0]
        let idtype = currentMutualKeyMessage["idtype"] as! String
        let usernameFromServer = currentMutualKeyMessage["username"] as! String
        let message = currentMutualKeyMessage["message"] as! String
        print("NOTE THIS",message)
        
        let decryptedMessageOfStepOneMessage = cryptographicModel.cryptoModel.asymmetricRSADecryption(key: "private1", message: message)
        print("READ THIS",decryptedMessageOfStepOneMessage)
    }

}
