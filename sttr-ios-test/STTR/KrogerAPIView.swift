//
//  KrogerAPIView.swift
//  STTR
//
//  Created by Siddharth N. on 3/10/21.
//
import Foundation
import SwiftUI
import Combine

class radioButton : UIButton{
    
}

class checkmarkButton {
    var isChecked: Bool = false
}

class SearchKrogerProducts : ObservableObject {
    let objectWillChange = PassthroughSubject<SearchKrogerProducts, Never>()

    @Published var resultList :[NSDictionary] =  [] {
        willSet {
            print("resultList for Kroger products")
            objectWillChange.send(self)

        }
    }
    
    @Published var KrogerItems: [Kroger] = []
    
   // @Binding var showMenu: Bool
    //@State private var searchval = "milk" // just test value, will be reset
    
    @State private var domainUrlString = "https://api.kroger.com/v1/products?"
    //"https://api.kroger.com/v1/products?filter.term=milk&filter.locationId=00361
    @State var baseURL = "https://api.kroger.com/v1/"
    //@State private var client_id =
     // "grocerycomparison-7d6244ca44a0d50f560f560f1399f7cb796d3023204378126220438";
    //@State private var client_secret = "ozcGTIsR7IRrXHlqxwHX1l01YU2i6u1jsoP4GATD";
    @State private var key = "Z3JvY2VyeWNvbXBhcmlzb24tN2Q2MjQ0Y2E0NGEwZDUwZjU2MGYxMzk5ZjdjYjc5NmQzMDIzMjA0Mzc4MTI2MjIwNDM4Om96Y0dUSXNSN2xSclhIbHF4d0hYMWwwMVlVMmk2dTFqc29QNEdBVEQ="
    //(client_id+":"+client_secret).base64EncodedString(); // first attempt at the creation of the key
    
    
    // theoretical base64 key = Z3JvY2VyeWNvbXBhcmlzb24tN2Q2MjQ0Y2E0NGEwZDUwZjU2MGY1NjBmMTM5OWY3Y2I3OTZkMzAyMzIwNDM3ODEyNjIyMDQzODpvemNHVElzUjdJUnJYSGxxeHdIWDFsMDFZVTJpNnUxanNvUDRHQVRE
    @State private var details = "grant_type=client_credentials&scope=product.compact"
    @EnvironmentObject var session: SessionStore
    var token : String?
    func getProducts(searchval: String, krogerView: KrogerView) {
        DispatchQueue.global(qos: .utility).async{
            self.KrogerItems.removeAll()
            //Request items from Kroger API
            self.getAccessToken()
            print("something")
            let locationID = "01400722"
            // TODO: change location ID
            let Icombined = (self.domainUrlString + "filter.term=" + searchval + "&filter.locationId=" + locationID + "&filter.limit=25").addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            let combinedURL = NSURL(string : Icombined)! as URL
            var Irequest = NSMutableURLRequest(url: combinedURL)
            Irequest.httpMethod = "GET"
            let Iheaders = [
                "Authorization" : "Bearer " + self.token!,
                "Cache-Control" : "no-cache"
            ]
            print(Iheaders)
            Irequest.allHTTPHeaderFields = Iheaders
            let Itask = URLSession.shared.dataTask(with: Irequest as URLRequest , completionHandler: { (data, response, error) in
                  if let error = error {
                    print("Error with fetching films: \(error)")
                    return
                  } else {
    //                  jsonObject = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions())
                  }
                      
                  guard let httpResponse = response as? HTTPURLResponse,
                        (200...299).contains(httpResponse.statusCode) else {
                    print("Error with the response, unexpected status code: \(response)")
                    return
                  }

    //              if let data = data,
    //                let results = try? JSONDecoder().decode(KrogerResults.self, from: data) {
    //                    //completionHandler(recipeResults.results ?? [])
    //                    print(results.results.brand)
    //                    print("here")
    //
    //
    //              }
                if let data = data {
                    //let string_data = String(data: data, encoding: String.Encoding.utf8)
                    //print(string_data)
                    do {
                        //let decoder = JSONDecoder()
                        //let krogerDetails = try decoder.decode(ProductResults.self, from: data)
                        //print(krogerDetails)
                        if let jsonArray = try JSONSerialization.jsonObject(with: data , options: []) as? [String: AnyObject]
                        {
                            //let jsonArray2 = try JSONSerialization.jsonObject(with: jsonArray["data"] , options: []) as? [String: Any]
                            print(jsonArray["data"])
                            
                            //print(jsonArray["data"])
//                            let jsonArray2 = jsonArray["data"]
//                            print(jsonArray2!["productId"])
                            for i in 0..<(jsonArray["data"] as? [Any])!.count {
                                //print((jsonArray["data"] as? [Any])![i])
                                self.KrogerItems.append(Kroger(
                                    id: (((jsonArray["data"] as? [Any])![i] as? [String: Any])!["productId"]) as! String,
                                    upc: (((jsonArray["data"] as? [Any])![i] as? [String: Any])!["upc"]) as! String,
                                    brand: (((jsonArray["data"] as? [Any])![i] as? [String: Any])?["brand"]) as? String,
                                    image: "https://www.kroger.com/product/images/medium/front/" + ((((jsonArray["data"] as? [Any])![i] as? [String: Any])!["productId"]) as! String),
                                    description: (((jsonArray["data"] as? [Any])![i] as? [String: Any])!["description"]) as! String,
                                        price: (String(describing: ((((((((jsonArray["data"] as? [Any])![i] as? [String: Any])!["items"]) as? [Any])![0]) as? [String: Any])?["price"]) as? [String: Any])?["regular"] ?? ""))
                                ))
                                var priceAsFloat = Float(self.KrogerItems[i].price ?? "") ?? 0
                                self.KrogerItems[i].price = String(format: "%.2f", priceAsFloat)
                                print(self.KrogerItems[i])
                                
                                
                                //print(jsonArray)
                                //self.resultList.removeAll()
                            }
                            self.KrogerItems.removeAll { value in
                                return value.price == "0.00"
                            }
                            krogerView.updateView()
//                            for var i in 0..<self.KrogerItems.count {
//                                if(self.KrogerItems[i].price == "0.00"){
//                                    self.KrogerItems.remove(at: i)
//                                    i-=1
//                                }
//                            }
                        }
                        else {
                            print("bad json")
                        }
                    } catch let error as NSError {
                        print(error)
                    }
                    
                }
                })
                Itask.resume()
        }
    }
    
    func getAccessToken(){
        let combined = baseURL + "connect/oauth2/token?" + details
        let url = URL(string :combined)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let Auth = "Basic " + key
        let headers = [
            "Authorization" : Auth,
            "Content-Type" : "application/x-www-form-urlencoded"
        ]
        //request.setValue("Authorization", forHTTPHeaderField: "Basic " + key)
        //request.setValue("Content-Type", forHTTPHeaderField: "application/x-www-form-urlencoded")
        request.allHTTPHeaderFields = headers
        //request.addValue(key, forHTTPHeaderField: "Authorization")
        
        print("Starting first task")
        let semaphore = DispatchSemaphore(value: 0)
        let task = URLSession.shared.dataTask(with: request , completionHandler: { (data, response, error) in
              
              if let error = error {
                print("Error with fetching films: \(error)")
                return
              } else {
//                  jsonObject = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions())
//                  print(jsonObject)
                  //print(data)
                
                  //print(combined)
                  //print(data)
                  //print(response)
                  //print(task)
              }
                  
              guard let httpResponse = response as? HTTPURLResponse,
                    (200...299).contains(httpResponse.statusCode) else {
                print("Error with the response, unexpected status code: \(response)")
                return
              }

//              if let data = data,
//                let results = try? JSONDecoder().decode(KrogerResults.self, from: data) {
//                    //completionHandler(recipeResults.results ?? [])
//                    print(results.results.brand)
//                    print("here")
//
//
//              }
            if let data = data {
                //let string_data = String(data: data, encoding: String.Encoding.utf8)
                //print(string_data)
                do {
                    print("Inside first task")
                    if let jsonArray = try JSONSerialization.jsonObject(with: data , options: []) as? [String: Any]
                    {
                        print(jsonArray)
                        self.token = jsonArray["access_token"] as! String?
                    }
                    else {
                        print("bad json")
                    }
                    
                    
                } catch let error as NSError {
                    print(error)
                }
                
            }
            semaphore.signal()
            print("here2")
            })
            task.resume()
        _ = semaphore.wait(wallTimeout: .distantFuture)
    }
}

struct KrogerView: View {
    @EnvironmentObject var kroger: SearchKrogerProducts
    @State var searchval: String
    @State var cartItem: Cart
    @State var update: String = "update"
    var body: some View {
//        HStack(spacing: 15){
//            TextField("Search product", text: $searchval)
//                .autocapitalization(UITextAutocapitalizationType.none)
//
//            if searchval != "" {
//                Button(action: { kroger.getProducts(searchval: searchval, krogerView: self)}, label: {
//                    Image(systemName: "magnifyingglass")
//                        .font(.title)
//                        .foregroundColor(.gray)
//                })
//                .animation(.easeIn).onAppear(perform: {
//                    kroger.getProducts(searchval: searchval, krogerView: self)
//                    update+=" "
//                })
//            }
//        }
//        .padding(.horizontal)
//        .padding(.top,10)
//
//        Divider()
//        Spacer()
        
//        ForEach(kroger.resultList, id: \.self) {r in
//
//
//            Text(r.value(forKey: "title") as? String ?? "test")
//                .font(.body)
//                .fontWeight(.medium)
//                .foregroundColor(.black)
//                // .lineLimit(2)
            ScrollView{

                        // Displaying the searched items
            ForEach(kroger.KrogerItems) {item in
                KrogerItemView(item: item, kroger: self).onAppear(perform: {
                    update+=" "
                })
//                            ZStack(alignment: Alignment(horizontal: .center, vertical: .top), content: {
//
//                                VStack{
//                                    KrogerImageView(withURL: item.image ?? "")
//                                    //ImageView(withURL: r.value(forKey: "image") as? String ?? "test")
//                                        .frame(width: UIScreen.main.bounds.width - 30, height: 250)
//                                    HStack{
//                                            // .lineLimit(2)
//                                        Text("$" + (item.price ?? "")).font(.body)
//                                            .fontWeight(.medium)
//                                            .foregroundColor(.black)
//                                            .padding(.trailing,15)
//
//                                    }
//                                    HStack{
//                                        let detail: String = item.description ?? ""
//                                        Text(detail.withoutHTMLTags)
//                                            .font(.body)
//                                            .foregroundColor(.black)
//                                            .lineLimit(2)
//                                            .frame(width: UIScreen.main.bounds.width - 30)
//
//                                        Spacer(minLength: 0)
//                                    }
//                                }
//
//                                NavigationLink(destination: CartView()) {
//                                    Image(systemName: "plus")
//                                        .foregroundColor(.clear)
//                                        //.padding(10)
//                                        .background(Color.clear)
//                                        .clipShape(Rectangle())
//                                        .frame(width: UIScreen.main.bounds.width - 30, height:250)
//
//                                }.isDetailLink(false).simultaneousGesture(TapGesture().onEnded{
//                                        cartItem.krogerReplace = item
//                                })
//
//                                Button (action: {
//                                    uncheckBoxes()
//                                    self.isChecked.toggle()
//                                    cartItem.krogerReplace = item
//                                },
//                                label: {
//                                    if(!isChecked){
//                                        Image(systemName: "square")
//                                    }
//                                    else{
//                                        Image(systemName: "checkmark.square")
//                                    }
//
//                                })
//
//
//                            })
//                            .frame(width: UIScreen.main.bounds.width - 30).onAppear(perform: {
//                                update+=" "
//                            })
//
//
//                            Divider()
//                        }
                        Spacer()
                    }
                }.navigationBarTitle(Text("Select an Ingredient"),displayMode: .inline)

              //  }

        Text("\(update)").font(.system(size:1)).foregroundColor(.white).onAppear(perform: {
            kroger.getProducts(searchval: cartItem.item.ingredientName ?? "", krogerView: self)
                                update+=" "
                            })
            
    }
    
   func updateView(){
        update+=" "
    }
}


struct KrogerItemView : View {
    var item: Kroger
    @State var isChecked = false
    @State var kroger: KrogerView
    private static var views: [KrogerItemView] = []
    var body: some View{
        ZStack(alignment: Alignment(horizontal: .center, vertical: .top), content: {

            VStack{
                KrogerImageView(withURL: item.image ?? "")
                //ImageView(withURL: r.value(forKey: "image") as? String ?? "test")
                    .frame(width: UIScreen.main.bounds.width - 30, height: 250)
                    .onAppear() {
                        KrogerItemView.views.append(self)
                        print(KrogerItemView.views.count)
                    }
                    .onDisappear() {
                        clearArray()
                        print("DISAPPEARING")
                    }
                HStack{
                        // .lineLimit(2)
                    Text("$" + (item.price ?? "")).font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                        .padding(.trailing,15)
                        
                }
                HStack{
                    let detail: String = item.description ?? ""
                    Text(detail.withoutHTMLTags)
                        .font(.body)
                        .foregroundColor(.black)
                        .lineLimit(2)
                        .frame(width: UIScreen.main.bounds.width - 30)

                    Spacer(minLength: 0)
                }
            }
            
//            Image(systemName: item.isAdded ? "checkmark" : "plus")
//                .foregroundColor(.clear)
//                //.padding(10)
//                .background(item.isAdded ? Color.green : Color.clear)
//                .clipShape(Rectangle())
//                .frame(width: UIScreen.main.bounds.width - 30, height:300)
//
            HStack{
                Button (action: {
                    uncheckBoxes()
                    self.isChecked.toggle()
                    kroger.cartItem.krogerReplace = item
                },
                label: {
                    Spacer(minLength: 0)
                    if(!isChecked){
                        Image(systemName: "square").padding(.leading,UIScreen.main.bounds.width - 30).frame(width: UIScreen.main.bounds.width - 30)
                    }
                    else{
                        Image(systemName: "checkmark.square").padding(.leading,UIScreen.main.bounds.width - 30).frame(width: UIScreen.main.bounds.width - 30)
                    }
                    
                })
            }

        })
        .frame(width: UIScreen.main.bounds.width - 30)

        
        Divider()
    }
    
    private func uncheckBoxes() {
        for box in KrogerItemView.views {
            box.isChecked = false
        }
    }
    
    func clearArray() {
//        while(singleLocationView.views.count != 0){
//            print("delete")
//            singleLocationView.views.remove(at: 0)
//        }
        KrogerItemView.views.removeAll()
    }
}


