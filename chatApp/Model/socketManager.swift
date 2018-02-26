//
//  socketManager.swift
//  chatApp
//
//  Created by Ashutosh Kumar sai on 17/02/18.
//  Copyright © 2018 Ashish Kumar sai. All rights reserved.
//

import UIKit
import SocketIO

let manager = SocketManager(socketURL: URL(string: "http://192.168.43.196:3000")!, config: [.log(true), .compress])
let socket = manager.defaultSocket

class socketManager: NSObject {
    static let sockets = socketManager()
    override init() {
        super.init()
    }
    
    func startConnection(){
        socket.connect()
    }
    
    func endConnection(){
        socket.disconnect()
    }
    
   
    func connectUserToServer(nickname: String, completionHandler: @escaping (_ userList: [[String: AnyObject]]?) -> Void) {
        socket.emit("connectUser", nickname)
        
        socket.on("userList") { ( dataArray, ack) -> Void in
            completionHandler(dataArray[0] as? [[String: AnyObject]])
        }
        
    }
    
    //Used to send messages to the servers
    func sendMessage(message : String,withNickName nickname : String,imageData : String,isEncryptionOn : String,hash : String){
        socket.emit("chatMessage", nickname,message,imageData,isEncryptionOn,hash)
    }
    
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
    
    //Sending Message for mutual key exchange
    func establishMutualKeys(message : String,withNickName nickname : String,idtype: String ){
        socket.emit("mutualKeyGeneration",nickname,message,idtype)
    }
    
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
