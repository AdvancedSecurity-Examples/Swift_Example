//
//  ContentView.swift
//  STTR
//
//  Created by Arjun Lalith on 12/15/20.
//
import SwiftUI
import Firebase

//view that happens on open, if session is going it opens to the main page and if not opens to login
struct ContentView: View {
    
    @EnvironmentObject var session: SessionStore
    @State var showMenu = false
    
    
    func getUser () {
        session.listen()
    }
    
    var body: some View {
        Group {
            //check to see if there is already a session going and if not send them to authenticate
            if (session.session != nil) {
                MenuViewHelper()
            } else {
                AuthenticationScreen()
            }
        }.onAppear(perform: getUser)
    }
}

