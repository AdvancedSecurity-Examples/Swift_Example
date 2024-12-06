import SwiftUI
import GoogleSignIn
import Firebase
import Combine
import WebKit

struct ForgotPasswordView : View {
    @State private var email = ""
    
    @EnvironmentObject var session: SessionStore
    
    func forgotPassword() {
        session.forgotPassword(email: email){ (result,error) in
            if error != nil {
                print("\(error)")
            }
            else{
                self.email = ""
            }
            
        }
    }
    var body : some View {
        Form {
            Section {
                HStack {
                    Text("Email:")
                    TextField("Email", text: $email)
                        .autocapitalization(UITextAutocapitalizationType.none)
                        .disableAutocorrection(true)
                }
                Button (action: forgotPassword) {
                    Text("Send Password Reset Email")
                }
            }
            
        }.navigationBarTitle("Forgot Password", displayMode: .inline)
    }
}

struct SignUpView : View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirm_password = ""
    @State private var error = false
    @State private var secured = true
    @State private var confirm_secured = true
    
    @EnvironmentObject var session: SessionStore
    
    func signUp() {
        print("sign me up")
        error = false
        if(password==confirm_password) {
            session.signUp(email: email, password: password) { (result, error) in
                if error != nil {
                    print("\(error)")
                    self.error = true
                }
                else {
                    self.email = ""
                    self.password = ""
                    self.confirm_password = ""
                }
                
            }
        }
        else {
            self.email = ""
            self.password = ""
            self.confirm_password = ""
        }
    }
    
    var body : some View {
        
        Form {
            Section(footer:
                Text("At least 8 chracters required.")
            ) {
                HStack {
                Text("Email")
                TextField("email", text: $email)
                    .autocapitalization(UITextAutocapitalizationType.none)
                    .disableAutocorrection(true)
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
                Button(action: signUp) {
                    Text("Sign up")
                }
            }
        }.navigationBarTitle("Sign Up", displayMode: .inline)
        
    }
}

struct SignOutView : View {
    @EnvironmentObject var session: SessionStore
    
    func signOut() {
        session.signOut()
    }
    
    var body : some View {
        VStack {
            Text("You have successfully signed in")
            Button(action: signOut) {
                Text("Sign Out")
            }
        }
    }
}

struct SignInView : View {
    
    @State private var email = ""
    @State private var password = ""
    @State private var loading = false
    @State private var error = false
    @State private var secured = true
    
    @EnvironmentObject var session: SessionStore
    
    func signIn () {
        print("logging in!")
        loading = true
        error = false
        session.signIn(email: email, password: password) { (result, error) in
            self.loading = false
            if error != nil {
                self.error = true
            } else {
                self.email = ""
                self.password = ""
            }
            
            print("result \(result) and error: \(error)")
        }
    }
    
    var body: some View {
        VStack{
            Form {
                Section (footer:
                            HStack {
                                NavigationLink(destination: SignUpView()) {
                                    Text("Don't have an account?")
                                }
                                Spacer()
                                NavigationLink(destination: ForgotPasswordView()) {
                                    Text("Forgot Password?")
                                }
                            }) {
                    if (error) {
                        HStack {
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
                        Text("Password:")
                        if secured {
                            SecureField("Password", text: $password)
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
                        Button(action: signIn) {
                        Text("Login")
                        }
                    }
                    HStack {
                        Button("Sign in with Google") {
                            GIDSignIn.sharedInstance()?.presentingViewController = UIApplication.shared.windows.first?.rootViewController
                            GIDSignIn.sharedInstance().signIn()


                        }
                    }
                    
                }
            
            
            }
            
            Section{
                NavigationLink(destination: PrivacyPolicyView(url: Bundle.main.url(forResource: "privacypolicy", withExtension: "html"))) {
                    Text("Read our privacy policy")
                        .background(Color.clear)
                        .font(.footnote)
                }
            }
           
            
                
            
        }.navigationBarTitle("Login", displayMode: .inline)
        
    }
    
}

struct AuthenticationScreen : View {
    
    var body : some View {
        NavigationView {
            SignInView()
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}



struct PrivacyPolicyView: UIViewRepresentable {
    
    let url: URL?
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let myURL = url else{
            return
        }
        let request = URLRequest(url: myURL)
        uiView.load(request)
    }

}

#if DEBUG
struct Authenticate_Previews : PreviewProvider {
    static var previews: some View {
        AuthenticationScreen()
            .environmentObject(SessionStore())
    }
}
#endif
