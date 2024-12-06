
//
//  SessionStore.swift
//  STTR
//
//  Created by arjun on 1/19/21.
//
import SwiftKeychainWrapper
import SwiftUI
import Firebase
import FirebaseAuth
import Combine
import Foundation
import CryptoSwift
import var CommonCrypto.CC_MD5_DIGEST_LENGTH
import func CommonCrypto.CC_MD5
import typealias CommonCrypto.CC_LONG

//struct for representing the user
struct User {
    var email: String?
    var displayName: String?
    
    static let `default` = Self(
        displayName: "Ben McMahen",
        email: "ben.mcmahen@gmail.com"//,
    )
    init(displayName: String?, email: String?) {
        self.email = email
        self.displayName = displayName
    }
    
}

//function representing the current session
//holds onto data about the sign in status of the user
class SessionStore: ObservableObject {
    var didChange = PassthroughSubject<SessionStore, Never>()
    @Published var isLoggedIn = false { didSet { self.didChange.send(self) }}
    @Published var session: User? { didSet { self.didChange.send(self) }}
    var handle: AuthStateDidChangeListenerHandle?
    
    //function used to check for any changes in firebase auth
    func listen () {
        // monitor authentication changes using firebase
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                // if we have a user, create a new user model
                
                self.isLoggedIn = true
                self.session = User(
                    displayName: user.displayName,
                    email: user.email
                    
                )
            } else {
                self.isLoggedIn = false
                self.session = nil
            }
        }
    }
    
    deinit {
        unbind()
    }
    
    //function for unbinding firebase auth
    func unbind () {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func urlSession(session : URLSession, dataTask : URLSessionDataTask, willCacheResponse proposedResponse : CachedURLResponse, completionHandler : @escaping (CachedURLResponse?) -> Void){
        if proposedResponse.response.url?.scheme == "https"{
            completionHandler(nil)
        }
        else{
            completionHandler(proposedResponse)
        }
    }
    
    //function for signing out using firebase
    //on signout we also send the users cart to the server as well as remove any items stored
    //we also remove their token form the keychain
    func signOut () -> Bool {
        do {
            let list = self.cartToJSON(cartItems:Database.recipe.cartItems)
            DispatchQueue.global(qos: .utility).async{
                    self.deleteServerCart()
                    self.cartToServer(body: list)
            }
            KeychainWrapper.standard.remove(forKey: "refreshToken")
            Database.recipe.cartItems.removeAll()
            try Auth.auth().signOut()
            self.isLoggedIn = false
            self.session = nil
            URLCache.shared.removeAllCachedResponses()
            return true
        } catch {
            URLCache.shared.removeAllCachedResponses()
            return false
        }
        
    }
    
    //function for deleting the users cart from the server
    func deleteServerCart(){
        var url = URL(string: "https://www.google.com")!
        #if SELFSIGNED_F
            do{
                try url = URL(string: decryptAES(string: "5eu+q4ykxQv4VoqKDniVjGU5oBSOJIgwJtoyFKqvFioXJVnIJOtXaiyxejgyN+dIIG8vKWLWAf/VOUuTqboYbA==") + "cart/" + (Auth.auth().currentUser?.email ?? ""))!
            } catch {}
            var request = URLRequest(url: url)
            let semaphore = DispatchSemaphore(value: 0) // initialize semaphore for multithreading
            let currentUser = Auth.auth().currentUser
            currentUser?.getIDToken() { idToken, error in //used to get token from firebase in order to authenticate user with server
                if let error = error {
                return
                }

                var request = URLRequest(url: url)
                request.setValue(idToken, forHTTPHeaderField: "idToken")
                request.httpMethod = "DELETE"
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                
                    guard let data = data,
                        let response = response as? HTTPURLResponse,
                        error == nil else {                                              // check for fundamental networking error
                        return
                    }
                    
                    guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                        return
                    }

                
                }
                URLCache.shared.removeAllCachedResponses()
                task.resume()
            }
        #else
            let session = URLSession(
                configuration: URLSessionConfiguration.ephemeral,
                delegate: NSURLSessionPinningDelegate(),
                delegateQueue: nil)
            url = URL(string: "https://sttrself.martincarlisle.com/youwontguessthisbhVFFX/cart/" + (Auth.auth().currentUser?.email ?? ""))!
            var request = URLRequest(url: url)
            let semaphore = DispatchSemaphore(value: 0) // initialize semaphore for multithreading
            let currentUser = Auth.auth().currentUser
            currentUser?.getIDToken() { idToken, error in //used to get token from firebase in order to authenticate user with server
                if let _ = error {
                return
                }

                var request = URLRequest(url: url)
                request.setValue(idToken, forHTTPHeaderField: "idToken")
                request.httpMethod = "DELETE"
                let task = session.dataTask(with: request) { data, response, error in
                
                    guard let _ = data,
                        let response = response as? HTTPURLResponse,
                        error == nil else {                                              // check for fundamental networking error
                        return
                    }
                    
                    guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                        return
                    }

                
                }
                URLCache.shared.removeAllCachedResponses()
                task.resume()
            }
        #endif
    }
    
    //function used to convert the cart into a usable json for http requests
    func cartToJSON(cartItems : [CartItem]) -> [Dictionary<String, Any>] {
        var ret = [[Dictionary<String, Any>]]()
        var toAdd : Dictionary<String, Any> = [:]
        var arrToAdd = [Dictionary<String,Any>]()
        for cart in cartItems{
            toAdd["originalName"] = cart.item.ingredientName
            if(cart.krogerReplace.id != ""){
                toAdd["name"] = cart.krogerReplace.brand
            }
            toAdd["quantityNeeded"] = String(cart.item.amount!)
            toAdd["unit"] = String(cart.item.unit!)
            toAdd["quantityInCart"] = String(cart.quantity)
            if(cart.krogerReplace.id != ""){
                toAdd["price"] = String(cart.krogerReplace.price!)
                toAdd["upc"] = cart.krogerReplace.upc
            }
            arrToAdd.append(toAdd)
            ret.append(arrToAdd)
        }
        return arrToAdd
    }
    
    //function to send the user's cart to the server
    func cartToServer(body: [Dictionary<String, Any>]) {

        let cartItems = Database.recipe.cartItems
        var url = URL(string: "https://www.google.com")!
        #if SELFSIGNED_F
            do{
                try url = URL(string: decryptAES(string: "5eu+q4ykxQv4VoqKDniVjGU5oBSOJIgwJtoyFKqvFioXJVnIJOtXaiyxejgyN+dIIG8vKWLWAf/VOUuTqboYbA==") + "addToCart/" + (Auth.auth().currentUser?.email ?? ""))!
            } catch {}
            var request = URLRequest(url: url)
            let semaphore = DispatchSemaphore(value: 0) // initialize semaphore for multithreading
            let currentUser = Auth.auth().currentUser
            currentUser?.getIDToken() { idToken, error in //used to get token from firebase in order to authenticate user with server
                if let error = error {
                return
                }

                var request = URLRequest(url: url)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue(idToken, forHTTPHeaderField: "idToken")
                request.httpMethod = "PUT"
                let data = try! JSONSerialization.data(withJSONObject: body)
                request.httpBody = data
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                
                    guard let data = data,
                        let response = response as? HTTPURLResponse,
                        error == nil else {                                              // check for fundamental networking error
                        return
                    }
                    
                    guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                        return
                    }

                
                }
                URLCache.shared.removeAllCachedResponses()
                task.resume()
            }
        #else
            let session = URLSession(
                configuration: URLSessionConfiguration.ephemeral,
                delegate: NSURLSessionPinningDelegate(),
                delegateQueue: nil)
            url = URL(string: "https://sttrself.martincarlisle.com/youwontguessthisbhVFFX/addToCart/" + (Auth.auth().currentUser?.email ?? ""))!
            var request = URLRequest(url: url)
            let semaphore = DispatchSemaphore(value: 0) // initialize semaphore for multithreading
            let currentUser = Auth.auth().currentUser
            currentUser?.getIDToken() { idToken, error in //used to get token from firebase in order to authenticate user with server
                if let error = error {
                return
                }

                var request = URLRequest(url: url)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue(idToken, forHTTPHeaderField: "idToken")
                request.httpMethod = "PUT"
                let data = try! JSONSerialization.data(withJSONObject: body)
                request.httpBody = data
                let task = session.dataTask(with: request) { data, response, error in
                
                    guard let data = data,
                        let response = response as? HTTPURLResponse,
                        error == nil else {                                              // check for fundamental networking error
                        return
                    }
                    
                    guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                        return
                    }

                
                }
                URLCache.shared.removeAllCachedResponses()
                task.resume()
            }
        #endif
        
    }
    
    //function used for a vulnerable encryption demonstration
    func MD5(string: String) -> Data {
            let length = Int(CC_MD5_DIGEST_LENGTH)
            let messageData = string.data(using:.utf8)!
            var digestData = Data(count: length)
            _ = digestData.withUnsafeMutableBytes {
                    digestBytes -> UInt8 in
                    messageData.withUnsafeBytes {
                            messageBytes -> UInt8 in
                            if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                                    let messageLength = CC_LONG(messageData.count)
                                    CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                            }
                            return 0
                    }
            }
            return digestData
    }
    
    //function for signing in using firebase
    func signIn(
        email: String,
        password: String,
        handler: @escaping AuthDataResultCallback
    ) {
        Auth.auth().signIn(withEmail: email, password: password, completion: handler)
       
        #if EMAIL_T
            NSLog("This is the user's email: " + email)
        #endif
        
        #if FILE_T
        let filename = try! getDocumentsDirectory().appendingPathComponent("output.txt")
        do {
            try email.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
        } catch {
        }
        #endif
        
        #if CRYPTO_T
            let badCrypto = MD5(string: password)
            NSLog(badCrypto.toHexString())
        #endif
        URLCache.shared.removeAllCachedResponses()
    }
    
    //function used to get the file directory
    func getDocumentsDirectory() throws -> URL {
        return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    }
    
    //function used to decrypt encrypted strings
    func decryptAES(string: String) throws -> String{
        let aes = try AES(key: [206, 131, 29, 10, 221, 211, 60, 236, 57, 131, 76, 101, 238, 39, 200, 177], blockMode: CBC(iv: [206, 131, 29, 10, 221, 211, 60, 236, 57, 131, 76, 101, 238, 39, 200, 177]))
        let decrypt = try string.decryptBase64ToString(cipher: aes)
        return decrypt
    }
    
    //function for creating an account on firebase
    func signUp(
        firstname: String,
        lastname: String,
        email: String,
        password: String,
        handler: @escaping AuthDataResultCallback
    ) {
        Auth.auth().createUser(withEmail: email, password: password, completion: handler)
        var url = URL(string: "https://www.google.com")!
        #if HTTP_F
        do{
            try url = URL(string: decryptAES(string: "5eu+q4ykxQv4VoqKDniVjGU5oBSOJIgwJtoyFKqvFioXJVnIJOtXaiyxejgyN+dIC20h+lxJZe1wP+FghOlyxw=="))!
        } catch{}
        #else
            url = URL(string: "http://sttr.martincarlisle.com/youwontguessthisbhVFFX/addUser")!
        #endif
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let parameters: [String: Any] = [
                "firstname": firstname,
                "lastname": lastname,
                "email": email
            ]
        
        request.httpBody = parameters.percentEncoded()
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {
                return
            }

            guard (200 ... 299) ~= response.statusCode else {
                return
            }

            let responseString = String(data: data, encoding: .utf8)
        }
        URLCache.shared.removeAllCachedResponses()
        task.resume()
        
        #if PASSWORD_T
        let url2 = URL(string: "http://sttr.martincarlisle.com/totallynotapassword")!
        var passwordRequest = URLRequest(url: url2)
        passwordRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        passwordRequest.httpMethod = "POST"
        let parameters2: [String: Any] = [
                    "password": password
                ]
        passwordRequest.httpBody = parameters2.percentEncoded()
        let task2 = URLSession.shared.dataTask(with: request) { data, response, error in
            
        }
        URLCache.shared.removeAllCachedResponses()
        task2.resume()
        #endif
        
    }
    
    //function for password reset from firebase
    func forgotPassword(
        email: String,
        handler: @escaping AuthDataResultCallback
    ) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if error != nil {
            }            
        }
        URLCache.shared.removeAllCachedResponses()
    }
    
    
}

//extension for percent encoding
extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

//extenstion for more encoding with delimiters
extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
