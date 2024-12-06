//
//  KrogerAPI.swift
//  STTR
//
//  Created by Siddharth N. on 3/10/21.
//
import Foundation
import SwiftUI
import Combine
import CryptoSwift


//class used for all things KrogerAPI
//used to get information like clientID and access tokens
//to make kroger API calls happen
class KrogerAPI : ObservableObject {
    let objectWillChange = PassthroughSubject<KrogerAPI, Never>()
    public static var locationID: String = ""
    @Published var KrogerItems: [KrogerItem] = []
    
    @State var baseURL = "mxOe3x/ZiWuJBk/Avo6Ukhnj0ijEPvwdf8/w+KbeFk4="
    #if HTTP_F
        @State var client_id_url =
            "5eu+q4ykxQv4VoqKDniVjGU5oBSOJIgwJtoyFKqvFioXJVnIJOtXaiyxejgyN+dI3imLFcU7Q2D+8/Vcil39kA0ayh23/OZw/IHVvMGw9ms="
            //translates to https://sttr.martincarlisle.com/youwontguessthisbhVFFX/client_id
    #else
        @State var client_id_url = "http://sttr.martincarlisle.com/youwontguessthisbhVFFX/client_id"
    #endif
    
    let urlsession = urlSesssion()
    
    #if HTTP_F
        let krogerAuthUrl = "5eu+q4ykxQv4VoqKDniVjGU5oBSOJIgwJtoyFKqvFioXJVnIJOtXaiyxejgyN+dIDXAamJfBN8Ps8UibR2d232P6mgOlx9ViIGivh6xXo+w="
    //translates to https://sttr.martincarlisle.com/youwontguessthisbhVFFX/kroger_auth_token
    #else
        let krogerAuthUrl = "http://sttr.martincarlisle.com/youwontguessthisbhVFFX/kroger_auth_token"
    #endif
    
    
    @State private var details = "grant_type=client_credentials&scope=product.compact"
    @EnvironmentObject var session: SessionStore
    var token : String?
    
    //function used search for items from kroger
    //sends and API request to Kroger that sends
    //the searchval and hands off the items returned to the passed in KrogerView
    func getProducts(searchval: String, krogerView: KrogerView) {
        DispatchQueue.global(qos: .utility).async{
            self.KrogerItems.removeAll()
            var base = "http://www.google.com"
            self.getAccessToken()
            do{
                try base = self.decryptAES(string: self.baseURL)
            }catch{}
            let Icombined = (base + "/products?filter.term=" + searchval + "&filter.locationId=" + KrogerAPI.locationID + "&filter.limit=25").addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            let combinedURL = NSURL(string : Icombined)! as URL
            let Irequest = NSMutableURLRequest(url: combinedURL)
            Irequest.httpMethod = "GET"
            let Iheaders = [
                "Authorization" : "Bearer " + self.token!,
                "Cache-Control" : "no-cache"
            ]
            Irequest.allHTTPHeaderFields = Iheaders
            let Itask = URLSession.shared.dataTask(with: Irequest as URLRequest , completionHandler: { (data, response, error) in
                if error != nil {
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
                            //parsing the heavily nested json returned by Kroger
                            for i in 0..<(jsonArray["data"] as? [Any])!.count {
                                self.KrogerItems.append(KrogerItem(
                                    id: (((jsonArray["data"] as? [Any])![i] as? [String: Any])!["productId"]) as! String,
                                    upc: (((jsonArray["data"] as? [Any])![i] as? [String: Any])!["upc"]) as? String,
                                    brand: (((jsonArray["data"] as? [Any])![i] as? [String: Any])?["brand"]) as? String,
                                    image: "https://www.kroger.com/product/images/medium/front/" + ((((jsonArray["data"] as? [Any])![i] as? [String: Any])!["productId"]) as! String),
                                    description: (((jsonArray["data"] as? [Any])![i] as? [String: Any])!["description"]) as? String,
                                    price: (String(describing: ((((((((jsonArray["data"] as? [Any])![i] as? [String: Any])!["items"]) as? [Any])![0]) as? [String: Any])?["price"]) as? [String: Any])?["regular"] ?? ""))
                                ))
                                let priceAsFloat = Float(self.KrogerItems[i].price ?? "") ?? 0
                                self.KrogerItems[i].price = String(format: "%.2f", priceAsFloat)
                            }
                            self.KrogerItems.removeAll { value in
                                return value.price == "0.00"
                            }
                            krogerView.updateView()
                        }
                    } catch _ as NSError {
                    }
                }
            })
            URLCache.shared.removeAllCachedResponses()
            Itask.resume()
        }
    }
    
    //function used to decrypt the encrypted strings
    func decryptAES(string: String) throws -> String{
        let aes = try AES(key: [206, 131, 29, 10, 221, 211, 60, 236, 57, 131, 76, 101, 238, 39, 200, 177], blockMode: CBC(iv: [206, 131, 29, 10, 221, 211, 60, 236, 57, 131, 76, 101, 238, 39, 200, 177]))
        let decrypt = try string.decryptBase64ToString(cipher: aes)
        return decrypt
    }
    
    //function used to get the clientId from the Docker server
    func getClientId() -> String {
        var clientId : String = ""
        let semaphore = DispatchSemaphore(value: 0)
        DispatchQueue.global(qos: .default).async{
            #if EMBED_F
                #if HTTP_F
                    do{
                        try clientId = self.urlsession.getData(from: self.decryptAES(string: self.client_id_url))
                    } catch{}
                #else
                    clientId = self.urlsession.getData(from: self.client_id_url)
                #endif
                    semaphore.signal()
            #else
                    clientId = "grocerycomparison-7d6244ca44a0d50f560f1399f7cb796d3023204378126220438"
                semaphore.signal()
            #endif
        }
        _ = semaphore.wait(wallTimeout: .distantFuture)
        return clientId
        
    }
    
    //function used to get an access token from Kroger through an API call
    func getAccessToken(){
        var base = "https://www.google.com"
        do{
            try base = decryptAES(string: baseURL)
        }catch{}
        let combined = base + "/connect/oauth2/token?" + details
        let url = URL(string :combined)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        var krogerAuth = ""
        #if EMBED_F
            #if HTTP_F
                do{
                    try krogerAuth = urlsession.getData(from: decryptAES(string:  krogerAuthUrl))
                } catch {}
            #else
                krogerAuth = urlsession.getData(from: krogerAuthUrl)
            #endif
        #else
            krogerAuth = "Z3JvY2VyeWNvbXBhcmlzb24tN2Q2MjQ0Y2E0NGEwZDUwZjU2MGYxMzk5ZjdjYjc5NmQzMDIzMjA0Mzc4MTI2MjIwNDM4Om96Y0dUSXNSN2xSclhIbHF4d0hYMWwwMVlVMmk2dTFqc29QNEdBVEQ="
        #endif
        let Auth = "Basic " + krogerAuth
        let headers = [
            "Authorization" : Auth,
            "Content-Type" : "application/x-www-form-urlencoded"
        ]
        request.allHTTPHeaderFields = headers
        
        let semaphore = DispatchSemaphore(value: 0)
        let task = URLSession.shared.dataTask(with: request , completionHandler: { (data, response, error) in
            
            if let error = error {
                return
            } else {
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                return
            }
            if let data = data {
                do {
                    if let jsonArray = try JSONSerialization.jsonObject(with: data , options: []) as? [String: Any]
                    {
                        self.token = jsonArray["access_token"] as! String?
                    }
                } catch _ as NSError {
                }
            }
            semaphore.signal()
        })
        URLCache.shared.removeAllCachedResponses()
        task.resume()
        _ = semaphore.wait(wallTimeout: .distantFuture)
    }
}
