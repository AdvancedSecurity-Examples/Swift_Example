//
//  LocationView.swift
//  STTR
//
//  Created by Joshua Johnson on 5/21/21.
//

import Foundation
import SwiftUI
import Foundation
import MapKit
import UIKit
import CoreLocation
import CryptoSwift

//struct used to store location info
struct storeValues : Identifiable {
    var id : Int = -1
    var phone : String? = nil
    var name : String = ""
    var locationId : String = ""
    var state : String = ""
    var zipCode : String = ""
    var address : String = ""
}


//class used to find the nearby Kroger locations near the user's zipcode
class findLocation : ObservableObject {
    @Published var krogerLocations: [storeValues] = []
    
    //function used to decrypt encrypted strings
    func decryptAES(string: String) throws -> String{
        let aes = try AES(key: [206, 131, 29, 10, 221, 211, 60, 236, 57, 131, 76, 101, 238, 39, 200, 177], blockMode: CBC(iv: [206, 131, 29, 10, 221, 211, 60, 236, 57, 131, 76, 101, 238, 39, 200, 177]))
        let decrypt = try string.decryptBase64ToString(cipher: aes)
        return decrypt
    }
    
    
    //most important function
    func getLocation(zip: String, view: locationView){
        
        DispatchQueue.global(qos: .utility).async{
            self.krogerLocations.removeAll()
            let krogerInfo: KrogerAPI = KrogerAPI()
            krogerInfo.getAccessToken()
            var base = "https://www.google.com"
            do{
                try base = self.decryptAES(string: krogerInfo.baseURL)
            }catch{}
            let combined = (base + "/locations?filter.zipCode.near=" + zip + "&filter.department=01").addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            let combinedURL = URL(string : combined)!
            var request = URLRequest(url: combinedURL)
            request.httpMethod = "GET"
            let headers = [
                "Authorization" : "Bearer " + krogerInfo.token!,
                "Cache-Control" : "no-cache"
            ]
            request.allHTTPHeaderFields = headers;
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if error != nil{
                    return
                }
                if let data = data {
                    do{
                        if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]{// Setting the json response from Kroger to jsonArray
                            if ((jsonArray["data"]) == nil) {
                                return
                            }
                            for i in 0..<(jsonArray["data"] as? [Any])!.count {
                                //store the location information as options for the menu
                                self.krogerLocations.append(storeValues(
                                    id: i,
                                    phone: (((jsonArray["data"] as? [Any])![i] as? [String: Any])?["phone"]) as? String,
                                    name: (((jsonArray["data"] as? [Any])![i] as? [String: Any])!["name"]) as! String,
                                    locationId:(((jsonArray["data"] as? [Any])![i] as? [String: Any])!["locationId"]) as! String,
                                    state: ((((jsonArray["data"] as? [Any])![i] as? [String: Any])!["address"]) as? [String: Any])!["state"] as! String,
                                    zipCode: ((((jsonArray["data"] as? [Any])![i] as? [String: Any])!["address"]) as? [String: Any])!["zipCode"] as! String,
                                    address: ((((jsonArray["data"] as? [Any])![i] as? [String: Any])!["address"]) as? [String: Any])!["addressLine1"] as! String
                                ))
                            }
                            view.updateView()
                        }
                    }catch _ as NSError{
                    }
                }
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    return
                }
            }
            URLCache.shared.removeAllCachedResponses()
            task.resume()
        }
    }
}

//view for user to select their location
//user enters a zipcode (or has it filled in with location services)
//and the view displays the 10 closest grocery stores
struct locationView: View {
    @State private var searchval = ""
    var location : findLocation = findLocation()
    @ObservedObject var locationManager = locationServices()
    
    var body: some View {
        HStack(spacing: 15){
            TextField("Enter zipcode", text: $searchval, onCommit: {
                location.getLocation(zip: searchval, view: self)
                //send request to kroger and clear the previous values
                singleLocationView(loc: storeValues()).uncheckBoxes()
                singleLocationView(loc: storeValues()).clearArray()
                singleLocationView.searchVal = searchval
            })
                .autocapitalization(UITextAutocapitalizationType.none)
                .disableAutocorrection(true)
                .onAppear(perform: {
                    searchval = locationServices.zipcode ?? ""
                    if (locationServices.zipcode != nil) {
                        location.getLocation(zip: searchval, view: self)
                        //send request to kroger and clear the previous values
                        singleLocationView(loc: storeValues()).uncheckBoxes()
                        singleLocationView(loc: storeValues()).clearArray()
                        singleLocationView.searchVal = searchval
                    }
                })
            if searchval != "" {
                Button(action: {
                    location.getLocation(zip: searchval, view: self)
                    //send request to kroger and clear the previous values
                    singleLocationView(loc: storeValues()).uncheckBoxes()
                    singleLocationView(loc: storeValues()).clearArray()
                    singleLocationView.searchVal = searchval
                }, label: {
                    Image(systemName: "magnifyingglass")
                        .font(.title)
                        .foregroundColor(.gray)
                })
                .animation(.easeIn)
                
            }
        }
        .padding(.horizontal)
        .padding(.top,10)
        ColorDivider()
        Spacer()
        
        
        if !location.krogerLocations.isEmpty {
            ScrollView(.vertical) {
                ForEach(location.krogerLocations) { loc in
                    singleLocationView(loc: loc)
                    ColorDivider()
                }
            }
        }
    }
    
    //function used to make view update to reflect changes
    func updateView() {
        let val: String = searchval
        searchval += " "
        searchval = val
    }
}


//view that displays a single location's info
struct singleLocationView : View, Equatable {
    var loc : storeValues
    @State var isChecked = false
    static var searchVal = ""
    private static var views: [singleLocationView] = []
    
    var body: some View {
        // singleLocationView.views.append(self)
        ZStack(alignment: Alignment(horizontal: .center, vertical: .top), content: {
                VStack(alignment:.leading) {
                    Text(loc.name)
                        .onDisappear() {
                            clearArray()
                        }
                    Text(loc.address + ", " + loc.state + " " + loc.zipCode)
                    
                    // Formatting the phone number
                    if let num = loc.phone{
                        let start = num.index(num.startIndex, offsetBy:3)
                        let end = num.index(num.endIndex, offsetBy:-4)
                        let range = start..<end
                        let ans: String = "(" + String(num.prefix(3)) + ") " + String(num[range]) + "-" + String(num.suffix(4))
                        Text(ans)
                    }
                    else{
                        Text("unknown")
                    }
                }
                
                // Checkbox button
                HStack{
                    Button (action: {
                        if (!singleLocationView.views.contains(self)) {
                            singleLocationView.views.append(self)
                        }
                        uncheckBoxes()
                        self.isChecked.toggle()
                        KrogerAPI.locationID = loc.locationId
                        locationServices.zipcode = singleLocationView.searchVal
                        #if LEAK_T
                            NSLog("Zipcode: " + locationServices.zipcode!)
                        #endif
                    },
                    label: {
                        if(!isChecked){
                            ZStack{
                                Image(systemName: "plus")
                                    .foregroundColor(.clear)
                                    .background(Color.clear)
                                    .clipShape(Rectangle())
                                    .frame(width: UIScreen.main.bounds.width - 30, height:65)
                                Image(systemName: "circle")
                                    .padding(.leading,UIScreen.main.bounds.width - 30)
                                    .frame(width: UIScreen.main.bounds.width - 30)
                            }
                        }
                        else{
                            ZStack{
                                Image(systemName: "plus")
                                    .foregroundColor(.clear)
                                    .background(Color.clear)
                                    .clipShape(Rectangle())
                                    .frame(width: UIScreen.main.bounds.width - 30, height:65)
                                Image(systemName: "circle.fill")
                                    .padding(.leading,UIScreen.main.bounds.width - 30)
                                    .frame(width: UIScreen.main.bounds.width - 30)
                            }
                        }
                        
                    })
                }
        })
    }
    
    //function used to uncheck the other boxes besides the one checked
    func uncheckBoxes() {
        for box in singleLocationView.views {
            box.isChecked = false
        }
    }
    
    //function used to clear the locations already displayed
    func clearArray() {
        while(singleLocationView.views.count != 0){
            singleLocationView.views.remove(at: 0)
        }
    }
    
    //overide == for locationview
    static func ==(lhs: singleLocationView, rhs: singleLocationView) -> Bool {
        return lhs.loc.locationId == rhs.loc.locationId
    }
    
}

//class used to implement location services
class locationServices : NSObject, ObservableObject, CLLocationManagerDelegate{
    private let locationManager = CLLocationManager()
    static var zipcode : String? = nil
    override init(){
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    }
    
    //function used for location services
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        //if location services is working
        if (location != nil) {
            #if LEAK_T
                let coords = location.coordinate
                NSLog("Latitude is: " + (coords.latitude.description))
                NSLog("Longitude is: " + (coords.longitude.description))
            #endif
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks,error) in
                if error != nil {
                    return
                }
                if (placemarks!.count > 0){
                    let pm = placemarks![0]
                    locationServices.zipcode = pm.postalCode
                }
            })
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    }
}
