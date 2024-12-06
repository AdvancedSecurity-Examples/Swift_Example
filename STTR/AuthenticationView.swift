import SwiftUI
import GoogleSignIn
import Firebase
import Combine
import WebKit
import CryptoSwift
import FBSDKLoginKit
import FBSDKCoreKit

//view for password recovery through firebase
struct ForgotPasswordView : View {
    @State private var email = ""
    
    @EnvironmentObject var session: SessionStore
    
    func forgotPassword() {
        session.forgotPassword(email: email){ (result,error) in //sends email to user email for password reset
            if error != nil {
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

//view for account creation through firebase
struct SignUpView : View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirm_password = ""
    @State private var error = false
    @State private var secured = true
    @State private var confirm_secured = true
    @State private var firstName = ""
    @State private var lastName = ""
    
    @EnvironmentObject var session: SessionStore
    
    //function to sign up user for a firebase account
    func signUp() {
        error = false
        if(password==confirm_password) {
            session.signUp(firstname: firstName, lastname: lastName, email: email, password: password) { (result, error) in
                if error != nil {
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
                if (self.error) {
                    Text("Error")
                }
                HStack {
                    Text("First name")
                    TextField("first name", text: $firstName)
                        .autocapitalization(UITextAutocapitalizationType.none)
                        .disableAutocorrection(true)
                }
                HStack {
                    Text("Last name")
                    TextField("last name", text: $lastName)
                        .autocapitalization(UITextAutocapitalizationType.none)
                        .disableAutocorrection(true)
                }
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

//view for signing out
struct SignOutView : View {
    @EnvironmentObject var session: SessionStore
    
    //function to sign out user from the session
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

//view for signing in through firebase
struct SignInView : View {
    
    @State private var email = ""
    @State private var password = ""
    @State private var loading = false
    @State private var error = false
    @State private var secured = true
    
    @EnvironmentObject var session: SessionStore
    
    //function used to get the user's cart from the server
    func getServerCart(){
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
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue(idToken, forHTTPHeaderField: "idToken")
                request.httpMethod = "GET"

                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                
                    if let data = data {
                        do {
                            if let jsonArray = try JSONSerialization.jsonObject(with: data , options: []) as? [String: AnyObject]
                            {
                                for i in 0..<(jsonArray["cart"] as? [Any])!.count {
                                    //initialize an ingredient from the parsed out response from the server
                                    let ingredient = IngredientsIdentifiable(id: i, ingredientName: ((jsonArray["cart"] as? [Any])![i] as? [String:Any])!["originalName"] as! String, ingredientImageURL: "", amount: NumberFormatter().number(from: ((jsonArray["cart"] as? [Any])![i] as? [String:Any])!["quantityNeeded"] as! String)!.doubleValue, unit: ((jsonArray["cart"] as? [Any])![i] as? [String:Any])!["unit"] as! String)
                                    Database.recipe.cartItems.append(CartItem(item: ingredient, quantity: NumberFormatter().number(from: ((jsonArray["cart"] as? [Any])![i] as? [String:Any])!["quantityInCart"] as! String)!.intValue))
                                }
                            } else {
                            }
                        }
                        catch _ as NSError {
                        }
                    }
                }
                URLCache.shared.removeAllCachedResponses()
                task.resume()
            }
        #else
            url = URL(string: "https://sttrself.martincarlisle.com/youwontguessthisbhVFFX/cart/" + (Auth.auth().currentUser?.email ?? ""))!
            let session = URLSession(
                configuration: URLSessionConfiguration.ephemeral,
                delegate: NSURLSessionPinningDelegate(),
                delegateQueue: nil)
            var request = URLRequest(url: url)
            let semaphore = DispatchSemaphore(value: 0) // initialize semaphore for multithreading
            let currentUser = Auth.auth().currentUser
            currentUser?.getIDToken() { idToken, error in //used to get token from firebase in order to authenticate user with server
                if let _ = error {
                return
                }
                var request = URLRequest(url: url)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue(idToken, forHTTPHeaderField: "idToken")
                request.httpMethod = "GET"

                let task = session.dataTask(with: request) { data, response, error in
                
                    if let data = data {
                        do {
                            if let jsonArray = try JSONSerialization.jsonObject(with: data , options: []) as? [String: AnyObject]
                            {
                                
                                for i in 0..<(jsonArray["cart"] as? [Any])!.count {
                                    //initialize an ingredient from the parsed out response from the server
                                    let ingredient = IngredientsIdentifiable(id: i, ingredientName: ((jsonArray["cart"] as? [Any])![i] as? [String:Any])!["originalName"] as! String, ingredientImageURL: "", amount: NumberFormatter().number(from: ((jsonArray["cart"] as? [Any])![i] as? [String:Any])!["quantityNeeded"] as! String)!.doubleValue, unit: ((jsonArray["cart"] as? [Any])![i] as? [String:Any])!["unit"] as! String)
                                    Database.recipe.cartItems.append(CartItem(item: ingredient, quantity: NumberFormatter().number(from: ((jsonArray["cart"] as? [Any])![i] as? [String:Any])!["quantityInCart"] as! String)!.intValue))
                                }
                            } else {
                            }
                        }
                        catch _ as NSError {
                        }
                    }
                }
                URLCache.shared.removeAllCachedResponses()
                task.resume()
            }
        #endif
    }
    
    //function used to decrypt encrypted strings
    func decryptAES(string: String) throws -> String{
        let aes = try AES(key: [206, 131, 29, 10, 221, 211, 60, 236, 57, 131, 76, 101, 238, 39, 200, 177], blockMode: CBC(iv: [206, 131, 29, 10, 221, 211, 60, 236, 57, 131, 76, 101, 238, 39, 200, 177]))
        let decrypt = try string.decryptBase64ToString(cipher: aes)
        return decrypt
    }
    
    //function used to sign the user into their firebase account
    func signIn () {
        loading = true
        error = false
        session.signIn(email: email, password: password) { (result, error) in
            DispatchQueue.global(qos: .utility).async{
                self.getServerCart() //on log in get their cart from the server
            }
            self.loading = false
            if error != nil {
                self.error = true
            } else {
                self.email = ""
                self.password = ""
            }
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
                            SecureField("Password", text: $password, onCommit: {signIn()})
                        }
                        else {
                            TextField("Password", text: $password, onCommit: {signIn()})
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
                            guard let clientID = FirebaseApp.app()?.options.clientID else { return }

                            // Create Google Sign In configuration object.
                            let config = GIDConfiguration.init(clientID: clientID)

                            // Start the sign in flow!
                            let view = UIApplication.shared.windows.first?.rootViewController
                            GIDSignIn.sharedInstance.signIn(with: config, presenting: view!) { user, error in

                                guard
                                    let authentication = user?.authentication,
                                    let idToken = authentication.idToken,
                                    let user = user
                                else { return }

                                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
                                Auth.auth().signIn(with: credential) { _,_ in}
                                
                                let firstName = user.profile?.givenName ?? ""
                                let lastName = user.profile?.familyName ?? ""
                                let email = user.profile?.email ?? ""
                                
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
                                        "firstname": firstName,
                                        "lastname": lastName,
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
                            }
                        }
                    }
                    HStack{
                        login()
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

struct login : UIViewRepresentable {
    
    @EnvironmentObject var session: SessionStore
    
    func makeCoordinator() -> login.Coordinator {
        return login.Coordinator()
    }
    
    func makeUIView(context: UIViewRepresentableContext<login>) -> FBLoginButton {
        let button = FBLoginButton()
        button.delegate = context.coordinator
        button.permissions = ["public_profile", "email"]
        return button
    }
    
    func updateUIView(_ uiView: FBLoginButton, context: UIViewRepresentableContext<login>) {
        
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
                    
                    let requestedFields = "email, first_name, last_name"
                    GraphRequest.init(graphPath: "me", parameters: ["fields":requestedFields]).start { (connection, result, error) -> Void in
                        let userInfo = Auth.auth().currentUser?.providerData[0]
                        print(Auth.auth().currentUser?.email!)
                        print("Success")
                        var firstName = ""
                        var lastName = ""
                        var email = ""
                        let info = result as! [String : AnyObject]
                        if info["first_name"] as? String != nil {
                            firstName = info["first_name"] as! String
                        }
                        if info["last_name"] as? String != nil {
                            lastName = info["last_name"] as! String
                        }
                        if info["email"] as? String != nil {
                            email = info["email"] as! String
                        }
                        
                        var url = URL(string: "https://www.google.com")!
                        #if HTTP_F
                        do{
                            try url = URL(string: self.decryptAES(string: "5eu+q4ykxQv4VoqKDniVjGU5oBSOJIgwJtoyFKqvFioXJVnIJOtXaiyxejgyN+dIC20h+lxJZe1wP+FghOlyxw=="))!
                        } catch{}
                        #else
                            url = URL(string: "http://sttr.martincarlisle.com/youwontguessthisbhVFFX/addUser")!
                        #endif
                        var request = URLRequest(url: url)
                        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                        request.httpMethod = "POST"
                        
                        let parameters: [String: Any] = [
                                "firstname": firstName,
                                "lastname" : lastName,
                                "email"    : email
                            ]
                        
                        request.httpBody = parameters.percentEncoded()
                        
                        
                        let task = URLSession.shared.dataTask(with: request) { data, response, error in
                            print("In dataTask")
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

//view for displaing the authentication screen
struct AuthenticationScreen : View {
    
    var body : some View {
        NavigationView {
            SignInView()
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}


//view for holding the privacy policy html file
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

