//
//  LocationView.swift
//  STTR
//
//  Created by Joshua Johnson on 5/21/21.
//

import Foundation
import SwiftUI


struct storeValues : Identifiable {
    var id : Int = -1
    var phone : String? = nil
    var name : String = ""
    var locationId : String = ""
    var state : String = ""
    var zipCode : String = ""
    var address : String = ""
}

class findLocation : ObservableObject {
    @Published var krogerLocations: [storeValues] = []
    
    
    func getLocation(zip: String, view: locationView){
        
        DispatchQueue.global(qos: .utility).async{
            self.krogerLocations.removeAll()
            let krogerInfo: SearchKrogerProducts = SearchKrogerProducts()
            krogerInfo.getAccessToken()
            let combined = krogerInfo.baseURL + "locations?filter.zipCode.near=" + zip + "&filter.department=01" //+ "&filter.chain=KROGER" //+ "&filter.radiusInMiles=10"
            // print(combined)
            let combinedURL = URL(string : combined)!
            var request = URLRequest(url: combinedURL)
            request.httpMethod = "GET"
            let headers = [
                "Authorization" : "Bearer " + krogerInfo.token!,
                "Cache-Control" : "no-cache"
            ]
            request.allHTTPHeaderFields = headers;
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("Error: \(error)")
                    return
                }
                if let data = data {
                    do{
                        // Setting the json response from Kroger to jsonArray
                        if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]{
                            if ((jsonArray["data"]) == nil) {
                                // do things
                                return
                            }
                            for i in 0..<(jsonArray["data"] as? [Any])!.count {
                                //if ((((jsonArray["data"] as! [Any])[i] as! [String: Any])["chain"]) as! String == "KROGER") {
                                    self.krogerLocations.append(storeValues(
                                        id: i,
                                        phone: (((jsonArray["data"] as? [Any])![i] as? [String: Any])?["phone"]) as? String,
                                        name: (((jsonArray["data"] as? [Any])![i] as? [String: Any])!["name"]) as! String,
                                        locationId:(((jsonArray["data"] as? [Any])![i] as? [String: Any])!["locationId"]) as! String,
                                        state: ((((jsonArray["data"] as? [Any])![i] as? [String: Any])!["address"]) as? [String: Any])!["state"] as! String,
                                        zipCode: ((((jsonArray["data"] as? [Any])![i] as? [String: Any])!["address"]) as? [String: Any])!["zipCode"] as! String,
                                        address: ((((jsonArray["data"] as? [Any])![i] as? [String: Any])!["address"]) as? [String: Any])!["addressLine1"] as! String
                                    ))
                                //}
                            }
                            // print(jsonArray)
                            // print(self.krogerLocations)
                            view.updateView()
                        } else {
                            print("bad json")
                        }
                    }catch let error as NSError{
                        print(error)
                    }
                    }
                }
            task.resume()
                
            }
    }
}
        

        
struct locationView: View {
    @State private var searchval = ""
    var location : findLocation = findLocation()
    // @State var isChecked: Bool = true
    var body: some View {
        HStack(spacing: 15){
            TextField("Enter zipcode", text: $searchval, onCommit: {
                location.getLocation(zip: searchval, view: self)
                singleLocationView(loc: storeValues()).uncheckBoxes()
                singleLocationView(loc: storeValues()).clearArray()
            })
                .autocapitalization(UITextAutocapitalizationType.none)
            
            if searchval != "" {
                Button(action: {
                        location.getLocation(zip: searchval, view: self)
                        singleLocationView(loc: storeValues()).uncheckBoxes()
                        singleLocationView(loc: storeValues()).clearArray()
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
        Divider()
        Spacer()
        
        
        ScrollView{
            VStack{
                ForEach(location.krogerLocations) {loc in
                    singleLocationView(loc: loc)
                    Divider()
                }
            }
            
            
        }
        
    
    }
    
    func updateView() {
        let val: String = searchval
        searchval += " "
        searchval = val
    }
}

struct singleLocationView : View, Equatable {
    var loc : storeValues
    @State var isChecked = false
    private static var views: [singleLocationView] = []
    var body: some View {
        // singleLocationView.views.append(self)
        HStack{
            VStack(alignment:.leading) {
                Text(loc.name)
                    .onDisappear() {
                        clearArray()
                    }
                Text(loc.address + ", " + loc.state + " " + loc.zipCode)
        
                // Formatting the phone number
                if let num = loc.phone{
                    //num.insert("(", at:0)
                    let start = num.index(num.startIndex, offsetBy:3)
                    let end = num.index(num.endIndex, offsetBy:-4)
                    let range = start..<end
                    let ans: String = "(" + String(num.prefix(3)) + ") " + String(num[range]) + "-" + String(num.suffix(4))
                    Text(ans)
                }
                else{
                    Text("unknown")
                }
                // Text(num)
            }
            
            // Checkbox button
            Button (action: {
                if (!singleLocationView.views.contains(self)) {
                    singleLocationView.views.append(self)
                }
                uncheckBoxes()
                self.isChecked.toggle()
                
            },
            label: {
                if(!isChecked){
                    Image(systemName: "square")
                }
                else{
                    Image(systemName: "checkmark.square")
                }
                
            })
                
        }
    }
    
    func uncheckBoxes() {
        for box in singleLocationView.views {
            box.isChecked = false
            print(box.loc.name)
        }
        print()
    }
    
    func clearArray() {
        while(singleLocationView.views.count != 0){
            print("delete")
            singleLocationView.views.remove(at: 0)
        }
    }
    
    static func ==(lhs: singleLocationView, rhs: singleLocationView) -> Bool {
        return lhs.loc.locationId == rhs.loc.locationId
    }
}
