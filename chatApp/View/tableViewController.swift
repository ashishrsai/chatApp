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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let nameToDisplay = username {
            testLable.text = nameToDisplay
        }
        
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
    
    
    
    
}
