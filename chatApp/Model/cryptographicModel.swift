//
//  cryptographicModel.swift
//  chatApp
//  This class is base of all cryptographic methods used by this chat app
//  Created by Ashutosh Kumar sai on 19/02/18.
//  Copyright © 2018 Ashish Kumar sai. All rights reserved.
//
//  This swift class can be used anywhere for the crypto methods written in it

import UIKit
import CryptoSwift
import SwiftyRSA

class cryptographicModel: NSObject {
    
    //We make this class singlton so that methods in this can be called by any other class
    static let cryptoModel = cryptographicModel()
    
    /*
     * symmetricAESEncryption(key: String,message: String)
     * function used to encrypt a given messsage string with a given key by using AES from CryptoSwift libarary
     *
     * parameter: key: String,message: String //Key and message
     * return: String // This will return an encrypted text
     */
    
    func symmetricAESEncryption(key: String,message: String)-> String{
        //AES
        var returnString = " "
        do{
            let aes = try AES(key: key, iv: "drowssapdrowssap")
            let ciphertext = try aes.encrypt(Array(message.utf8))
            let encryptedData = Data(ciphertext)
            let encryptedString = encryptedData.base64EncodedString()
            returnString = encryptedString
        }catch{
            print("Error in AESEncryption")
        }
        
        return returnString
    }
    
    /*
     * symmetricAESDecryption(key: String,message: String)
     * function used to decrypt a given messsage string with a given key by using AES from CryptoSwift libarary
     *
     * parameter: key: String,message: String //Key and message
     * return: String // This will return an decrypted text
     */
    
    func symmetricAESDecryption(key: String,message: String)-> String{
        //AES Decryption
        var returnString = " "
        do{
            let aes = try AES(key: key, iv: "drowssapdrowssap")
            let data = Data(base64Encoded: message)
            let defaultForm = [UInt8](data!)
            let plainText = try aes.decrypt(defaultForm)
            let xmlStr:String = String(bytes: plainText, encoding: String.Encoding.utf8)!
            returnString = xmlStr
        }catch{
            print("Error in AESDecryption")
        }
        return returnString
        
    }
    
    /*
     * asymmetricRSAEncryption(key: String,message: String)
     * function used to encrypt a given messsage string with a given key by using RSA from SwiftyRSA libarary
     *
     * parameter: key: String,message: String //Key and message
     * return: String // This will return an encrypted text
     */
    
    func asymmetricRSAEncryption(key: String,message: String)-> String{
        //RSAEncryption
        var returnString = " "
        do{
            let publicKey = try PublicKey(pemNamed: key)
            let clear = try ClearMessage(string: message, using: .utf8)
            let encrypted = try clear.encrypted(with: publicKey, padding: .PKCS1)
            print(encrypted)
            //let data = encrypted.data
            let base64String = encrypted.base64String
            returnString = base64String
        }catch{
            print("Error in RSA Encryption")
        }
        return returnString
    }
   
    /*
     * asymmetricRSADecryption(key: String,message: String)
     * function used to decrypt a given messsage string with a given key by using RSA from SwiftyRSA libarary
     *
     * parameter: key: String,message: String //Key and message
     * return: String // This will return an decrypted text
     */

    
    func asymmetricRSADecryption(key: String,message: String)-> String{
        //RSA Decryption
        var returnString = " "
        do{
            let privateKey = try PrivateKey(pemNamed: key)
            let encryptedText = try EncryptedMessage(base64Encoded: message)
            let clears = try encryptedText.decrypted(with: privateKey, padding: .PKCS1)
            let datas = clears.data
            let base64Strings = clears.base64String
            let string = try clears.string(encoding: .utf8)
            returnString = string
        }catch{
            print("Error in RSA Decryption")
        }
        return returnString
        
    }
    
    /*
     * asymmetricRSASign(key: String,message: String)
     * function used to digitally Sign a given messsage string with a given key by using RSA from SwiftyRSA libarary
     *
     * parameter: key: String,message: String //Key and message
     * return: String // This will return an signed text
     */
    
    func asymmetricRSASign(key: String,message: String)-> String{
        //RSASign
        var returnString = " "
        do{
            let privateKey = try PrivateKey(pemNamed: key)
            let hash = try ClearMessage(string: message, using: .utf8)
            let signature = try hash.signed(with: privateKey, digestType: .sha256)
            let data = signature.data
            let base64String = signature.base64String
            returnString = base64String
            
        }catch{
            print("Error in RSA Sign")
        }
        return returnString
    }
    
    /*
     * asymmetricRSAVerify(key: String,message: String,textToVerify: String)
     * function used to digitally verify a given messsage string with a given key by using RSA from SwiftyRSA libarary
     *
     * parameter: key: key: String,message: String,textToVerify: String //Key and message, text to verify against the key
     * return: bool // This will return true if sign was verified else false
     */
    func asymmetricRSAVerify(key: String,message: String,textToVerify: String)-> Bool{
        //RSAVerify
        var returnBool :Bool = false
        do{
            print("INSIDE RSA VERIFY")
            let publicKey = try PublicKey(pemNamed: key)
            let clear = try ClearMessage(string: message, using: .utf8)
            print("ClearMessage",clear)
            let signature = try Signature(base64Encoded: textToVerify)
            print("Signature =",signature)
            let isSuccessful = try clear.verify(with: publicKey, signature: signature, digestType: .sha256)
            print("LOOK AT THIS mate",isSuccessful)
            returnBool = isSuccessful
        }catch{
            print("Error in RSA Verify")
        }
        
        return returnBool
    }
}
