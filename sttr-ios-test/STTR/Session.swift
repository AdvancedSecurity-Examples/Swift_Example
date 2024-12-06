
//
//  SessionStore.swift
//  STTR
//
//  Created by arjun on 1/19/21.
//

import SwiftUI
import Firebase
import FirebaseAuth
import Combine
import SwiftKeychainWrapper

struct User {
   // var uid: String
    var email: String?
    //var photoURL: URL?
    var displayName: String?
    
    static let `default` = Self(
        //uid: "sdfdsaf",
        displayName: "Ben McMahen",
        email: "ben.mcmahen@gmail.com"//,
        //photoURL: nil
    )
//    init(uid: String, displayName: String?, email: String?, photoURL: URL?) {
//        self.uid = uid
//        self.email = email
//        self.photoURL = photoURL
//        self.displayName = displayName
//    }
    init(displayName: String?, email: String?) {
        //self.uid = uid
        self.email = email
        //self.photoURL = photoURL
        self.displayName = displayName
    }

}

class SessionStore: ObservableObject {
    
    var didChange = PassthroughSubject<SessionStore, Never>()
    @Published var isLoggedIn = false { didSet { self.didChange.send(self) }}
    @Published var session: User? { didSet { self.didChange.send(self) }}
    var handle: AuthStateDidChangeListenerHandle?

   
    
    
//
//    override convenience init() {
//        self.init(session: nil)
//    }
//    init(session: User? = nil) {
//        self.session = session
//    }
    func listen () {
        // monitor authentication changes using firebase
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                    // if we have a user, create a new user model
                print("Got user \(user)")

                self.isLoggedIn = true
                self.session = User(
                  //  uid: user.uid,
                    displayName: user.displayName,
                    email: user.email//,
                  //  photoURL: user.photoURL
                    
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

    func unbind () {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    func signOut () -> Bool {
        do {
            try Auth.auth().signOut()
            self.isLoggedIn = false
            self.session = nil
            return true
        } catch {
            return false
        }
    }
    func signIn(
        email: String,
        password: String,
        handler: @escaping AuthDataResultCallback
        ) {
        Auth.auth().signIn(withEmail: email, password: password, completion: handler)
        if (KeychainWrapper.standard.string(forKey: email) == nil) {
            KeychainWrapper.standard.set(password, forKey: email)
        }
        
    }
    

    func signUp(
        email: String,
        password: String,
        handler: @escaping AuthDataResultCallback
    ) {
        Auth.auth().createUser(withEmail: email, password: password, completion: handler)
        KeychainWrapper.standard.set(password, forKey: email)
    }
    
    func forgotPassword(
        email: String,
        handler: @escaping AuthDataResultCallback
    ) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if error != nil {
                print("\(error)")
            }
        }
    }
    
    
}
