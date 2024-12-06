//
//  DeactivateAccountView.swift
//  STTR
//
//  Created by Jeb Malek on 6/2/21.
//

import Foundation
import UIKit
import SwiftUI
import FirebaseAuth
import CryptoSwift
import GoogleSignIn
import Firebase
import FBSDKLoginKit
import FBSDKCoreKit

//view used let the user deactivate their account
struct DeactivateAccountView : View {
    @State private var email = ""
    @State private var password = ""
    @State private var failure = false
    @EnvironmentObject var session: SessionStore
    
    var body : some View {
        
        Form {
            Section(header: Text("Enter log in credentials").font(.system(size: 20)))
            {
                HStack {
                    Text("Email")
                    TextField("Email", text: $email)
                        .autocapitalization(UITextAutocapitalizationType.none)
                        .disableAutocorrection(true)
                }
                HStack() {
                    Text("Password")
                    SecureField("Password", text: $password)
                        .autocapitalization(UITextAutocapitalizationType.none)
                        .disableAutocorrection(true)
                }
                Button(action: {
                    deleteAccount()
                },label: {
                    Spacer()
                    Text("Delete Account").font(.system(size: 25, weight: .regular, design: .default))
                        .foregroundColor(Color.white)
                    Spacer()
                }).buttonStyle(PlainButtonStyle()).listRowBackground(Color.red)
                if (failure) {
                    HStack() {
                        Spacer()
                        Text("Invalid Credentials!")
                            .foregroundColor(Color.red)
                        Spacer()
                    }
                }
            }
            Section{
                Button(action: {
                    deleteWithGoogle()
                },label: {
                    Spacer()
                    Text("Delete Account from Google").font(.system(size: 25, weight: .regular, design: .default))
                        .foregroundColor(Color.white)
                    Spacer()
                }).buttonStyle(PlainButtonStyle()).listRowBackground(Color.red)
            }
            Section {
                logout()
            }
        }
    }
    
    //function used to decrpyt encrypted strings
    func decryptAES(string: String) throws -> String{
        let aes = try AES(key: [206, 131, 29, 10, 221, 211, 60, 236, 57, 131, 76, 101, 238, 39, 200, 177], blockMode: CBC(iv: [206, 131, 29, 10, 221, 211, 60, 236, 57, 131, 76, 101, 238, 39, 200, 177]))
        let decrypt = try string.decryptBase64ToString(cipher: aes)
        return decrypt
    }
    
    //function used to delete the user's firebase login account
    func deleteAccount() {
        session.signIn(email: email, password: password) { (result, error) in //sign in to firebase first
            if let _ = error {
                failure = true
                return
            }
            var url = URL(string : "https://www.google.com")!
            #if HTTP_F
                do{
                    try url = URL(string: decryptAES(string: "5eu+q4ykxQv4VoqKDniVjGU5oBSOJIgwJtoyFKqvFioXJVnIJOtXaiyxejgyN+dIn1mKLAkqdbPHABfqjAIzYA==") + email)!
                } catch{}
            #else
                url = URL(string: "http://sttr.martincarlisle.com/youwontguessthisbhVFFX/users/" + email)!
            #endif
            var request = URLRequest(url: url)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "DELETE"
            
            let currentUser = Auth.auth().currentUser
            currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
                request.setValue(idToken, forHTTPHeaderField: "idToken")
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let  _ = data,
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
            
            
            Auth.auth().currentUser?.delete { error in //delete the users account using the Firebase Auth instance
                if let _ = error {
                } else {
                }
            }
        }
        
    }
    
    func deleteWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration.init(clientID: clientID)

        // Start the sign in flow!
        let view = UIApplication.shared.windows.first?.rootViewController
        GIDSignIn.sharedInstance.signIn(with: config, presenting: view!) { user, error in

            if error != nil { return }

            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else { return }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: authentication.accessToken)
            Auth.auth().signIn(with: credential) {_,_ in
                print("Deleting with Google")
                var url = URL(string : "https://www.google.com")!
                let email = Auth.auth().currentUser?.email ?? ""
                #if HTTP_F
                    do{
                        try url = URL(string: decryptAES(string: "5eu+q4ykxQv4VoqKDniVjGU5oBSOJIgwJtoyFKqvFioXJVnIJOtXaiyxejgyN+dIn1mKLAkqdbPHABfqjAIzYA==") + email)!
                    } catch{}
                #else
                    url = URL(string: "http://sttr.martincarlisle.com/youwontguessthisbhVFFX/users/" + email)!
                #endif
                print(url)
                var request = URLRequest(url: url)
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request.httpMethod = "DELETE"
                
                let currentUser = Auth.auth().currentUser
                currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
                    request.setValue(idToken, forHTTPHeaderField: "idToken")
                    let task = URLSession.shared.dataTask(with: request) { data, response, error in
                        print("I AM RUNNING THE DATA TASK")
                        guard let  _ = data,
                            let response = response as? HTTPURLResponse,
                            error == nil else {
                            print("AN ERROR OCCURED")
                            // check for fundamental networking error
                            return
                        }

                        guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                            return
                        }

                    }
                    URLCache.shared.removeAllCachedResponses()
                    task.resume()
                }
                Auth.auth().currentUser?.delete()
            }
        }
    }
}



struct logout : UIViewRepresentable {
    
    @EnvironmentObject var session: SessionStore
    
    func makeCoordinator() -> logout.Coordinator {
        return logout.Coordinator()
    }
    
    func makeUIView(context: UIViewRepresentableContext<logout>) -> FBLoginButton {
        let button = FBLoginButton()
        button.delegate = context.coordinator
        button.permissions = ["public_profile", "email"]
        return button
    }
    
    func updateUIView(_ uiView: FBLoginButton, context: UIViewRepresentableContext<logout>) {
        
    }
    
    class Coordinator : NSObject, LoginButtonDelegate{
        func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
            if error != nil{
                return
            }
            
            if AccessToken.current != nil{
                let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
                Auth.auth().signIn(with: credential) { (res,err) in
                    
                    if err != nil{
                        print("An error has occured!!!!!!!!!!!")
                        print(err)
                        return
                    }
                    //session.fbLog.toggle()
                    
                    let requestedFields = "email"
                    GraphRequest.init(graphPath: "me", parameters: ["fields":requestedFields]).start { (connection, result, error) -> Void in
                        let userInfo = Auth.auth().currentUser?.providerData[0]
                        var email = ""
                        let info = result as! [String : AnyObject]
                        if info["email"] as? String != nil {
                            email = info["email"] as! String
                        }
                        var url = URL(string : "https://www.google.com")!
                        #if HTTP_F
                            do{
                                try url = URL(string: self.decryptAES(string: "5eu+q4ykxQv4VoqKDniVjGU5oBSOJIgwJtoyFKqvFioXJVnIJOtXaiyxejgyN+dIn1mKLAkqdbPHABfqjAIzYA==") + email)!
                            } catch{}
                        #else
                            url = URL(string: "http://sttr.martincarlisle.com/youwontguessthisbhVFFX/users/" + email)!
                        #endif
                        print(url)
                        var request = URLRequest(url: url)
                        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                        request.httpMethod = "DELETE"
                        
                        let currentUser = Auth.auth().currentUser
                        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
                            request.setValue(idToken, forHTTPHeaderField: "idToken")
                            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                                print("I AM RUNNING THE DATA TASK")
                                guard let  _ = data,
                                    let response = response as? HTTPURLResponse,
                                    error == nil else {
                                    print("AN ERROR OCCURED")
                                    // check for fundamental networking error
                                    return
                                }

                                guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                                    return
                                }

                            }
                            URLCache.shared.removeAllCachedResponses()
                            task.resume()
                        }
                        Auth.auth().currentUser?.delete()
                    }
                }
                
                
            }
        }
        
        func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
            if (AccessToken.current == nil) {
                return
            }
            try! Auth.auth().signOut()
        }
        func decryptAES(string: String) throws -> String{
                let aes = try AES(key: [206, 131, 29, 10, 221, 211, 60, 236, 57, 131, 76, 101, 238, 39, 200, 177], blockMode: CBC(iv: [206, 131, 29, 10, 221, 211, 60, 236, 57, 131, 76, 101, 238, 39, 200, 177]))
                let decrypt = try string.decryptBase64ToString(cipher: aes)
                return decrypt
            }
    }
}
