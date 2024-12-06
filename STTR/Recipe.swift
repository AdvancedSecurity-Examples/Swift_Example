//
//  recipeStore.swift
//  STTR
//
//  Created by elizabeth on 2/25/21.
//

import UIKit
import Combine
import Foundation

//class used to get and store information about recipes
class RecipeStore : ObservableObject{
    let objectWillChange = PassthroughSubject<RecipeStore, Never>()
    
    @Published var cartItems: [Cart] = []
    {
        didSet {
            objectWillChange.send(self)
        }
    }
    
    @Published var items: [Item] = []
    {
        didSet {
            objectWillChange.send(self)
        }
    }
    
    @Published var resultList :[NSDictionary] =  [] {
        willSet {
            //print("I swear I'm addicted to blue cheese")
            objectWillChange.send(self)
        }
    }
    
    @Published var countRecipeAPIrequests = 0
    
    var shouldRedirectToUpdateView = false {
        willSet {
            objectWillChange.send(self)
        }
    }
    
    //func that makes a call to spoonacular and stores the response
    //returned for the searchval
    func searchRecipes(searchval: String){
        let domainURLString = "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/complexSearch?query="
        let parameters = "&addRecipeInformation=true&offset=\(countRecipeAPIrequests)&number=10"
        let combined = (domainURLString + searchval + parameters).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        #if SECURE
            let rapidapi_key_url = "https://sttr.martincarlisle.com/youwontguessthisbhVFFX/rapid_api_header"
        #else
            let rapidapi_key_url = "http://sttr.martincarlisle.com/youwontguessthisbhVFFX/rapid_api_header"
        #endif
        let urlsession = urlSesssion()
        var rapidapi_key: String = ""
        DispatchQueue.global(qos: .utility).async{
            #if SECURE
                rapidapi_key = urlsession.getData(from: rapidapi_key_url)
                //print("SECURE")
            #else
                rapidapi_key = "dcfe9a59bamsh62b7564bd8625adp1c859ajsnf2a3df45d987"
                //print("UNSECURE")
            #endif
            
            let headers = [
                "x-rapidapi-key": rapidapi_key,
                "x-rapidapi-host": "spoonacular-recipe-food-nutrition-v1.p.rapidapi.com",
                "useQueryString": "true"
            ]
            let request = NSMutableURLRequest(url: NSURL(string: combined)! as URL,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 10.0)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = headers
            
            let task = URLSession.shared.dataTask(with: request as URLRequest , completionHandler: { (data, response, error) in
                if let error = error {
                    //print("Error with fetching films: \(error)")
                    return
                } else {
                    
                    if let data = data {
                        do {
                            let decoder = JSONDecoder()
                            let recipeDetails = try decoder.decode(RecipeResults.self, from: data)
                            _ = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]// testing purposes, remove after
                            DispatchQueue.main.async{
                              
                            
                                for i in 0..<recipeDetails.results.count {// Adding the search results to the item list
                                    self.items.append(Item(id: recipeDetails.results[i].id ?? 0,
                                                           item_name: recipeDetails.results[i].title ?? "",
                                                           item_details: recipeDetails.results[i].summary ?? "",
                                                           item_image: recipeDetails.results[i].image ?? "",
                                                           ingredients: nil,
                                                           preparationMinutes: recipeDetails.results[i].readyInMinutes ?? 0,
                                                           servings: recipeDetails.results[i].servings ?? 0,
                                                           dairyFree: recipeDetails.results[i].dairyFree ?? false,
                                                           glutenFree: recipeDetails.results[i].glutenFree ?? false,
                                                           vegan: recipeDetails.results[i].vegan ?? false,
                                                           vegetarian: recipeDetails.results[i].vegetarian ?? false ))
                                    self.getIngredients(recipeID: recipeDetails.results[i].id ?? 0, itemIndex: self.getIndexItem(item: self.items[self.items.count - 1]))
                                    self.countRecipeAPIrequests += 10
                                }
                            }
                        } catch _ as NSError {
                        }
                        
                    }
                }
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    return
                }
            })
            task.resume()
        }
    }
    
    //function that gets the ingredients associated with a specific recipe
    //using the spoonacular API
    func getIngredients(recipeID: Int, itemIndex: Int) {
        let domainURLString = "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/"
        let stringID = String(recipeID)
        let dataType = "/ingredientWidget.json"
        
        let combined = domainURLString + stringID + dataType
        
        #if SECURE
            let rapidapi_key_url = "https://sttr.martincarlisle.com/youwontguessthisbhVFFX/rapid_api_header"
        #else
            let rapidapi_key_url = "http://sttr.martincarlisle.com/youwontguessthisbhVFFX/rapid_api_header"
        #endif
        
        DispatchQueue.global(qos: .utility).async{
            #if SECURE
                let rapidapi_key: String = urlSesssion().getData(from: rapidapi_key_url)
                //print("SECURE")
            #else
                let rapidapi_key: String = "dcfe9a59bamsh62b7564bd8625adp1c859ajsnf2a3df45d987"
                //print("UNSECURE")
            #endif
            //need instance of urlSession bc getData is not static
            //
            let headers = [
                "x-rapidapi-key": rapidapi_key,
                "x-rapidapi-host": "spoonacular-recipe-food-nutrition-v1.p.rapidapi.com",
                "useQueryString": "true"
            ]
            let request = NSMutableURLRequest(url: NSURL(string: combined)! as URL,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 10.0)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = headers
            let task = URLSession.shared.dataTask(with: request as URLRequest , completionHandler: { (data, response, error) in
                if let error = error {
                    //print("Error with fetching films: \(error)")
                    return
                }
                else {
                    if let data = data {
                        do {
                            let decoder = JSONDecoder()
                            let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                            let recipeIngredients = try decoder.decode(RecipeIngredients.self, from: data)
                            
                            var ingredientList = [IngredientsIdentifiable]()
                            var num = 0
                            for ingredient in recipeIngredients.ingredients {
                                ingredientList.append(IngredientsIdentifiable(id: num, ingredientName: ingredient.name ?? "", ingredientImageURL: ingredient.image ?? "", amount: ingredient.amount.metric.value ?? 0, unit: ingredient.amount.metric.unit ?? ""))
                                num = num + 1
                            }
                            DispatchQueue.main.async {
                                self.items[itemIndex].ingredients = ingredientList
                            }
                        }
                        catch let error as NSError {
                            //print("getIngredients error")
                            //print("item index: ",itemIndex)
                            //print("recipeID:",recipeID)
                            //print(error)
                        }
                    }
                }
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    //print("Error with the response, unexpected status code: \(String(describing: response))")
                    return
                }
            })
            task.resume()
        }
    }
    
    //function used to add an ingredient to the app's cart
    //also removes the item from the cart if it is already in the cart
    func addToCart(ingredient: IngredientsIdentifiable, recipeItem: Item ){
        let index = getIndexItem(item: recipeItem)// "add to cart" button pressed again after item already added
        if (!(self.items[index].ingredients?[getIndexIngredient(ingredient: ingredient, itemIndex: index)].isAdded)!){
            self.cartItems.append(Cart(item: ingredient, quantity: 1, recipe: recipeItem))
        }
        else{
            self.cartItems.remove(at: getIndexCart(cartItem: ingredient))// remove from cart
        }
        
        self.items[index].ingredients?[getIndexIngredient(ingredient: ingredient, itemIndex: index)].isAdded = !((self.items[index].ingredients?[getIndexIngredient(ingredient: ingredient, itemIndex: index)].isAdded)!)
    }
    
    //function that returns the index of an item in the Item array
    func getIndexItem(item: Item) -> Int {
        let index = self.items.firstIndex { (item1) -> Bool in
            return item.id == item1.id
        } ?? 0
        return index
    }
    
    //function that returns the index of an ingredient in the Ingredients array
    func getIndexIngredient(ingredient: IngredientsIdentifiable, itemIndex: Int) -> Int {
        let index = self.items[itemIndex].ingredients?.firstIndex { (item1) -> Bool in
            return ingredient.id == item1.id
        } ?? 0
        return index
    }
    
    //function that returns the index of an item in the cart
    func getIndexCart(cartItem: IngredientsIdentifiable) -> Int {
        let index = self.cartItems.firstIndex { (item1) -> Bool in
            return cartItem.id == item1.item.id
        } ?? 0
        return index
    }
}
