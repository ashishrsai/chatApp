//
//  tableViewController.swift
//  chatApp
//
//  Created by Ashutosh Kumar sai on 17/02/18.
//  Copyright © 2018 Ashish Kumar sai. All rights reserved.
//

import UIKit
import CryptoSwift

class tableViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    

    @IBOutlet weak var turnEncryptionOnButtonText: UIButton!
    @IBOutlet weak var testLable: UILabel!
    @IBOutlet weak var chatTable: UITableView!
    @IBOutlet weak var messageField: UITextField!
    var username: String!
    var chatMessages = [[String : AnyObject]]()
    let imagePicker = UIImagePickerController()
    var imageView: UIImage = #imageLiteral(resourceName: "imageAshish")
    var didSendAnImage = ""
    var didSelectANewImage = 0
    var dataForImage = ""
    var checkEncryption = 0
    var encryptedMessage = " "
    var encryptedUsername = " "
    var encryptedImage = " "
    var mutualKey = " "
    //CODE FOR MUTUAL KEY GEN
    var users = [[String: AnyObject]]()
    var keyMessages = [[String : AnyObject]]()
    var keyMessageString = " "
    let challengeByUserA = "asdfghjk"
    var challengeByUserb = " "
    var finalMutualKey = " "
    //CODE ENDS FOR MUTUAL KEY GEN
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let nameToDisplay = username {
            testLable.text = nameToDisplay
        }
        
        if(checkEncryption == 0){
            turnEncryptionOnButtonText.setTitle("Turn Encryption On", for: .normal)
        }else{
            turnEncryptionOnButtonText.setTitle("Turn Encryption Off", for: .normal)
        }
        
        //CODE FOR MUTUAL KEY GEN
        socketManager.sockets.getMutualKeyMessage { (messageInfo) -> Void in
            DispatchQueue.main.async {
                self.keyMessages.append(messageInfo as [String : AnyObject])
                print("Mutual Key Message Got it")
                print(self.keyMessages[self.keyMessages.count-1])
                self.callTheRightMethod()
            }
        }
        //CODE FOR MUTUAL KEY GEN ENDS HERE
        
        
        print("THIS IS WHAT YOU NEED TO READ",checkEncryption)
        socketManager.sockets.getChatMessage { (messageInfo) -> Void in
            DispatchQueue.main.async {
                
                self.chatMessages.append(messageInfo as [String : AnyObject])
                self.chatTable.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillAppear(_ animated: Bool) {
        
        //configureTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
       
        
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        moveTextField(textField, moveDistance: -250, up: true)
    }
    

    func textFieldDidEndEditing(_ textField: UITextField) {
        moveTextField(textField, moveDistance: -250, up: false)
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func moveTextField(_ textField: UITextField, moveDistance: Int, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    
    func configureChatTable(){
        chatTable.delegate = self
        chatTable.dataSource = self
        chatTable.estimatedRowHeight = 90.0
        chatTable.rowHeight = UITableViewAutomaticDimension
        chatTable.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! prototypeTableViewCell
        
        let currentChatMessage = chatMessages[indexPath.row]
        let senderNickname = currentChatMessage["nickname"] as! String
        let message = currentChatMessage["message"] as! String
        var imageData = currentChatMessage["imageData"] as! String
        let isEncryptionOn = currentChatMessage["isEncryptionOn"] as! String
        let hash = currentChatMessage["hash"] as! String
        let messageDate = currentChatMessage["date"] as! String
        let hashForImageData = imageData
        
        if(isEncryptionOn == "1"){
            do{
                print("MUTUAL KEY SEE THIS",mutualKey)
                let aes = try AES(key: mutualKey, iv: "drowssapdrowssap")
                //for message
                let messageData = Data(base64Encoded: message)
                let defaultMessageForm = [UInt8](messageData!)
                let plainMessageText = try aes.decrypt(defaultMessageForm)
                let plainMessageStr:String = String(bytes: plainMessageText, encoding: String.Encoding.utf8)!
                //for username
                let usernamedata = Data(base64Encoded: senderNickname)
                let defaultUsernameForm = [UInt8](usernamedata!)
                let plainUsernameText = try aes.decrypt(defaultUsernameForm)
                let usernameStr:String = String(bytes: plainUsernameText, encoding: String.Encoding.utf8)!
                //for image
                if(imageData == " "){
                    imageData = " "
                }else{
                    
                    let imagedata = Data(base64Encoded: imageData)
                    let defaultImageForm = [UInt8](imagedata!)
                    let plainImageText = try aes.decrypt(defaultImageForm)
                    let imageStr:String = String(bytes: plainImageText, encoding: String.Encoding.utf8)!
                    imageData = imageStr

                }
                
                if usernameStr == username {
                    cell.messageTextCell.textAlignment = NSTextAlignment.right
                    cell.userDataCell.textAlignment = NSTextAlignment.right
                }
                let checkHashString = message+hashForImageData
                print("Hash MSG TABLE",checkHashString)

                let hashOfPlainTextThatWeHave = checkHashString.sha256()
                print("Hash TABLE",hashOfPlainTextThatWeHave)
                if(hashOfPlainTextThatWeHave == hash){
                    print("Data is the same")
                }else{
                    print("hash does not match")
                }
                cell.messageTextCell.text = plainMessageStr
                cell.userDataCell.text = "by \(usernameStr.uppercased()) @ \(messageDate)"
                
                
            }catch{
                print("Error in decryption")
            }
            
        } else{
            if senderNickname == username {
                cell.messageTextCell.textAlignment = NSTextAlignment.right
                cell.userDataCell.textAlignment = NSTextAlignment.right
            }
            
            cell.messageTextCell.text = message
            cell.userDataCell.text = "by \(senderNickname.uppercased()) @ \(messageDate)"
        }
      
        
        /*
        print("I am called")
        if(imageView != #imageLiteral(resourceName: "imageAshish")){
            print("I am called 3")
            didSendAnImage = 1
        }
        if(didSendAnImage == 0){
            print("I am called2")
            cell.imageButton.isHidden = true
        }else {
            cell.imageButton.isHidden = false
            didSendAnImage = 0
        }
         */
        
       
        return cell
    }
    
   
    @IBAction func sendMessageButtonAction(_ sender: Any) {
        if (messageField.text?.isEmpty)!{
            print("No text to send")
        }else{
            
            if(didSelectANewImage == 1){
                dataForImage = didSendAnImage
                didSelectANewImage = 0
                print("THE VALUE YOU WANT",didSelectANewImage)
            }else{
                dataForImage = " "
            }
            
            if(checkEncryption == 1){
                //AES
                do{
                    let aes = try AES(key: mutualKey, iv: "drowssapdrowssap")
                    let cipherMessagetext = try aes.encrypt(Array(messageField.text!.utf8))
                    let encryptedMessageData = Data(cipherMessagetext)
                    encryptedMessage = encryptedMessageData.base64EncodedString()
                    //Now we will encrypt the username
                    let cipherUsernametext = try aes.encrypt(Array(username.utf8))
                    let encryptedUsernameData = Data(cipherUsernametext)
                    encryptedUsername = encryptedUsernameData.base64EncodedString()
                    //Now we will encrypt image if a new image has been attached
                    if(dataForImage != " "){
                        print("INSIDE IMAGE ENCRYPTION")
                        print("INSIDE PRINT FOR DATA ",dataForImage)
                        let cipherImagetext = try aes.encrypt(Array(dataForImage.utf8))
                        print("INSIDE AFTER ENCRYPT",cipherImagetext)
                        let encryptedImageData = Data(cipherImagetext)
                        encryptedImage = encryptedImageData.base64EncodedString()
                        print("INSIDE AND ITS DONE",encryptedImage)
                    } else {
                        encryptedImage = " "
                    }
                    
                }catch{
                    print("Encryption Failed ")
                }
                let completeMessage = encryptedMessage+encryptedImage
                print("Hash MSG",completeMessage)
                let hashOfCompleteMessage = completeMessage.sha256()
                print("Hash SENDBUTTON",hashOfCompleteMessage)
                socketManager.sockets.sendMessage(message: encryptedMessage, withNickName: encryptedUsername,imageData: encryptedImage,isEncryptionOn: "1",hash: hashOfCompleteMessage)

            }else {
                print("Check encryption is 0 and I am in else")
                socketManager.sockets.sendMessage(message: messageField.text!, withNickName: username,imageData: dataForImage,isEncryptionOn: "0", hash: " ")
            }
            
            messageField.text = ""
            
            messageField.resignFirstResponder()
        }
    }
    
    
    @IBAction func sendImageAction(_ sender: Any) {
        let imagecontroller = UIImagePickerController()
        imagecontroller.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        imagecontroller.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imagecontroller, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageView = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
        let image = UIImagePNGRepresentation(imageView) as NSData?
        didSendAnImage = image!.base64EncodedString()
        messageField.text = "Image File Attached"
        didSelectANewImage = 1
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let imageVC = storyBoard.instantiateViewController(withIdentifier: "imageVCS") as! imageViewController
        
        let currentChatMessage = chatMessages[indexPath.row]
        let senderNickname = currentChatMessage["nickname"] as! String
        let message = currentChatMessage["message"] as! String
        var imageData = currentChatMessage["imageData"] as! String
        let isEncryptionOn = currentChatMessage["isEncryptionOn"] as! String
        let messageDate = currentChatMessage["date"] as! String
        print("READ THIS",senderNickname,message,messageDate)
        
        if(isEncryptionOn == "1"){
            do{
                let aes = try AES(key: mutualKey, iv: "drowssapdrowssap")
                //for message
                let messageData = Data(base64Encoded: message)
                let defaultMessageForm = [UInt8](messageData!)
                let plainMessageText = try aes.decrypt(defaultMessageForm)
                let plainMessageStr:String = String(bytes: plainMessageText, encoding: String.Encoding.utf8)!
                //for username
                let usernamedata = Data(base64Encoded: senderNickname)
                let defaultUsernameForm = [UInt8](usernamedata!)
                let plainUsernameText = try aes.decrypt(defaultUsernameForm)
                let usernameStr:String = String(bytes: plainUsernameText, encoding: String.Encoding.utf8)!
                //for image
                if(imageData == " "){
                    imageData = " "
                }else{
                    
                    let imagedata = Data(base64Encoded: imageData)
                    let defaultImageForm = [UInt8](imagedata!)
                    let plainImageText = try aes.decrypt(defaultImageForm)
                    let imageStr:String = String(bytes: plainImageText, encoding: String.Encoding.utf8)!
                    imageData = imageStr
                    
                }
                
                imageVC.detailOfImage = "by \(usernameStr.uppercased()) @ \(messageDate)"
                //imageVC.imageForSelectedImage = imageView
                if(imageData == " "){
                    imageVC.selectModeOfImageSelection = 1
                }else{
                    imageVC.byteToImageValue = imageData
                }
                
            
            }catch{
                print("Error in decryption")
            }
            
          
            
            
        } else{
           
            imageVC.detailOfImage = "by \(senderNickname.uppercased()) @ \(messageDate)"
            //imageVC.imageForSelectedImage = imageView
            if(imageData == " "){
                imageVC.selectModeOfImageSelection = 1
            }else{
                imageVC.byteToImageValue = imageData
            }

        }
        
        
        
        self.navigationController?.pushViewController(imageVC, animated: true)
    }
    
    
    @IBAction func turnEncryptionOnButtonAction(_ sender: Any) {
        if(checkEncryption == 0){
            if(mutualKey == " "){
                mutualKeyGeneration()
            }else{
                print("There is already a mutual key")
            }
            turnEncryptionOnButtonText.setTitle("Turn Encryption Off", for: .normal)
            checkEncryption = 1
        }else{
            turnEncryptionOnButtonText.setTitle("Turn Encryption On", for: .normal)
            checkEncryption = 0
        }
    }
    
    //Code for mutual key generation if not already generated
    //CODE STARTS HERE
    func mutualKeyGeneration() {
        let integrityForMesssageOne = cryptographicModel.cryptoModel.asymmetricRSASign(key: "private", message: challengeByUserA)
        let messageToEncryptInStepOne = challengeByUserA+","+integrityForMesssageOne
        let finalOutputOfStepOne = cryptographicModel.cryptoModel.asymmetricRSAEncryption(key: "public1", message: messageToEncryptInStepOne)
        print("NOTE THIS TOO",finalOutputOfStepOne)
        socketManager.sockets.establishMutualKeys(message: finalOutputOfStepOne, withNickName: username,idtype: "1")
    }
    
    func callTheRightMethod(){
        
        let currentMutualKeyMessage = keyMessages[keyMessages.count-1]
        let idtype = currentMutualKeyMessage["idtype"] as! String
        let usernameFromServer = currentMutualKeyMessage["username"] as! String
        let message = currentMutualKeyMessage["message"] as! String
        
        if(usernameFromServer != username){
            if(idtype == "1"){
               
                performStepTwo()
            }else if(idtype == "2"){
                funtionForIDTypeTwo()
            }else if(idtype == "3"){
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
        var mutualKeys = challengeByUserA+challengeFromTheOtherUser
        //Now we create hash of the mutualkey and take out first 16 chars to have the actual mutual key
        let randomVar = mutualKeys.sha256()
        let startIndex = randomVar.index(randomVar.startIndex, offsetBy: 16)
        let finalHashOfMutualKey = String(randomVar[..<startIndex])
        print("CHECK",finalHashOfMutualKey,finalHashOfMutualKey.count)
        let finalMutualKeys = finalHashOfMutualKey
        mutualKeys = finalMutualKeys
        
        print("OUR MUTUAL KEY",mutualKeys)
        print("OUR ALL DATA",challengeFromTheOtherUser)
        
        print("3rd VALUE FROM THE SERVER",hashOfBothOfTheChallengeSigned)
        //Now that we have to create hash of 1 and 2 and use the 3 to verify if its same with signature
        let FirstAndSecondValueFromString = challengeFromTheOtherUser+","+challengeEncrpytedWithMutualKey
        //TESTING
        
        print("LOOK AT THIS",FirstAndSecondValueFromString)
        //TESTING ENDS
        let finalAnswer = cryptographicModel.cryptoModel.asymmetricRSAVerify(key: "public1", message: FirstAndSecondValueFromString, textToVerify: hashOfBothOfTheChallengeSigned )
        print(finalAnswer)
        let testValue = cryptographicModel.cryptoModel.symmetricAESEncryption(key: mutualKeys, message: "asdfghjk")
        print("Test Value = ",testValue)
        //if finalAnswer is true we move on to decrypt the message to get a response to our challenge
        //Response to the challenge of other user
        let responseToTheChellenge = cryptographicModel.cryptoModel.symmetricAESEncryption(key: mutualKeys, message: challengeFromTheOtherUser)
        if(finalAnswer == true){
            let response = cryptographicModel.cryptoModel.symmetricAESDecryption(key: mutualKeys, message: challengeEncrpytedWithMutualKey)
            print("Response",response)
            finalMutualKey = mutualKeys
            mutualKey = finalMutualKey
            //labeForMutualKeyUpdate.text = "Mutual Key generation in done"
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
            //labeForMutualKeyUpdate.text = "Mutual Key generation in done"
            mutualKey = finalMutualKey
            print("SUCESSS")
        }else{
            print("Something went wrong")
        }
        
        
    }
    //Code for mutual key generation ends here
    
    
    
    
}
