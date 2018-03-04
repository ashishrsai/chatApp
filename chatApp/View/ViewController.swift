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
    @IBOutlet weak var labeForMutualKeyUpdate: UILabel!
    @IBOutlet weak var mutualKeyGenButton: UIButton!
    var isEncryptionOn = 0
    var username : String = ""
    var users = [[String: AnyObject]]()
    var keyMessages = [[String : AnyObject]]()
    var keyMessageString = " "
    let challengeByUserA = "asdfghjk"
    var challengeByUserb = " "
    var finalMutualKey = " "
    
    static let keyExchangeVar = ViewController()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
         
        socketManager.sockets.getMutualKeyMessage { (messageInfo) -> Void in
            DispatchQueue.main.async {
                self.keyMessages.append(messageInfo as [String : AnyObject])
                print("Mutual Key Message Got it")
                print(self.keyMessages[self.keyMessages.count-1])
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
            destination.mutualKey = finalMutualKey
            
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
        
            let integrityForMesssageOne = cryptographicModel.cryptoModel.asymmetricRSASign(key: "private", message: challengeByUserA)
            let messageToEncryptInStepOne = challengeByUserA+","+integrityForMesssageOne
            let finalOutputOfStepOne = cryptographicModel.cryptoModel.asymmetricRSAEncryption(key: "public1", message: messageToEncryptInStepOne)
            print("NOTE THIS TOO",finalOutputOfStepOne)
            labeForMutualKeyUpdate.text = "Initiating the session"
            mutualKeyGenButton.isEnabled = false
            socketManager.sockets.establishMutualKeys(message: finalOutputOfStepOne, withNickName: username,idtype: "1")
    }
    
    func callTheRightMethod(){
        
        let currentMutualKeyMessage = keyMessages[keyMessages.count-1]
        let idtype = currentMutualKeyMessage["idtype"] as! String
        let usernameFromServer = currentMutualKeyMessage["username"] as! String
        let message = currentMutualKeyMessage["message"] as! String
        
        if(usernameFromServer != username){
            if(idtype == "1"){
                mutualKeyGenButton.isEnabled = false
                labeForMutualKeyUpdate.text = "Initiating the session"
                performStepTwo()
            }else if(idtype == "2"){
                labeForMutualKeyUpdate.text = "Mutual Key generation in progress"
                mutualKeyGenButton.isEnabled = false
                funtionForIDTypeTwo()
            }else if(idtype == "3"){
                labeForMutualKeyUpdate.text = "Mutual Key generation in progress"
                mutualKeyGenButton.isEnabled = false
                finalFunctionForMutualKey()
            }else if(idtype == "4"){
                print("Type 4 called")
            }
    }
    

}
    func performStepTwo(){
        var mutualKey = " "
        let challengeByUserB = "qwertyui"
        challengeByUserb = challengeByUserB
        //Step 1 is to decrypt the message we just recieved from User A
        let currentMutualKeyMessage = keyMessages[0]
        let idtype = currentMutualKeyMessage["idtype"] as! String
        let usernameFromServer = currentMutualKeyMessage["username"] as! String
        let message = currentMutualKeyMessage["message"] as! String
        let decryptedMessageOfStepOneMessage = cryptographicModel.cryptoModel.asymmetricRSADecryption(key: "private1", message: message)
        print("READ THIS",decryptedMessageOfStepOneMessage)
        //Now we can take the two parts apart from the message and procceed with rest of the steps
        let messageRecivedArray = decryptedMessageOfStepOneMessage.components(separatedBy: ",")
        let challengeSentByUserA = messageRecivedArray[0]
        let hashedMessage = messageRecivedArray[1]
        let signedHashSentByUserA = cryptographicModel.cryptoModel.asymmetricRSAVerify(key: "public", message: challengeSentByUserA , textToVerify: hashedMessage)
        //if true generate mutual key
        if(signedHashSentByUserA == true){
            mutualKey = challengeSentByUserA+challengeByUserB
            print(mutualKey)
            //In order to get first 16 chars out of the hashed string
            print("CHECK THIS OUT MATE ")
            let randomVar = mutualKey.sha256()
            let startIndex = randomVar.index(randomVar.startIndex, offsetBy: 16)
            let finalHashOfMutualKey = String(randomVar[..<startIndex])
            print("CHECK",finalHashOfMutualKey,finalHashOfMutualKey.count)
            finalMutualKey = finalHashOfMutualKey
            mutualKey = finalMutualKey
        }
        //Now that we have the mutual key we can procced
        //now we have respond to the challenge of user A
        let responseToA = cryptographicModel.cryptoModel.symmetricAESEncryption(key: mutualKey, message: challengeSentByUserA)
        let messageToDigitallySign = challengeByUserB+","+responseToA
        print("READ THIS BROOOOO",mutualKey)
        let digitiallySignedHashOfAllMessagesInStepTwo = cryptographicModel.cryptoModel.asymmetricRSASign(key: "private1", message: messageToDigitallySign)
        let finalStringToEncrypt = challengeByUserB+","+responseToA+","+digitiallySignedHashOfAllMessagesInStepTwo
        let encryptingEverythingThatWeHaveInStepTwo = cryptographicModel.cryptoModel.asymmetricRSAEncryption(key: "public", message: finalStringToEncrypt)
        
          socketManager.sockets.establishMutualKeys(message: encryptingEverythingThatWeHaveInStepTwo, withNickName: username,idtype: "2")
    }
    
    func funtionForIDTypeTwo(){
        let currentMutualKeyMessage = keyMessages[1]
        let idtype = currentMutualKeyMessage["idtype"] as! String
        let usernameFromServer = currentMutualKeyMessage["username"] as! String
        let message = currentMutualKeyMessage["message"] as! String
        
        //We will decrypt the message so that we can get
        let decryptedMessage = cryptographicModel.cryptoModel.asymmetricRSADecryption(key: "private", message: message)
        print(decryptedMessage)
        
        var challengeFromTheOtherUser = " "
        var challengeEncrpytedWithMutualKey = " "
        var hashOfBothOfTheChallengeSigned = " "
        let messageRecivedFromOtherUserArray = decryptedMessage.components(separatedBy: ",")
        //1
        challengeFromTheOtherUser = messageRecivedFromOtherUserArray[0]
        //2
        challengeEncrpytedWithMutualKey = messageRecivedFromOtherUserArray[1]
        //3
        hashOfBothOfTheChallengeSigned = messageRecivedFromOtherUserArray[2]
        //Lets generate our mutual key here
        var mutualKey = challengeByUserA+challengeFromTheOtherUser
        //Now we create hash of the mutualkey and take out first 16 chars to have the actual mutual key
        let randomVar = mutualKey.sha256()
        let startIndex = randomVar.index(randomVar.startIndex, offsetBy: 16)
        let finalHashOfMutualKey = String(randomVar[..<startIndex])
        print("CHECK",finalHashOfMutualKey,finalHashOfMutualKey.count)
        let finalMutualKeys = finalHashOfMutualKey
        mutualKey = finalMutualKeys
        
        print("OUR MUTUAL KEY",mutualKey)
        print("OUR ALL DATA",challengeFromTheOtherUser)
        
        print("3rd VALUE FROM THE SERVER",hashOfBothOfTheChallengeSigned)
        //Now that we have to create hash of 1 and 2 and use the 3 to verify if its same with signature
        let FirstAndSecondValueFromString = challengeFromTheOtherUser+","+challengeEncrpytedWithMutualKey
        //TESTING
        
        print("LOOK AT THIS",FirstAndSecondValueFromString)
        //TESTING ENDS
        let finalAnswer = cryptographicModel.cryptoModel.asymmetricRSAVerify(key: "public1", message: FirstAndSecondValueFromString, textToVerify: hashOfBothOfTheChallengeSigned )
        print(finalAnswer)
        let testValue = cryptographicModel.cryptoModel.symmetricAESEncryption(key: mutualKey, message: "asdfghjk")
        print("Test Value = ",testValue)
        //if finalAnswer is true we move on to decrypt the message to get a response to our challenge
        //Response to the challenge of other user
        let responseToTheChellenge = cryptographicModel.cryptoModel.symmetricAESEncryption(key: mutualKey, message: challengeFromTheOtherUser)
        if(finalAnswer == true){
            let response = cryptographicModel.cryptoModel.symmetricAESDecryption(key: mutualKey, message: challengeEncrpytedWithMutualKey)
            print("Response",response)
            finalMutualKey = mutualKey
            labeForMutualKeyUpdate.text = "Mutual Key generation in done"
            socketManager.sockets.establishMutualKeys(message: responseToTheChellenge, withNickName: username,idtype: "3")

        }
        
        
        
    }
    
    func finalFunctionForMutualKey(){
        
        //This is where we will save the mutual key for the other user
        let currentMutualKeyMessage = keyMessages[2]
        let idtype = currentMutualKeyMessage["idtype"] as! String
        let usernameFromServer = currentMutualKeyMessage["username"] as! String
        let message = currentMutualKeyMessage["message"] as! String
        
        let theOutputFromTheMessage = cryptographicModel.cryptoModel.symmetricAESDecryption(key: finalMutualKey, message: message)
        print("Something",theOutputFromTheMessage,challengeByUserb)
        if(theOutputFromTheMessage == challengeByUserb){
            labeForMutualKeyUpdate.text = "Mutual Key generation in done"
            print("SUCESSS")
        }else{
            print("Something went wrong")
        }
        
        
    }
    


}
