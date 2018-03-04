//
//  socketManager.swift
//  chatApp
//  This class is base for all socket communication used throughout the application
//  Created by Ashutosh Kumar sai on 17/02/18.
//  Copyright © 2018 Ashish Kumar sai. All rights reserved.
//

import UIKit
import SocketIO

//Setting up parameters for the URL of our socket
let manager = SocketManager(socketURL: URL(string: "http://192.168.43.196:3000")!, config: [.log(true), .compress])
let socket = manager.defaultSocket

class socketManager: NSObject {
    //We make this class singlton so that methods in this can be called by any other class
    static let sockets = socketManager()
    override init() {
        super.init()
    }
    
    /*
     * startConnection()
     * function used to establish connection with the socket, done on the app launch , called by AppDelegate.swift
     */
    
    func startConnection(){
        socket.connect()
    }
    
    /*
     * endConnection()
     * function used to end a connection with the socket, done when the app is pushed to background , called by AppDelegate.swift
     */
    func endConnection(){
        socket.disconnect()
    }
    
    /*
     * connectUserToServer(nickname: String, completionHandler: @escaping (_ userList: [[String: AnyObject]]?) -> Void)
     * function used to connect a user with username to the server
     *
     * parameter: key: nickname: String //This is the username of the user
     * return: void // A completion handler is used to in order to notify the calling function whenever a new user is connected with socket
     */

   
    func connectUserToServer(nickname: String, completionHandler: @escaping (_ userList: [[String: AnyObject]]?) -> Void) {
        socket.emit("connectUser", nickname)
        
        socket.on("userList") { ( dataArray, ack) -> Void in
            completionHandler(dataArray[0] as? [[String: AnyObject]])
        }
        
    }
   
    /*
     * sendMessage(message : String,withNickName nickname : String,imageData : String,isEncryptionOn : String,hash : String)
     * function used to send a message to the server by using socket.emit
     *
     * parameter: message : String, //Message that the user wish to send
     *            withNickName nickname : String, //this is the username of the user
                  imageData : String, // if image is sent with a message this variable is used
                  isEncryptionOn : String, // This is to notify the other user that the encryption is on or off
                  hash : String // this is the hash of message ussed to validate the integrity of message
     *
     * return: void // This will return nothing
     */

    
    //Used to send messages to the servers
    func sendMessage(message : String,withNickName nickname : String,imageData : String,isEncryptionOn : String,hash : String){
        socket.emit("chatMessage", nickname,message,imageData,isEncryptionOn,hash)
    }
    
    /*
     * getChatMessage()
     * function used to get new messages from the server and appned that to the messageDictionary of the calling function
     *
     * parameter: Completionhandler //Used to keep the function running in background waiting for new messages to arrive
     * return: messageDictionary // A list of messages recieved is returned
     */
    
    //Used to get new Messages from the server
    
    func getChatMessage(completionHandler: @escaping (_ messageInfo: [String: String]) -> Void) {
        socket.on("newChatMessage") { (dataArray, socketAck) -> Void in
            var messageDictionary = [String: String]()
            if let nicknameString = dataArray[0] as? String, let messageString = dataArray[1] as? String, let imageData = dataArray[2] as? String, let enyStr = dataArray[3] as? String, let hashString = dataArray[4] as? String, let dateString = dataArray[5] as? String{
                messageDictionary["nickname"] = nicknameString
                messageDictionary["message"] = messageString
                messageDictionary["imageData"] = imageData
                messageDictionary["isEncryptionOn"] = enyStr
                messageDictionary["hash"] = hashString
                messageDictionary["date"] =  dateString
                
            }
            
            completionHandler(messageDictionary)
        }
    }
    
    /*
     * establishMutualKeys(message : String,withNickName nickname : String,idtype: String )
     * function used to establish mutual keys between both end users
     *
     * parameter: message : String, // This will contain the message from the protocol
                  withNickName nickname : String, // Name of the user who is sending the message
                  idtype: String // This is the id of the step of the protocol
     * return: Void // This will not return a value
     */

    
    //Sending Message for mutual key exchange
    func establishMutualKeys(message : String,withNickName nickname : String,idtype: String ){
        socket.emit("mutualKeyGeneration",nickname,message,idtype)
    }
    
    /*
     * getMutualKeyMessage()
     * function used to get new mutual key messages from the server and appned that to the mutualKeyMessageDictionary of the calling function
     *
     * parameter: Completionhandler //Used to keep the function running in background waiting for new key messages to arrive
     * return: messageDictionary // A list of key messages recieved is returned
     */
    //Receiving Message for mutual key exchange
    func getMutualKeyMessage(completionHandler: @escaping (_ messageInfo: [String: String]) -> Void) {
        socket.on("newMutualKeyMessage") { (dataArray, socketAck) -> Void in
            var mutualKeyMessageDictionary = [String: String]()
            if let nicknameString = dataArray[0] as? String, let messageString = dataArray[1] as? String,let messageType = dataArray[2] as? String{
                mutualKeyMessageDictionary["username"] = nicknameString
                mutualKeyMessageDictionary["message"] = messageString
                mutualKeyMessageDictionary["idtype"] = messageType

            }
            
            completionHandler(mutualKeyMessageDictionary)
        }
    }

}
