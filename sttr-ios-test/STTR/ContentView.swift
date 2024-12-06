//
//  ContentView.swift
//  STTR
//
//  Created by Arjun Lalith on 12/15/20.
//
import SwiftUI
import Firebase

struct ContentView: View {

    @EnvironmentObject var session: SessionStore
    @State var showMenu = false

    
    func getUser () {
        session.listen()
    }
    
    var body: some View {
        Group {
            if (session.session != nil) {
                //SignOutView()
                MenuViewHelper()
               // KrogerView()
                              
                
            } else {
                AuthenticationScreen()
            }
        }.onAppear(perform: getUser)

        


    }
}


#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(SessionStore())
            .environmentObject(RecipeStore())
    }
}
#endif
