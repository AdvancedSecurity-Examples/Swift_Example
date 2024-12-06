//
//  GeneralSettingsView.swift
//  STTR
//
//  Created by Brady  on 3/16/21.
//

import SwiftUI
import Firebase
import FirebaseAuth
import ContactsUI
import Foundation
import MessageUI
import UIKit

struct dateAndTime { //For time of order
    static var date = Date()
    static var calendar = Calendar.current
    
    static var yesSeconds = false
    static var yesTime = true

    static var hour = calendar.component(.hour, from: date)
    static var minutes = calendar.component(.minute, from: date)
    static var seconds = calendar.component(.second, from: date)
    static var zone = calendar.component(.timeZone, from: date)
    
    static var day = calendar.component(.day, from: date)
    static var month = calendar.component(.month, from: date)
    static var year = calendar.component(.year, from: date)
        
    static var orderDate = String(month) + "/" + String(day) + "/" + String(year) + " " + String(hour) + ":" + String(minutes)
    static var orderDateWithSeconds = String(month) + "/" + String(day) + "/" + String(year) + " " + String(hour) + ":" + String(minutes) + ":" + String(seconds)
    static var orderDateWithoutTime = String(month) + "/" + String(day) + "/" + String(year)
    
}

//view used to navigate between the different pages in the settings
struct GeneralSettingsView: View {
    @State var text = NSMutableAttributedString(string: "Howdy")
    var body: some View {
        
        VStack {
            Form {
                //links to associated settings page
                Section {
                    NavigationLink(destination: SecurityView()) {
                        Text("Security Settings")
                    }.buttonStyle(PlainButtonStyle()).frame(height: 50)
                }
                Section {
                    NavigationLink(destination: locationView()) {
                        Text("Location Settings")
                    }.buttonStyle(PlainButtonStyle()).frame(height: 50)
                }
                Section {
                    NavigationLink(destination: UpdatesView()) {
                        Text("Check For Updates")
                    }.buttonStyle(PlainButtonStyle()).frame(height: 50)
                }
                Section {
                    NavigationLink(destination: DeactivateAccountView()) {
                        Text("Deactivate Account")
                    }.buttonStyle(PlainButtonStyle()).frame(height: 50).listRowBackground(Color.red)
                }
            }
        }
        .navigationBarTitle("Settings")
    }
}

//view used to "check for updates." In reality it actually downloads a zip file in order to demonstrate the associated vulnerability
struct UpdatesView: View{
    var body: some View{
        Text("No Updates Available").onAppear(){
            //if allowed will download a zip file over Objective-C AFNetworking
            #if ZIP_T
                let vuln = Vuln()
                vuln.trustCerts()
                vuln.unsecureDownload()
            #endif
            //displays file path
            let fm = FileManager.default
            var path = Bundle.main.resourcePath!
            path = String(path[...path.index(path.lastIndex(of: "/")!, offsetBy: -1)])
            path = String(path[...path.index(path.lastIndex(of: "/")!, offsetBy: -1)])
            path = String(path[...path.index(path.lastIndex(of: "/")!, offsetBy: -1)])
            path = String(path[...path.index(path.lastIndex(of: "/")!, offsetBy: -1)])
            path = String(path[...path.index(path.lastIndex(of: "/")!, offsetBy: -1)])
            path = String(path[...path.index(path.lastIndex(of: "/")!, offsetBy: -1)])
            path = String(path[...path.index(path.lastIndex(of: "/")!, offsetBy: -1)])
            
            do {
                let items = try fm.contentsOfDirectory(atPath: path)
                
                for item in items {
                }
            } catch {
            }
        }
    }
}

//view used to change the user account's email and password
struct SecurityView: View {
    
    @EnvironmentObject var session: SessionStore
    @State var halfModalEmailShow = false //toggle variables used to show a view to bring up a view for entering info to change account info
    @State var halfModalPasswordShow = false

    var body: some View {
        ZStack (alignment: .top){
            VStack(spacing: 30){
//                Button(action: {self.halfModalEmailShow.toggle()
//                    halfModalPasswordShow = false
//                } ) {
//                    Text("Change Email")
//                        .frame(width: 300,
//                               height: 35,
//                               alignment: .center)
//                        .background(Color(.systemGray3))
//                        .foregroundColor(.black)
//                        .clipShape(Capsule())
//                    
//                }
                
                Button(action: {self.halfModalPasswordShow.toggle()
                    halfModalEmailShow = false
                } ) {
                    Text("Change Password")
                        .frame(width: 300,
                               height: 35,
                               alignment: .center)
                        .background(Color(.systemGray3))
                        .foregroundColor(.black)
                        .clipShape(Capsule())
                    
                }
                
            }.padding(.init(top: 150, leading: 0, bottom: 12, trailing: 0))
            
            
//            HalfModalView(isShown: $halfModalEmailShow, modalHeight: 2*UIScreen.main.bounds.height/3){
//                ChangeEmailView()
//            }
            
            HalfModalView(isShown: $halfModalPasswordShow, modalHeight: 2*UIScreen.main.bounds.height/3){
                ChangePasswordView()
                
            }
        }
    }
    
}

//view used for entering info for changing the user account's info
/*struct ChangeEmailView: View {
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
    
    //function used to change the user's firebase login email
    func changeEmail(){
        error = false
        if(email==confirm_email) {
            Auth.auth().currentUser?.updateEmail(to: email) { (error) in
                if error != nil {
                    self.error = true
                }
                else{
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
    
    //function used to reathenticate the user if necessary
    func reauthenticateUser() {
        let user = Auth.auth().currentUser
    }
} */

//view used for entering info for changing the user account's info
struct ChangePasswordView: View {
    @EnvironmentObject var session: SessionStore
    @State private var old_password = ""
    @State private var password = ""
    @State private var confirm_password = ""
    @State private var error = false
    @State private var secured = true
    @State private var confirm_secured = true
    @State private var old_secured = true
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
                    Text("Old Password:")
                    if old_secured {
                        SecureField("Password", text: $old_password)
                            .textContentType(.oneTimeCode)
                        
                    }
                    else {
                        TextField("Password", text: $old_password)
                            .autocapitalization(UITextAutocapitalizationType.none)
                            .disableAutocorrection(true)
                    }
                    Button( action: {
                        self.old_secured.toggle()
                        
                    }) {
                        if old_secured {
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
            }
        }
    }
    
    //function used to change the user's firebase login password
    func changePassword(){
        let email = Auth.auth().currentUser?.email!
        session.signIn(email: email!, password: old_password) { (result, error) in //sign in to firebase first
            if let _ = error {
                self.error = true
                return
            }
            
            if(password==confirm_password) {
                Auth.auth().currentUser?.updatePassword(to: password) { (error) in
                    if error != nil {
                        self.error = true
                    }
                    else{
                        self.old_password = ""
                        self.password = ""
                        self.confirm_password = ""
                        self.changePasswordSuccess = true
                    }
                }
                
            }
            else {
                self.old_password = ""
                self.password = ""
                self.confirm_password = ""
            }
        }
        
        
        
        
    }
    
    //function used to reauthenticate the user if necessary
    func reauthenticateUser() {
        let user = Auth.auth().currentUser
    }
}

//function that pulls up a smaller view
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

//enum to help deal with the dragging of the modal view
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

//view used for getting and helping the actual view for diaplaying the user's contacts
class ContactListViewModel: ObservableObject {
    var contactService = ContactService()
    
    @Published var newContact = CNContact()
    @Published var contacts: [Contact] = []
    @Published var showNewContact = false
    @Published var noPermission = false
    
    init() {
        self.fetch()
    }
    
    //function used to get the contacts if permission is available
    func fetch() {
        self.contactService.getContacts { (contacts, error) in
            guard error == nil else {
                self.contacts = []
                self.noPermission = true
                return 
            }
            self.contacts = contacts
        }
    }
    
}

//view for actually displaying the contacts
struct ContactsView: View {
    @ObservedObject var viewModel = ContactListViewModel()
    var body: some View {
        ScrollView{
            ForEach(viewModel.contacts){ contact in
                ForEach(contact.phoneNumbers){ number in
                    HStack{
                        VStack{
                            Text("\(contact.fullName())").bold()
                            Text("\(number.number)").font(.footnote)
                        }
                        Spacer()
                        Button(action:{
                            sendMessage(number: number.number)
                            
                        }, label: {
                            Text("Invite")
                                .font(.system(size: 14, weight: .regular, design: .default))
                                .foregroundColor(Color.white)
                                .background(RoundedRectangle(cornerRadius: 10)
                                .fill(Color.blue)
                                .frame(width: 75, height: 30))
                                .padding(.trailing,15)
                        })
                    }.frame(width: UIScreen.main.bounds.width-30)
                    ColorDivider()
                }
            }
        }
    }
    
    //function used to send the user to message a selected contact
    func sendMessage(number: String){
        let sms: String = "sms:+\(number.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: ""))&body=Checkout this cool shopping app I found: [insert App Store Link]"
        let strURL: String = sms.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        UIApplication.shared.open(URL.init(string: strURL)!, options: [:], completionHandler: nil)
    }
}

//preview for the contacts view
struct ContactView_Previews: PreviewProvider {
    static var previews: some View {
        ContactsView()
    }
}

//struct used to represent the info present in a user's contact
struct Contact : Identifiable {
    var id = UUID()
    var givenName: String
    var lastName: String
    
    var phoneNumbers: [PhoneNumber]
    
    var systemContact: CNContact?
    
    struct PhoneNumber : Identifiable {
        var id = UUID()
        var label: String
        var number: String
    }
    
    init(givenName: String, lastName: String, phoneNumbers: [PhoneNumber], systemContact: CNContact){
        self.givenName = givenName
        self.lastName = lastName
        self.phoneNumbers = phoneNumbers
        self.systemContact = systemContact
    }
    
    init(givenName: String, lastName: String, phoneNumbers: [PhoneNumber]){
        self.givenName = givenName
        self.lastName = lastName
        self.phoneNumbers = phoneNumbers
    }
    
    //function to conver a system contact into a contact struct
    static func fromCNContact(contact: CNContact) -> Contact {
        let phoneNumbers = contact.phoneNumbers.map({
            (value: CNLabeledValue<CNPhoneNumber>) -> Contact.PhoneNumber in
            let localized = CNLabeledValue<NSString>.localizedString(forLabel: value.label ?? "")
            return Contact.PhoneNumber.init(label: localized, number: value.value.stringValue)
        })
        return self.init(givenName: contact.givenName, lastName: contact.familyName, phoneNumbers: phoneNumbers, systemContact: contact)
    }
    
    //function that converts first and last name into one string
    func fullName() -> String {
        return "\(self.givenName) \(self.lastName)"
    }
}
