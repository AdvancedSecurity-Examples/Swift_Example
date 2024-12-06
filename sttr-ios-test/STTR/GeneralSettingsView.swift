//
//  GeneralSettingsView.swift
//  STTR
//
//  Created by Brady  on 3/16/21.
//

import SwiftUI
import Firebase
import FirebaseAuth
import SwiftKeychainWrapper

struct GeneralSettingsView: View {
    var body: some View {
        
        //ScrollView{
            VStack {
                Form {
                    Section {
                        NavigationLink(destination: GeneralView()) {
                           Text("General")
                        }.buttonStyle(PlainButtonStyle()).frame(height: 50)
                    }
                    Section {
                        NavigationLink(destination: SecurityView()) {
                           Text("Security Settings")
                        }.buttonStyle(PlainButtonStyle()).frame(height: 50)
                    }
                    Section {
                        NavigationLink(destination: PrivacyView()) {
                           Text("Privacy Settings")
                        }.buttonStyle(PlainButtonStyle()).frame(height: 50)
                    }
                    Section {
                        NavigationLink(destination: ContactsView()) {
                           Text("Contacts")
                        }.buttonStyle(PlainButtonStyle()).frame(height: 50)
                    }
                    Section {
                        NavigationLink(destination: PaymentView()) {
                           Text("Payment Settings")
                        }.buttonStyle(PlainButtonStyle()).frame(height: 50)
                    }
                    Section {
                        NavigationLink(destination: locationView()) {
                            Text("Location Settings")
                        }.buttonStyle(PlainButtonStyle()).frame(height: 50)
                    }
                }
                Button(action: {
                }, label: {
                    Text("Deactivate Account")
                        .frame(width: 300,
                               height: 50,
                               alignment: .center)
                        .background(Color.orange)
                        .foregroundColor(.black)
                    })
            }
        .navigationBarTitle("Settings")
        //}
    }
}
struct GeneralView: View {
    var body: some View {
        Text("General")
    }
}

struct SecurityView: View {

    @EnvironmentObject var session: SessionStore
    @State var halfModalEmailShow = false
    @State var halfModalPasswordShow = false
   
//    @State var newEmail: String
//    var lol: String
    var body: some View {
        ZStack (alignment: .top){
            VStack(spacing: 30){
                Button(action: {self.halfModalEmailShow.toggle()} ) {
                    Text("Change Email")
                        .frame(width: 300,
                               height: 35,
                               alignment: .center)
                        .background(Color(.systemGray3))
                        .foregroundColor(.black)
                        .clipShape(Capsule())
                    //.padding()
                    
                }

                Button(action: {self.halfModalPasswordShow.toggle()} ) {
                    Text("Change Password")
                        .frame(width: 300,
                               height: 35,
                               alignment: .center)
                        .background(Color(.systemGray3))
                        .foregroundColor(.black)
                        .clipShape(Capsule())
                    //.padding()

                }
               
            }.padding(.init(top: 150, leading: 0, bottom: 12, trailing: 0))
    
            
            HalfModalView(isShown: $halfModalEmailShow, modalHeight: 550){
                ChangeEmailView()
                
                
            }
            
            HalfModalView(isShown: $halfModalPasswordShow, modalHeight: 550){
                ChangePasswordView()
                
            }
        }
    }

}


struct ChangeEmailView: View {
    @EnvironmentObject var session: SessionStore
    @State private var email = ""
    @State private var confirm_email = ""
    @State private var error = false
    @State private var secured = true
    @State private var confirm_secured = true
    @State private var changeEmailSuccess = false
    
    
    var body: some View {
            Form {
                Section() {
//                    HStack{
                    if (changeEmailSuccess) {
                        HStack{
                            Text("SUCCESS")
                        }
                    }
                    else if (error) {
                        HStack{
                            Text("ERROR")
                        }
                    }
                    HStack {
                            Text("Email:")
                            
                            TextField("Email", text: $email)
                                .autocapitalization(UITextAutocapitalizationType.none)
                                .disableAutocorrection(true)
                                    
                            
                    }
                    HStack {
                        Text("Confirm Email:")
                        
                        TextField("Email", text: $confirm_email)
                            .autocapitalization(UITextAutocapitalizationType.none)
                            .disableAutocorrection(true)
                        
                        
                    }
                    Button(action: {
                        reauthenticateUser()
                        changeEmail()
                    }) {
                        Text("Change Email")
                        
                    }
     
                }
    
            }
    }
    
    func changeEmail(){
        error = false
        if(email==confirm_email) {
            Auth.auth().currentUser?.updateEmail(to: email) { (error) in
                if error != nil {
                    print("\(error)")
                    self.error = true
                }
                else{
                    print("Successfully changed email")
                    self.email = ""
                    self.confirm_email = ""
                    self.changeEmailSuccess = true
                }
            }
            
        }
        else {
            self.email = ""
            self.confirm_email = ""
        }
        
        
        
        
        
    }
    
    func reauthenticateUser() {
        let user = Auth.auth().currentUser
        let credential: AuthCredential = EmailAuthProvider.credential(withEmail: session.session?.email ?? "N/A", password: KeychainWrapper.standard.string(forKey: session.session?.email ?? "N/A" )!)
        
        user?.reauthenticate(with: credential){ error,completion  in
           if error != nil {
               print("\(error)")
               print("Failed to reauthenticate")
           } else {
               print("Successfully reauthenticated")

           }
        }
        
    }
}


struct ChangePasswordView: View {
    @EnvironmentObject var session: SessionStore
    @State private var password = ""
    @State private var confirm_password = ""
    @State private var error = false
    @State private var secured = true
    @State private var confirm_secured = true
    @State private var changePasswordSuccess = false
    
    
    var body: some View {

            
            Form {
                
                    
                Section(footer:
                    Text("At least 8 chracters required.")
                            .foregroundColor(.black)
                            .opacity(0.65)
                ) {

                    if (changePasswordSuccess) {
                        HStack{
                            Text("SUCCESS")
                        }
                    }
                    else if (error) {
                        HStack{
                            Text("ERROR")
                        }
                    }
                    HStack {
                        Text("Password:")
                        if secured {
                            SecureField("Password", text: $password)
                                .textContentType(.oneTimeCode)

                        }
                        else {
                            TextField("Password", text: $password)
                                .autocapitalization(UITextAutocapitalizationType.none)
                                .disableAutocorrection(true)
                        }
                        Button( action: {
                            self.secured.toggle()
                            
                        }) {
                            if secured {
                                Image("eye-open")
                                    .resizable()
                                    .foregroundColor(.black)
                                    .frame(width: 22, height: 22, alignment: .trailing)
                            }
                            else {
                                Image("eye-close")
                                    .resizable()
                                    .foregroundColor(.black)
                                    .frame(width: 22, height: 22, alignment: .trailing)
                            }
                        }
                        }
                        HStack {
                            Text("Confirm Password:")
                                .lineLimit(1)
                            if confirm_secured {
                                SecureField("Password", text: $confirm_password)
                                    .textContentType(.newPassword)
                            }
                            else {
                                TextField("Password", text: $confirm_password)
                                    .autocapitalization(UITextAutocapitalizationType.none)
                                    .disableAutocorrection(true)
                            }
                            Button( action: {
                                self.confirm_secured.toggle()
                            }) {
                                if confirm_secured {
                                    Image("eye-open")
                                        .resizable()
                                        .foregroundColor(.black)
                                        .frame(width: 22, height: 22, alignment: .trailing)
                                }
                                else {
                                    Image("eye-close")
                                        .resizable()
                                        .foregroundColor(.black)
                                        .frame(width: 22, height: 22, alignment: .trailing)
                                }
                            }
                        }
                        Button(action: {
                            reauthenticateUser()
                            changePassword()
                        }) {
                            Text("Change password")
                            
                        }
          //          }
                
                    
                }
                
                
            
                
                
            }
        //}
        
        
        
       
        
    }
    
    func changePassword(){
        error = false
        if(password==confirm_password) {
            Auth.auth().currentUser?.updatePassword(to: password) { (error) in
                if error != nil {
                    print("\(error)")
                    self.error = true
                }
                else{
                    print("Successfully changed password")
                    self.password = ""
                    self.confirm_password = ""
                    self.changePasswordSuccess = true
                }
            }
            
        }
        else {
            self.password = ""
            self.confirm_password = ""
        }
        
        
        
        
        
    }
    
    func reauthenticateUser() {
        let user = Auth.auth().currentUser
        let credential: AuthCredential = EmailAuthProvider.credential(withEmail: session.session?.email ?? "N/A", password: KeychainWrapper.standard.string(forKey: session.session?.email ?? "N/A" )!)
        
        user?.reauthenticate(with: credential){ error,completion  in
           if error != nil {
               print("\(error)")
               print("Failed to reauthenticate")
           } else {
               print("Successfully reauthenticated")

           }
        }
        // update keychain
        KeychainWrapper.standard.set(self.password, forKey: session.session?.email ?? "N/A")
    }
}
struct HalfModalView<Content: View> : View {
    @GestureState private var dragState = DragState.inactive
    @Binding var isShown: Bool
    
    private func onDragEnded(drag: DragGesture.Value) {
        let dragThreshold = modalHeight * (2/3)
        if drag.predictedEndTranslation.height > dragThreshold || drag.translation.height > dragThreshold{
            isShown = false
        }
    }
    
    var modalHeight: CGFloat = 400
    
    
    var content: () -> Content
    var body: some View {
        let drag = DragGesture()
            .updating($dragState) { drag, state, transaction in
                state = .dragging(translation: drag.translation)
        }
        .onEnded(onDragEnded)
        return Group {
            ZStack {
  
                Spacer()
                    .edgesIgnoringSafeArea(.all)
                    .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                    .background(Color.clear)
                    .animation(.interpolatingSpring(stiffness: 100.0, damping: 700, initialVelocity: 10.0))
                    .gesture(
                        TapGesture()
                            .onEnded { _ in
                                self.isShown = false
                        }
                )
                
         
                VStack{
                    Spacer()
                    ZStack{
                        Color.clear.opacity(0.5)
                            .frame(width: UIScreen.main.bounds.size.width, height: modalHeight)
                            .cornerRadius(10)
                           
                        self.content()
                            .padding()
                            .padding(.bottom, 65)
                            .frame(width: UIScreen.main.bounds.size.width+20, height: modalHeight)
                            .clipped()
                    }
                    .offset(y: isShown ? ((self.dragState.isDragging && dragState.translation.height >= 1) ? dragState.translation.height : 0) : modalHeight)
                    .animation(.interpolatingSpring(stiffness: 100.0, damping: 700, initialVelocity: 10.0))
                    .gesture(drag)
                    
                    
                }
            }.edgesIgnoringSafeArea(.all)
        }
    }
}

enum DragState {
    case inactive
    case dragging(translation: CGSize)
    
    var translation: CGSize {
        switch self {
        case .inactive:
            return .zero
        case .dragging(let translation):
            return translation
        }
    }
    
    var isDragging: Bool {
        switch self {
        case .inactive:
            return false
        case .dragging:
            return true
        }
    }
}





struct PrivacyView: View {
    var body: some View {
        Text("Privacy")
    }
}
struct ContactsView: View {
    var body: some View {
        Text("Contacts")
    }
}
struct PaymentView: View {
   var body: some View {
       Text("Payment")
   }
}
struct CustomNavigationView: View {
    var body: some View {
        Text("Hello, World!")
    }
}

struct GeneralSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralSettingsView()
    }
}


