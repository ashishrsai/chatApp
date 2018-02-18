//
//  tableViewController.swift
//  chatApp
//
//  Created by Ashutosh Kumar sai on 17/02/18.
//  Copyright © 2018 Ashish Kumar sai. All rights reserved.
//

import UIKit

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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let nameToDisplay = username {
            testLable.text = nameToDisplay
        }
        
        socketManager.sockets.getChatMessage { (messageInfo) -> Void in
            DispatchQueue.main.async {
                print("THIS IS WHAT YOU NEED TO READ")
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
        let imageData = currentChatMessage["imageData"] as! String
        let messageDate = currentChatMessage["date"] as! String
        
        if senderNickname == username {
            cell.messageTextCell.textAlignment = NSTextAlignment.right
            cell.userDataCell.textAlignment = NSTextAlignment.right
        
            
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
        
        
        print(imageData)
        cell.messageTextCell.text = message
        cell.userDataCell.text = "by \(senderNickname.uppercased()) @ \(messageDate)"
        return cell
    }
    
   
    @IBAction func sendMessageButtonAction(_ sender: Any) {
        if (messageField.text?.isEmpty)!{
            print("No text to send")
        }else{
            
            if(didSelectANewImage == 1){
                dataForImage = didSendAnImage
                didSelectANewImage = 0
            }else{
                dataForImage = " "
            }
            socketManager.sockets.sendMessage(message: messageField.text!, withNickName: username,imageData: dataForImage)
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
        let imageData = currentChatMessage["imageData"] as! String
        let messageDate = currentChatMessage["date"] as! String
        print("READ THIS",senderNickname,message,messageDate)
        imageVC.detailOfImage = "by \(senderNickname.uppercased()) @ \(messageDate)"
        //imageVC.imageForSelectedImage = imageView
        imageVC.byteToImageValue = imageData
        self.navigationController?.pushViewController(imageVC, animated: true)
    }
    
    
    
    
}
