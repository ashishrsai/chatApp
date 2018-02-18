//
//  tableViewController.swift
//  chatApp
//
//  Created by Ashutosh Kumar sai on 17/02/18.
//  Copyright © 2018 Ashish Kumar sai. All rights reserved.
//

import UIKit

class tableViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate {
    

    @IBOutlet weak var testLable: UILabel!
    @IBOutlet weak var chatTable: UITableView!
    @IBOutlet weak var messageField: UITextField!
    var username: String!
    var chatMessages = [[String : AnyObject]]()
    let imagePicker = UIImagePickerController()
    var imageView: UIImage = #imageLiteral(resourceName: "imageAshish")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        if let nameToDisplay = username {
            testLable.text = nameToDisplay
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
       
        socketManager.sockets.getChatMessage { (messageInfo) -> Void in
            DispatchQueue.main.async {
                self.chatMessages.append(messageInfo as [String : AnyObject])
                self.chatTable.reloadData()
            }
        }
        
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
        let messageDate = currentChatMessage["date"] as! String
        
        if senderNickname == username {
            cell.messageTextCell.textAlignment = NSTextAlignment.right
            cell.userDataCell.textAlignment = NSTextAlignment.right
        
            
        }
        
        if(imageView != #imageLiteral(resourceName: "imageAshish")){
            cell.sendImage.image = imageView
        }
        cell.messageTextCell.text = message
        cell.userDataCell.text = "by \(senderNickname.uppercased()) @ \(messageDate)"
        return cell
    }
    
   
    @IBAction func sendMessageButtonAction(_ sender: Any) {
        if (messageField.text?.isEmpty)!{
            print("No text to send")
        }else{
            socketManager.sockets.sendMessage(message: messageField.text!, withNickName: username)
            messageField.text = ""
            messageField.resignFirstResponder()
        }
    }
    
    
    @IBAction func sendImageAction(_ sender: Any) {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
}
