//
//  KrogerContentView.swift
//  STTR
//
//  Created by Siddharth Nair on 3/11/21.
//

import SwiftUI
import Firebase

struct ContentView: View {
    
    @EnvironmentObject var session: SessionStore
    
    func getUser () {
        session.listen()
    }

    var body: some View {
        Group {
            if (session.session != nil) {
                SearchKrogerProducts()
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
    }
}
#endif
