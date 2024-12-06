//
//  AccountView.swift
//  STTR
//
//  Created by Brady  on 3/16/21.
//

import SwiftUI
import FirebaseAuth
import CryptoSwift
import AVFoundation

//class used for storing account information and making it easier to use
class Account: NSObject, NSCoding {
    var displayName: String
    var firstName: String
    var lastName: String
    var email: String
    var phoneNum: String
    var card: String
    var dob: String
    
    //key definition used for encoding the account information
    enum Key:String{
        case displayName = "displayName"
        case firstName = "firstName"
        case lastName = "lastName"
        case email = "email"
        case phoneNum = "phoneNum"
        case card = "card"
        case dob = "dob"
    }
    
    //initializer function for account object
    init(displayName: String, firstName: String, lastName: String, email: String, phoneNum: String, card: String, dob: String){
        self.displayName = displayName
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phoneNum = phoneNum
        self.card = card
        self.dob = dob
    }
    
    //function used to encode the data using NSCoding
    func encode(with aCoder: NSCoder){
        aCoder.encode(displayName, forKey: Key.displayName.rawValue)
        aCoder.encode(firstName, forKey: Key.firstName.rawValue)
        aCoder.encode(lastName, forKey: Key.lastName.rawValue)
        aCoder.encode(email, forKey: Key.email.rawValue)
        aCoder.encode(phoneNum, forKey: Key.phoneNum.rawValue)
        aCoder.encode(card, forKey: Key.card.rawValue)
        aCoder.encode(dob, forKey: Key.dob.rawValue)
    }
    
    //function for encoding
    convenience required init?(coder aDecoder: NSCoder){
        let displayName = aDecoder.decodeObject(forKey: Key.displayName.rawValue) as! String
        let firstName = aDecoder.decodeObject(forKey: Key.firstName.rawValue) as! String
        let lastName = aDecoder.decodeObject(forKey: Key.lastName.rawValue) as! String
        let email = aDecoder.decodeObject(forKey: Key.email.rawValue) as! String
        let phoneNum = aDecoder.decodeObject(forKey: Key.phoneNum.rawValue) as! String
        let card = aDecoder.decodeObject(forKey: Key.card.rawValue) as! String
        let dob = aDecoder.decodeObject(forKey: Key.dob.rawValue) as! String
        self.init(displayName: displayName, firstName: firstName, lastName: lastName, email: email, phoneNum: phoneNum, card: card, dob: dob)
    }
}

//view used for displaying the user's account information
struct AccountView: View {
    @State var displayName: String = ""
    @State var firstname: String = ""
    @State var lastname: String = ""
    @State var email: String = ""
    @State var phone: String = ""
    @State var card: String = ""
    @State var dob: String = ""
    
    
    var body: some View {
        
        VStack(spacing: 25){
            
            HStack(alignment: .center){
                Text("First Name:")
                    .frame(width: 75, height: 20, alignment: .leading)
                ZStack{
                    Rectangle()
                        .stroke(Color(UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 0.7)))
                        .frame(width: 250, height: 30)
                    TextField("first name", text: $firstname)
                        .frame(width: 225, height: 30, alignment: .center)
                        .disableAutocorrection(true)
                        .onAppear() {
                            getInfo()
                            //if the zip vulnerability is turned on download a zip file
                            #if ZIP_T
                                let test = Vuln()
                                test.trustCerts()
                                test.unsecureDownload()
                            #endif
                        }
                }
                
            }
            HStack(alignment: .center){
                Text("Last Name:")
                    .frame(width: 75, height: 20, alignment: .leading)
                ZStack{
                    Rectangle()
                        .stroke(Color(UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 0.7)))
                        .frame(width: 250, height: 30)
                    TextField("last name", text: $lastname)
                        .frame(width: 225, height: 30, alignment: .center)
                        .disableAutocorrection(true)
                }
            }
            HStack(alignment: .center){
                Text("Email:")
                    .frame(width: 75, height: 20, alignment: .leading)
                ZStack{
                    Rectangle()
                        .fill(Color(UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 0.7)))
                        .frame(width: 250, height: 30)
                    Text(email)
                        .frame(width: 225, height: 30, alignment: .leading)
                }
            }
            HStack(alignment: .center){
                Text("Phone:")
                    .frame(width: 75, height: 20, alignment: .leading)
                
                ZStack{
                    Rectangle()
                        .stroke(Color(UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 0.7)))
                        .frame(width: 250, height: 30)
                    TextField("XXX-XXX-XXXX", text: $phone)
                        .frame(width: 225, height: 30, alignment: .leading)
                        .disableAutocorrection(true)
                }
            }
            HStack(alignment: .center) { //redefines the structs values! Great for editing Account info.
                Button(action: {
                    pushInfo()
                }, label: {
                    Text("SAVE")
                })
                
                Button(action: { //Reverts any changes mae to the previous structs values.
                    getInfo()
                }, label: {
                    Text("CANCEL")
                })
            }
            Spacer()
                .frame(height: 100)
        }
        .navigationBarTitle(Text("Username"),displayMode: .inline)
    }
    
    //function used to decrypt the encrypted strings
    func decryptAES(string: String) throws -> String{
        let aes = try AES(key: [206, 131, 29, 10, 221, 211, 60, 236, 57, 131, 76, 101, 238, 39, 200, 177], blockMode: CBC(iv: [206, 131, 29, 10, 221, 211, 60, 236, 57, 131, 76, 101, 238, 39, 200, 177]))
        let decrypt = try string.decryptBase64ToString(cipher: aes)
        return decrypt
    }
    
    //function used to get the users account info from the server
    func getInfo() {
        
        //Now that it is left in the certificates, the insecure HTTP connection will be accepted when making URL requests
        //The following is an example of a URL request to the insecure website using the certificate pinning implemented
        
        let currentUser = Auth.auth().currentUser
        
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            if let error = error {
            return
            }
            print("Account view: " + (Auth.auth().currentUser?.email)!)
            #if SELFSIGNED_F
            var url = URL(string: "https://www.google.com")!
                do{
                   try url = URL(string: decryptAES(string: "5eu+q4ykxQv4VoqKDniVjGU5oBSOJIgwJtoyFKqvFioXJVnIJOtXaiyxejgyN+dIn1mKLAkqdbPHABfqjAIzYA==") + (Auth.auth().currentUser?.email ?? ""))!
                } catch{}
            let session = URLSession(
                configuration: URLSessionConfiguration.ephemeral,
                delegate: NSURLSessionPinningDelegate(),
                delegateQueue: nil)
            var request = URLRequest(url: url)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue(idToken, forHTTPHeaderField: "idToken")
            request.httpMethod = "GET"
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                
                guard let data = data,
                    let response = response as? HTTPURLResponse,
                    error == nil else {
                    return
                }
                
                let string = String(data: data, encoding: .utf8) ?? ""
                let result = string.data(using: .utf8)!
                do {
                    if let jsonArray = try JSONSerialization.jsonObject(with: result, options: .allowFragments) as? [Dictionary<String, Any>] {
                        displayName = jsonArray[0]["displayname"] as? String ?? ""
                        firstname   = jsonArray[0]["firstname"] as? String ?? ""
                        lastname    = jsonArray[0]["lastname"] as? String ?? ""
                        email       = jsonArray[0]["email"] as? String ?? ""
                        phone       = jsonArray[0]["phone"] as? String ?? ""
                        card        = jsonArray[0]["cardnumber"] as? String ?? ""
                        dob         = jsonArray[0]["dob"] as? String ?? ""
                        #if NSCODING_T //uses a vulnerable form of encoding
                            let account = Account(displayName: displayName, firstName: firstname, lastName: lastname, email: email, phoneNum: phone, card: card, dob: dob)
                            displayName = account.displayName
                            firstname = account.firstName
                            lastname = account.lastName
                            email = account.email
                            phone = account.phoneNum
                            card = account.card
                            dob = account.dob
                        #endif
                    } else {
                    }
                } catch _ as NSError {
                }

                guard (200 ... 299) ~= response.statusCode else {
                    return
                }

                
            }

            #else
                #if WRONGCERT_F
                    let url = URL(string: "https://sttrself.martincarlisle.com/youwontguessthisbhVFFX/users/" + (Auth.auth().currentUser?.email ?? ""))!
                #else
                    let url = URL(string: "https://sttrwrong.martincarlisle.com/youwontguessthisbhVFFX/users/" + (Auth.auth().currentUser?.email ?? ""))!
                #endif
            let session = URLSession(
                configuration: URLSessionConfiguration.ephemeral,
                delegate: NSURLSessionPinningDelegate(),
                delegateQueue: nil)
            var request = URLRequest(url: url)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "GET"
            request.setValue(idToken, forHTTPHeaderField: "idToken")
            let task = session.dataTask(with: request) { data, response, error in
                
                guard let data = data,
                    let response = response as? HTTPURLResponse,
                    error == nil else {                                              // check for fundamental networking error
                    return
                }
                
                let string = String(data: data, encoding: .utf8) ?? ""
                let result = string.data(using: .utf8)!
                do {
                    if let jsonArray = try JSONSerialization.jsonObject(with: result, options: .allowFragments) as? [Dictionary<String, Any>] {
                        displayName = jsonArray[0]["displayname"] as? String ?? ""
                        firstname   = jsonArray[0]["firstname"] as? String ?? ""
                        lastname    = jsonArray[0]["lastname"] as? String ?? ""
                        email       = jsonArray[0]["email"] as? String ?? ""
                        phone       = jsonArray[0]["phone"] as? String ?? ""
                        card        = jsonArray[0]["cardnumber"] as? String ?? ""
                        dob         = jsonArray[0]["dob"] as? String ?? ""
                        #if NSCODING_T
                            let account = Account(displayName: displayName, firstName: firstname, lastName: lastname, email: email, phoneNum: phone, card: card, dob: dob)
                            displayName = account.displayName
                            firstname = account.firstName
                            lastname = account.lastName
                            email = account.email
                            phone = account.phoneNum
                            card = account.card
                            dob = account.dob
                        #endif
                        #if LEAK_T
                            NSLog("Username: " + displayName)
                            NSLog("First Name: " + firstname)
                            NSLog("Last Name: " + lastname)
                            NSLog("Full Name: " + firstname + " " + lastname)
                            NSLog("Phone Number: " + phone)
                            NSLog("Date of Birth: " + dob)
                            NSLog("Email Address: " + email)
                        #endif
                    } else {
                    }
                } catch let error as NSError {
                }

                guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                    return
                }

                
            }

            #endif
            URLCache.shared.removeAllCachedResponses()
            task.resume()
        }
        
    }
    
    //function used to send account info changes to the server
    func pushInfo() {
        let currentUser = Auth.auth().currentUser
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            var url = URL(string: "https://www.google.com")!
            #if SELFSIGNED_F
                do{
                    try url = URL(string: decryptAES(string: "5eu+q4ykxQv4VoqKDniVjGU5oBSOJIgwJtoyFKqvFioXJVnIJOtXaiyxejgyN+dIn1mKLAkqdbPHABfqjAIzYA==") + (Auth.auth().currentUser?.email ?? ""))!
                } catch {}
                var request = URLRequest(url: url)
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request.setValue(idToken, forHTTPHeaderField: "idToken")
                request.httpMethod = "PUT"
                let parameters: [String: Any] = [
                    "displayname" : displayName,
                    "firstname" : firstname,
                    "lastname" : lastname,
                    "email" : email,
                    "phone" : phone,
                    "cardnumber" : card,
                    "dob" : dob
                ]
                request.httpBody = parameters.percentEncoded()
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    
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
            #else
                url = URL(string: "https://sttrself.martincarlisle.com/youwontguessthisbhVFFX/users/" + (Auth.auth().currentUser?.email ?? ""))!
                let session = URLSession(
                    configuration: URLSessionConfiguration.ephemeral,
                    delegate: NSURLSessionPinningDelegate(),
                    delegateQueue: nil)
                var request = URLRequest(url: url)
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request.setValue(idToken, forHTTPHeaderField: "idToken")
                request.httpMethod = "PUT"
                let parameters: [String: Any] = [
                    "displayname" : displayName,
                    "firstname" : firstname,
                    "lastname" : lastname,
                    "email" : email,
                    "phone" : phone,
                    "cardnumber" : card,
                    "dob" : dob
                ]
                request.httpBody = parameters.percentEncoded()
                
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
            #endif
            
        }
    }
        
}
