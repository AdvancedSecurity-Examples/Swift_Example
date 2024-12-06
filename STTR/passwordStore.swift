//
//  KrogerAPI.swift
//  STTR
//
//  Created by Siddharth N. on 3/10/21.
//
import Foundation
import SwiftUI
import Combine

//class used for all things KrogerAPI
//used to get information like clientID and access tokens
//to make kroger API calls happen
class KrogerAPI : ObservableObject {
    let objectWillChange = PassthroughSubject<KrogerAPI, Never>()
    public static var locationID: String = ""
    
    @Published var resultList :[NSDictionary] =  [] {
        willSet {
            objectWillChange.send(self)
        }
    }
    @Published var KrogerItems: [KrogerItem] = []
    
    @State private var domainUrlString = "https://api.kroger.com/v1/products?"
    @State var baseURL = "https://api.kroger.com/v1/"
    #if SECURE
        @State var client_id_url = "https://sttr.martincarlisle.com/youwontguessthisbhVFFX/client_id"
    #else
        @State var client_id_url = "http://sttr.martincarlisle.com/youwontguessthisbhVFFX/client_id"
    #endif
    
    let urlsession = urlSesssion()
    
    #if SECURE
        let krogerAuthUrl = "https://sttr.martincarlisle.com/youwontguessthisbhVFFX/kroger_auth_token"
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
            self.getAccessToken()
            let Icombined = (self.domainUrlString + "filter.term=" + searchval + "&filter.locationId=" + KrogerAPI.locationID + "&filter.limit=25").addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
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
            Itask.resume()
        }
    }
    
    //function used to get the clientId from the Docker server
    func getClientId() -> String {
        var clientId : String = ""
        let semaphore = DispatchSemaphore(value: 0)
        #if SECURE
       
            clientId = self.urlsession.getData(from: self.client_id_url)
            semaphore.signal()
        #else
                clientId = "grocerycomparison-7d6244ca44a0d50f560f1399f7cb796d3023204378126220438"
        #endif
        _ = semaphore.wait(wallTimeout: .distantFuture)
        return clientId
    }
    
    //function used to get an access token from Kroger through an API call
    func getAccessToken(){
        let combined = baseURL + "connect/oauth2/token?" + details
        let url = URL(string :combined)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        #if SECURE
            let krogerAuth = urlsession.getData(from: krogerAuthUrl)
            // print("SECURE")
        #else
        let krogerAuth = "Z3JvY2VyeWNvbXBhcmlzb24tN2Q2MjQ0Y2E0NGEwZDUwZjU2MGYxMzk5ZjdjYjc5NmQzMDIzMjA0Mzc4MTI2MjIwNDM4Om96Y0dUSXNSN2xSclhIbHF4d0hYMWwwMVlVMmk2dTFqc29QNEdBVEQ="
            // print("UNSECURE")
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
                //print("Error with fetching films: \(error)")
                return
            } else {
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                //print("Error with the response, unexpected status code: \(String(describing: response))")
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
        task.resume()
        _ = semaphore.wait(wallTimeout: .distantFuture)
    }
}
