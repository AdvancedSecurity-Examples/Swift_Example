//
//  CartView.swift
//  STTR
//
//  Created by Brady  on 3/16/21.
//

import SwiftUI
import Foundation
import WebKit
import UIKit
import SwiftKeychainWrapper
import CryptoSwift
import AlertToast


var link = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
//View used to display the cart
struct CartView: View {
    static var krogerRefreshToken : String? //used to hold refresh token from Kroger
    @State var update: String = "update" //used to update the view due to issues with other state variables not updating changes
    @State var total: Float = 0 //price total of items in cart
    @State var openKroger : Bool = false //used for webview
    @State var code : String = ""
    static var access_token : String = ""
    @State var showToast = false //used for toast popup
    @State var badToast = false //used for toast popup
    @State var refresh_token : String = ""
    
    
    static var krogerItemsJSON : [String : Any] = [:]
    var body: some View {
        VStack {
            ScrollView(.vertical, showsIndicators: false){
                VStack(spacing: 0){
                    ForEach(Database.recipe.cartItems){ cartItem in //creates a CartItemView for each item put into the cart
                        CartItemView(view : self, cart: cartItem).onAppear(perform: {
                            
                            if (locationServices.zipcode != nil) { //if location is defined update the view to replace the text with location prompt
                                update+=" "
                            }
                            })
                    }
                }
            }.onAppear(perform: { total = 0
                if (locationServices.zipcode != nil) { //if location is defined update the view to replace the text with location prompt
                    update += " "
                }
            })
            VStack{
                HStack{
                    Text(String(format: "Total: $%.2f",abs(total)))
                        .fontWeight(.heavy)
                        .foregroundColor(.gray)
                }
                .padding([.top,.horizontal,.bottom])

                Button(action: {
                    CartView.krogerRefreshToken = KeychainWrapper.standard.string(forKey: "refreshToken") ?? "" //check if a refresh token is stored in the keychain
                    DispatchQueue.global(qos: .utility).async{
                        link = getLink()
                        if(CartView.krogerRefreshToken == ""){ //if not refresh open the login page
                            self.openKroger = true
                        }
                        else{ // if a refresh token exists skip login
                            pushToCart()
                       }
                    }
                                       
                }){
                    Text("Add To Kroger Cart").font(.system(size: 20, weight: .regular, design: .default))
                        .foregroundColor(Color.white)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue).frame(width: 250, height: 40))
                        .padding(.trailing,15).padding(.bottom,4)
                }
                .sheet(isPresented: $openKroger){ //when true open the login page
                    let send = link
                    WebView(url : URL(string: send)!, cart : self).onAppear(perform: {
                    })
                }
                Text("\(update)").font(.system(size:1)).foregroundColor(.clear) //used to update the view, does not appear
                
            }
        }
        .toast(isPresenting: $showToast, duration: 2){
            AlertToast(displayMode : .alert, type: .complete(Color.green), title: "Item(s) Added to Kroger Cart") // Toast to signal that the cart was sent to kroger successfully
        }
        .toast(isPresenting: $badToast, duration: 2){
            AlertToast(displayMode : .alert, type: .error(Color.red), title: "Error", subTitle : "Failed To Add Items To Kroger Cart") //Toast to siganl that the cart was NOT sent to kroger successfully
        }
    }
    
    //function used to decrypt the encrypted strings
    //send AES encrypted string, returns unencrypted
    func decryptAES(string: String) throws -> String{
        let aes = try AES(key: [206, 131, 29, 10, 221, 211, 60, 236, 57, 131, 76, 101, 238, 39, 200, 177], blockMode: CBC(iv: [206, 131, 29, 10, 221, 211, 60, 236, 57, 131, 76, 101, 238, 39, 200, 177]))
        let decrypt = try string.decryptBase64ToString(cipher: aes)
        return decrypt
    }
    
//    function used to create a link to the
//    Kroger login page with a redirect to
//    https://sttr.martincarlisle.com/callback
    func getLink() -> String{
        let krogerInfo : KrogerAPI = KrogerAPI()
        //create a url using KrogerAPI
        let urlsession : urlSesssion = urlSesssion()
        var combined = "https://www.google.com"
        let group = DispatchGroup()
        group.enter()
        let semaphore = DispatchSemaphore(value: 0)
            do{
                var clientId = ""
                    #if EMBED_F
                    
                            #if HTTP_F
                                do{
                                    try clientId = urlsession.getData(from: self.decryptAES(string: krogerInfo.client_id_url), group: group)
                                } catch{}
                            #else
                                clientId = urlsession.getData(from: krogerInfo.client_id_url)
                            #endif
                    
                    #else
                            clientId = "grocerycomparison-7d6244ca44a0d50f560f1399f7cb796d3023204378126220438"
                    #endif
                

                        do{
                            try combined = decryptAES(string: krogerInfo.baseURL) + "/connect/oauth2/authorize?" + "scope=cart.basic:write&response_type=code&client_id=" + clientId  + "&redirect_uri=" + (decryptAES(string: "5eu+q4ykxQv4VoqKDniVjGU5oBSOJIgwJtoyFKqvFipQLVV8pc0HNjwWAgejT/Xl"))
                        } catch{}
                //includes AES encrypted string for redirect uri
                //translates to https://sttr.martincarlisle.com/callback
                semaphore.signal()
            } catch{
            }
        _ = semaphore.wait(timeout: .distantFuture)
        return combined
    }
    
    
//    function used to refresh a users access token
//    uses refresh token stored in keychain
    func refreshCartToken(){
        let semaphore = DispatchSemaphore(value : 0)
        let krogerItem : KrogerAPI = KrogerAPI()
        var base = "https://www.google.com"
        do{
            try base = decryptAES(string: "mxOe3x/ZiWuJBk/Avo6Ukhnj0ijEPvwdf8/w+KbeFk4=") //translates to Kroger API URL
        }catch{}
        let combined = base + "/connect/oauth2/token"
        let combinedURL = NSURL(string : combined)! as URL
        let request = NSMutableURLRequest(url : combinedURL)
        request.httpMethod = "POST"
        var headers = [String : String]()
        #if HTTP_F
        do{
        try headers = [
            "Content-Type" : "application/x-www-form-urlencoded",
            "Authorization" : "Basic " + krogerItem.urlsession.getData(from : decryptAES(string: krogerItem.krogerAuthUrl))
        ]
        } catch{}
        #else
        headers = [
            "Content-Type" : "application/x-www-form-urlencoded",
            "Authorization" : "Basic " + krogerItem.urlsession.getData(from:krogerItem.krogerAuthUrl)
        ]
        #endif
        var body = URLComponents()
        body.queryItems = [URLQueryItem(name : "grant_type", value : "refresh_token"), URLQueryItem(name : "refresh_token", value : CartView.krogerRefreshToken)]
        request.httpBody = body.query?.data(using  : .utf8)
        request.allHTTPHeaderFields = headers
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler : {(data, response, error) in
            if let error = error {
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                return
            }
            if let data = data {
                do {
                    if let jsonArray = try JSONSerialization.jsonObject(with: data , options: []) as? [String: AnyObject]
                    {
                        let saveSuccessful = KeychainWrapper.standard.set(jsonArray["refresh_token"] as! String, forKey: "refreshToken")
                        //get refresh token in order to skip login on later (if available)
                        if(saveSuccessful == true){
                            CartView.krogerRefreshToken = KeychainWrapper.standard.string(forKey: "refreshToken")
                        }
                        CartView.access_token = jsonArray["access_token"] as! String
                    }
                    else {
                    }
                } catch let error as NSError {
                }
                
            }
            semaphore.signal()
        })
        URLCache.shared.removeAllCachedResponses()
        task.resume()
        _ = semaphore.wait(wallTimeout: .distantFuture)
    }
    
//    function used to get the refresh token using a
//    user's access token
    func requestCartToken(){
            let semaphore = DispatchSemaphore(value: 0)
            let krogerItem : KrogerAPI = KrogerAPI()
            krogerItem.getAccessToken()//Request items from Kroger API
        
            var base = "https://www.google.com"
            do{
                try base = decryptAES(string: "mxOe3x/ZiWuJBk/Avo6Ukhnj0ijEPvwdf8/w+KbeFk4=") //translates to Kroger API URL
            }catch{}
            let Icombined = base + "/connect/oauth2/token"
            let combinedURL = NSURL(string : Icombined)! as URL
            let Irequest = NSMutableURLRequest(url: combinedURL)
            Irequest.httpMethod = "POST"
        var Iheaders = [String : String]()
        #if HTTP_F
            do{
            try Iheaders = [
                "Authorization" : "Basic " +  krogerItem.urlsession.getData(from: decryptAES(string: krogerItem.krogerAuthUrl)), "Content-Type" : "application/x-www-form-urlencoded"
            ]
            } catch {}
        #else
            Iheaders = [
                "Authorization" : "Basic " +  krogerItem.urlsession.getData(from:krogerItem.krogerAuthUrl), "Content-Type" : "application/x-www-form-urlencoded"
            ]
        #endif
           var body = URLComponents()
            do{
                try body.queryItems = [URLQueryItem(name : "grant_type", value : "authorization_code"), URLQueryItem(name : "code", value : code), URLQueryItem(name : "redirect_uri", value : decryptAES(string: "5eu+q4ykxQv4VoqKDniVjGU5oBSOJIgwJtoyFKqvFipQLVV8pc0HNjwWAgejT/Xl"))]
            } catch{}
           Irequest.httpBody = body.query?.data(using : .utf8)
            Irequest.allHTTPHeaderFields = Iheaders
            let Itask = URLSession.shared.dataTask(with: Irequest as URLRequest , completionHandler: { (data, response, error) in
                if let error = error {
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    return
                }
                if let data = data {
                    do {
                        if let jsonArray = try JSONSerialization.jsonObject(with: data , options: []) as? [String: AnyObject]
                        {
                            let saveSuccessful = KeychainWrapper.standard.set(jsonArray["refresh_token"] as! String, forKey: "refreshToken")
                            if(saveSuccessful == true){
                                CartView.krogerRefreshToken = KeychainWrapper.standard.string(forKey: "refreshToken")
                            }
                            CartView.access_token = jsonArray["access_token"] as! String //save access token
                        }
                        else {
                        }
                    } catch let error as NSError {
                    }
                    
                }
                semaphore.signal()
            })
            URLCache.shared.removeAllCachedResponses()
            Itask.resume()
            _ = semaphore.wait(wallTimeout: .distantFuture)
    }
    
    
//    converts the current kroger items stored in the cart into a JSON format
//    used in order to push the cart to kroger
//    also removes the items from the cart
    func cartToJSON() -> Dictionary<String, Any>{
        var krogerCart : Dictionary<String, Any> = [:]
        var toAdd : Dictionary<String, Any> = [:]
        var arrToAdd = [Dictionary<String,Any>]()
        for cart in Database.recipe.cartItems{
            if(cart.krogerReplace.id != "" ){
                toAdd["upc"] = cart.krogerReplace.upc
                toAdd["quantity"] = cart.quantity
                arrToAdd.append(toAdd)
                // Remove the ingredient from the cart
                Database.recipe.removeFromCart(ingredient: cart.item)
            }
        }
        total = 0
        krogerCart["items"] = arrToAdd
        total = 0
        return krogerCart
    }
    
//    function used to push all of the current kroger items
//    in the cart to the user's cart on kroger.com
    func pushToCart(){
        var body : [String : Any]
            let krogerItem : KrogerAPI = KrogerAPI()
            var base = "https://www.google.com"
            do{
                try base = decryptAES(string: "mxOe3x/ZiWuJBk/Avo6Ukhnj0ijEPvwdf8/w+KbeFk4=") //translates to Kroger API URL
            }catch{}
            let Icombined = base + "/cart/add"
            let combinedURL = NSURL(string : Icombined)! as URL
            let Irequest = NSMutableURLRequest(url: combinedURL)
            Irequest.httpMethod = "PUT"
        //change all after authorization
            let Iheaders = [
                //Delete after authorization
                "Authorization" : "Bearer " + CartView.access_token,
                "Accept" : "application/json",
                "Content-Type" : "application/json"
            ]
        if(CartView.krogerItemsJSON.isEmpty){
            body = cartToJSON()
            
            CartView.krogerItemsJSON = body
        }
        else{
            body = CartView.krogerItemsJSON
        }
            let data = try! JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
            Irequest.httpBody = data
            Irequest.allHTTPHeaderFields = Iheaders
            let Itask = URLSession.shared.dataTask(with: Irequest as URLRequest , completionHandler: { (data, response, error) in
                if let error = error {
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    if((response as? HTTPURLResponse)?.statusCode == 401){
                        DispatchQueue.global(qos: .utility).async{
                            refreshCartToken()
                            pushToCart()
                        }
                    }
                    else{
                        badToast.toggle() //if you receive a bad response toggle the bad toast
                    }
                    return
                }
                showToast.toggle() //show toast regardless of good or bad result
                CartView.krogerItemsJSON.removeAll() //remove all of the kroger items from the cart view
            })
            URLCache.shared.removeAllCachedResponses()
            Itask.resume()
        }
    
}


//view used to display the kroger login
//page for OAuth2 Authentication
struct WebView: UIViewRepresentable {
    var url: URL
    @Environment(\.presentationMode) var presentation
    var loadStatusChanged: ((Bool, Error?) -> Void)? = nil
    var cart : CartView
    
    //function called internally to make WebView work
    func makeCoordinator() -> WebView.Coordinator {
        Coordinator(self)
    }
    
    //function called internally to make WebView work
    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView()
        view.navigationDelegate = context.coordinator
        view.load(URLRequest(url: URL(string: link)!))
        return view
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // you can access environment via context.environment here
        // Note that this method will be called A LOT
    }

    func onLoadStatusChanged(perform: ((Bool, Error?) -> Void)?) -> some View {
        var copy = self
        copy.loadStatusChanged = perform
        return copy
    }

    //internal class used to define behavior for the WebView
    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebView
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        //class used to decrypt encrypted string
        //the strings are encrypted with AES and translated to Base64
        //if you need to translate a string you can get it by using the command:
        //  try string.encryptToBase64(cipher: aes)
        func decryptAES(string: String) throws -> String{
            let aes = try AES(key: [206, 131, 29, 10, 221, 211, 60, 236, 57, 131, 76, 101, 238, 39, 200, 177], blockMode: CBC(iv: [206, 131, 29, 10, 221, 211, 60, 236, 57, 131, 76, 101, 238, 39, 200, 177]))
            let decrypt = try string.decryptBase64ToString(cipher: aes)
            return decrypt
        }
        
        //most important function for the WebView functionality
        //defines how the WebView redirects back to the app after login
        //also gets the authorization code from the redirect URL
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            
            var checkHost = "https://www.google.com"
            do{
                try checkHost = decryptAES(string: "7peGDFhQ2fK084totSpPpnqE+FTXKlBMBioHehzUTdY=")
            } catch{}
            
            if let host = navigationAction.request.url?.host {
              if host == checkHost{
                let sURL : String = "\(webView.url!)"
                let urlList = sURL.components(separatedBy: "=")
                parent.cart.code = urlList[1]
                parent.cart.update += " "
                DispatchQueue.global(qos: .utility).async{
                    self.parent.cart.requestCartToken()
                    self.parent.cart.pushToCart()
                }
                parent.presentation.wrappedValue.dismiss()
                decisionHandler(.cancel)
                return
              }
            }
            decisionHandler(.allow)
        }
    }
}

//view used to display the individual items in the cart
struct CartItemView: View {
    @EnvironmentObject var recipe: RecipeInfo
    var view : CartView
    @ObservedObject var cart: CartItem
    @Environment(\.colorScheme) var colorScheme //used to determine dark mode vs light mode
    
    var body: some View{
        if(colorScheme != .dark){ //light mode
            HStack(spacing: 15){
                if(cart.krogerReplace.id != ""){ //if a kroger item has been selected, replace the generic info with a kroger image and price
                    if(colorScheme != .dark){
                        KrogerImageView(withURL: cart.krogerReplace.image ?? "")
                            .frame(width: 40, height: 40)
                            .onAppear(perform: {
                                let subPrice = Float(cart.krogerReplace.price!)!
                                let priceQuant = subPrice*Float(cart.quantity)
                                view.total += priceQuant
                            })
                    } else {
                        KrogerImageView(withURL: cart.krogerReplace.image ?? "")
                            .frame(width: 40, height: 40)
                            .onAppear(perform: {
                                let subPrice = Float(cart.krogerReplace.price!)!
                                let priceQuant = subPrice*Float(cart.quantity)
                                view.total += priceQuant
                            })
                            .background(Color(red: 0.2, green: 0.2, blue: 0.2))
                            .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                    }
                }
                VStack(alignment: .leading, spacing: 10){
                    if(KrogerAPI.locationID == ""){ //if location hasn't been selected yet make the name a link to locationView instead
                        NavigationLink(destination: locationView()){
                            Text("Press to find stores")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                    .lineLimit(2)
                               
                        }.isDetailLink(false)
                    }
                    else{
                        NavigationLink(destination: KrogerView(searchval: cart.item.ingredientName ?? "No ingredient found", cartItem: cart)){
                            if(cart.krogerReplace.id == ""){
                                Text(cart.item.ingredientName ?? "No ingredient found")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                    .lineLimit(2)
                                    
                           }
                            else{
                                Text(cart.krogerReplace.description ?? "No ingredient found")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                    .lineLimit(2)
                                   
                            }
                        }.isDetailLink(false)
                    }
                    HStack(spacing: 7){
                        Text("Price: ")
                            .fontWeight(.heavy)
                            .foregroundColor(.black)
                        if(cart.krogerReplace.id != ""){
                            Text("$\(cart.krogerReplace.price ?? "")").fontWeight(.heavy)
                                .foregroundColor(.black)
                        }
                        Spacer(minLength: 0)
                        VStack{
                            Text("Quantity")
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                            HStack(spacing : 5){
                                //minus button
                                Button(action: {
                                    if(cart.quantity > 0){
                                        cart.quantity-=1
                                        view.update+=" "
                                    }
                                    if(cart.quantity <= 0){
                                        recipe.removeFromCart(ingredient: cart.item)
                                        view.update+=" "
                                    }
                                    if(cart.krogerReplace.id != ""){
                                        let subPrice = Float(cart.krogerReplace.price!)!
                                        view.total -= subPrice
                                        view.update+=" "
                                    }
                                }){
                                    Image(systemName: "minus")
                                        .font(.system(size: 10, weight: .heavy))
                                        .foregroundColor(.black)
                                }
                                //Quantity of item
                                HStack{
                                    Text("\(cart.quantity)")
                                    .fontWeight(.heavy)
                                    .foregroundColor(.black)
                                    .padding(.vertical,5)
                                    .padding(.horizontal,8)
                                    .background(Color.black.opacity(0.06))
                                }
                                //Plus button
                                Button(action: {cart.quantity+=1
                                    if(cart.krogerReplace.id != ""){
                                        let subPrice = Float(cart.krogerReplace.price!)!
                                        view.total += subPrice
                                        view.update+=" "
                                    }
                                }){
                                    Image(systemName: "plus")
                                        .font(.system(size: 10, weight: .heavy))
                                        .foregroundColor(.black)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            .contentShape(RoundedRectangle(cornerRadius: 15))
            
        } else { //dark mode
            HStack(spacing: 15){
                if(cart.krogerReplace.id != ""){ //if a kroger item has been selected, replace the generic info with a kroger image and price
                    if(colorScheme != .dark){
                        KrogerImageView(withURL: cart.krogerReplace.image ?? "")
                            .frame(width: 40, height: 40)
                            .onAppear(perform: {
                                let subPrice = Float(cart.krogerReplace.price!)!
                                let priceQuant = subPrice*Float(cart.quantity)
                                view.total += priceQuant
                            })
                    } else {
                        KrogerImageView(withURL: cart.krogerReplace.image ?? "")
                            .frame(width: 40, height: 40)
                            .onAppear(perform: {
                                let subPrice = Float(cart.krogerReplace.price!)!
                                let priceQuant = subPrice*Float(cart.quantity)
                                view.total += priceQuant
                            })
                            .background(Color(red: 0.2, green: 0.2, blue: 0.2))
                            .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                    }
                }
                VStack(alignment: .leading, spacing: 10){
                    if(KrogerAPI.locationID == ""){ //if location hasn't been selected yet make the name a link to locationView instead
                        NavigationLink(destination: locationView()){
                            Text("Press to find stores")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                    .lineLimit(2)
                               
                        }.isDetailLink(false)
                    }
                    else{
                        NavigationLink(destination: KrogerView(searchval: cart.item.ingredientName ?? "No ingredient found", cartItem: cart)){
                            if(cart.krogerReplace.id == ""){
                                Text(cart.item.ingredientName ?? "No ingredient found")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                    .lineLimit(2)
                                    
                           }
                            else{
                                Text(cart.krogerReplace.description ?? "No ingredient found")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                    .lineLimit(2)
                                   
                            }
                        }.isDetailLink(false)
                    }
                    HStack(spacing: 7){
                        Text("Price: ")
                            .fontWeight(.heavy)
                            .foregroundColor(.black)
                        if(cart.krogerReplace.id != ""){
                            Text("$\(cart.krogerReplace.price ?? "")").fontWeight(.heavy)
                                .foregroundColor(.black)
                        }
                        Spacer(minLength: 0)
                        VStack{
                            Text("Quantity")
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                            HStack(spacing : 5){
                                //minus button
                                Button(action: {
                                    if(cart.quantity > 0){
                                        cart.quantity-=1
                                        view.update+=" "
                                    }
                                    if(cart.quantity <= 0){
                                        recipe.removeFromCart(ingredient: cart.item)
                                        view.update+=" "
                                    }
                                    if(cart.krogerReplace.id != ""){
                                        let subPrice = Float(cart.krogerReplace.price!)!
                                        view.total -= subPrice
                                        view.update+=" "
                                    }
                                }){
                                    Image(systemName: "minus")
                                        .font(.system(size: 10, weight: .heavy))
                                        .foregroundColor(.black)
                                }
                                //Quantity of item
                                HStack{
                                    Text("\(cart.quantity)")
                                    .fontWeight(.heavy)
                                    .foregroundColor(.black)
                                    .padding(.vertical,5)
                                    .padding(.horizontal,8)
                                    .background(Color.black.opacity(0.06))
                                }
                                //Plus button
                                Button(action: {cart.quantity+=1
                                    if(cart.krogerReplace.id != ""){
                                        let subPrice = Float(cart.krogerReplace.price!)!
                                        view.total += subPrice
                                        view.update+=" "
                                    }
                                }){
                                    Image(systemName: "plus")
                                        .font(.system(size: 10, weight: .heavy))
                                        .foregroundColor(.black)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            .contentShape(RoundedRectangle(cornerRadius: 15))
            .background(Color(red: 0.2, green: 0.2, blue: 0.2))
        }
        ColorDivider()
    }
}
