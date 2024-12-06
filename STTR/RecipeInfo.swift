//
//  recipeStore.swift
//  STTR
//
//  Created by elizabeth on 2/25/21.
//

import UIKit
import Combine
import Foundation
import CryptoSwift

//class used to get and store information about recipes
class RecipeInfo : ObservableObject{
    let objectWillChange = PassthroughSubject<RecipeInfo, Never>()
    
    //stores items in the cart
    @Published var cartItems: [CartItem] = []
    {
        didSet {
            objectWillChange.send(self)
        }
    }
    
    //stores recipes to show in RecipeView
    @Published var items: [RecipeItem] = []
    {
        didSet {
            objectWillChange.send(self)
        }
    }
    
    //variable used for infinite scrolling on RecipeView
    @Published var countRecipeAPIrequests = 0
    
    var shouldRedirectToUpdateView = false {
        willSet {
            objectWillChange.send(self)
        }
    }
    
    //function used to decrypt encrypted strings
    func decryptAES(string: String) throws -> String{
        let aes = try AES(key: [206, 131, 29, 10, 221, 211, 60, 236, 57, 131, 76, 101, 238, 39, 200, 177], blockMode: CBC(iv: [206, 131, 29, 10, 221, 211, 60, 236, 57, 131, 76, 101, 238, 39, 200, 177]))
        let decrypt = try string.decryptBase64ToString(cipher: aes)
        return decrypt
    }
    
    //func that makes a call to spoonacular and stores the response
    //returned for the searchval
    func searchRecipes(searchval: String){
        var domainURLString = ""
        do{
            try domainURLString = decryptAES(string: "+/rPO0Wiw60aGp1RKwU1zdZhTObfx0PSjTeQqK32mqwNdqJd7j5Jeyvqw+DfwTFwrVBB1guiokcgW/lrav2lQl+NdU9mLtpFR13ZI180fprs+hqJ1tKXDsH8yjEeMQx6")
        }catch{}
        let parameters = "&addRecipeInformation=true&offset=\(countRecipeAPIrequests)&number=10"
        let combined = (domainURLString + searchval + parameters).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        var rapidapi_key_url = ""
        #if HTTP_F
            do{
                try rapidapi_key_url = decryptAES(string: "5eu+q4ykxQv4VoqKDniVjGU5oBSOJIgwJtoyFKqvFioXJVnIJOtXaiyxejgyN+dIPlxaWBTVoJArQ6k6rveU/DRN1nSkJJrCsyOb9c4AmAY=")
            } catch {}
        #else
            rapidapi_key_url = "http://sttr.martincarlisle.com/youwontguessthisbhVFFX/rapid_api_header"
        #endif
        let urlsession = urlSesssion()
        var rapidapi_key: String = ""
        DispatchQueue.global(qos: .utility).async{
            #if EMBED_F
                rapidapi_key = urlsession.getData(from: rapidapi_key_url)
            #else
                rapidapi_key = /*"dcfe9a59bamsh62b7564bd8625adp1c859ajsnf2a3df45d987"*/"8aee341878564ebb9b021f49c8abf4e0"
            #endif
            if(rapidapi_key.count == 50){ //check the length of the key to check whether we're doing the free or paid spoonacular call
                let headers = [
                    "x-rapidapi-key": rapidapi_key,
                    "x-rapidapi-host": "spoonacular-recipe-food-nutrition-v1.p.rapidapi.com"
                ]
                let request = NSMutableURLRequest(url: NSURL(string: combined)! as URL,
                                                  cachePolicy: .reloadIgnoringLocalCacheData,
                                                  timeoutInterval: 10.0)
                request.httpMethod = "GET"
                request.allHTTPHeaderFields = headers
                
                let task = URLSession.shared.dataTask(with: request as URLRequest , completionHandler: { (data, response, error) in
                    if let error = error {
                        return
                    } else {
                        
                        if let data = data {
                            
                            do {
                                let jsonArray = try JSONSerialization.jsonObject(with: data , options: []) as? [String: AnyObject]
                                let decoder = JSONDecoder()
                                let recipeDetails = try decoder.decode(RecipeResults.self, from: data)
                                _ = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]// testing purposes, remove after
                                DispatchQueue.main.async{
                                  
                                
                                    for i in 0..<recipeDetails.results.count {// Adding the search results to the item list
                                        self.items.append(RecipeItem(id: recipeDetails.results[i].id ?? 0,
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
                URLCache.shared.removeAllCachedResponses()
                task.resume()
            } else if (rapidapi_key.count == 32){ //if the key length is 32 we use the free version
                domainURLString = "https://api.spoonacular.com/recipes/complexSearch?query="
                let parameters = "&addRecipeInformation=true&offset=\(self.countRecipeAPIrequests)&number=10&apiKey="
                let combined = (domainURLString + searchval + parameters+rapidapi_key).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                let request = NSMutableURLRequest(url: NSURL(string: combined)! as URL,
                                                  cachePolicy: .reloadIgnoringLocalCacheData,
                                                  timeoutInterval: 10.0)
                let headers = [
                    "Content-Type": "application/json"
                ]
                request.httpMethod = "GET"
                request.allHTTPHeaderFields = headers
                let task = URLSession.shared.dataTask(with: request as URLRequest , completionHandler: { (data, response, error) in
                    if let  _ = error {
                        return
                    } else {
                        
                        if let data = data {
                            
                            do {
                                let decoder = JSONDecoder()
                                let recipeDetails = try decoder.decode(RecipeResults.self, from: data)
                                DispatchQueue.main.async{
                                  
                                
                                    for i in 0..<recipeDetails.results.count {// Adding the search results to the item list
                                        self.items.append(RecipeItem(id: recipeDetails.results[i].id ?? 0,
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
                URLCache.shared.removeAllCachedResponses()
                task.resume()
            }
        }
    }
    
    
    //function used to get 10 random recipes and put them on the RecipeView when no search is performed
    func getRandomRecipes(){
        var domainURLString = ""
        do{
            try domainURLString = decryptAES(string: "+/rPO0Wiw60aGp1RKwU1zdZhTObfx0PSjTeQqK32mqwNdqJd7j5Jeyvqw+DfwTFwrVBB1guiokcgW/lrav2lQoeisXp+ViVP1mIcK27naW8=")
        }catch{}
        var rapidapi_key_url = ""
        #if HTTP_F
            do{
                try rapidapi_key_url = decryptAES(string: "5eu+q4ykxQv4VoqKDniVjGU5oBSOJIgwJtoyFKqvFioXJVnIJOtXaiyxejgyN+dIPlxaWBTVoJArQ6k6rveU/DRN1nSkJJrCsyOb9c4AmAY=")
            } catch {}
        #else
            rapidapi_key_url = "http://sttr.martincarlisle.com/youwontguessthisbhVFFX/rapid_api_header"
        #endif
        let urlsession = urlSesssion()
        var rapidapi_key: String = ""
        DispatchQueue.global(qos: .utility).async{
            #if EMBED_F
                rapidapi_key = urlsession.getData(from: rapidapi_key_url)
            #else
                rapidapi_key = "8aee341878564ebb9b021f49c8abf4e0"
            #endif
            if(rapidapi_key.count == 50){ // check to see the length of the key, if 50 use paid version
                let headers = [
                    "x-rapidapi-key": rapidapi_key,
                    "x-rapidapi-host": "spoonacular-recipe-food-nutrition-v1.p.rapidapi.com",
                    "useQueryString": "true"
                ]
                let request = NSMutableURLRequest(url: NSURL(string: domainURLString)! as URL,
                                                  cachePolicy: .reloadIgnoringLocalCacheData,
                                                  timeoutInterval: 10.0)
                request.httpMethod = "GET"
                request.allHTTPHeaderFields = headers
                
                let task = URLSession.shared.dataTask(with: request as URLRequest , completionHandler: { (data, response, error) in
                    if let _ = error {
                        return
                    } else {
                        
                        if let data = data {
                            do {
                                let decoder = JSONDecoder()
                                let recipeDetails = try decoder.decode(RandomRecipeResults.self, from: data)
                                DispatchQueue.main.async{
                                
                                    for i in 0..<recipeDetails.recipes.count {// Adding the search results to the item list
                                        self.items.append(RecipeItem(id: recipeDetails.recipes[i].id ?? 0,
                                                               item_name: recipeDetails.recipes[i].title ?? "",
                                                               item_details: recipeDetails.recipes[i].summary ?? "",
                                                               item_image: recipeDetails.recipes[i].image ?? "",
                                                               ingredients: nil,
                                                               preparationMinutes: recipeDetails.recipes[i].readyInMinutes ?? 0,
                                                               servings: recipeDetails.recipes[i].servings ?? 0,
                                                               dairyFree: recipeDetails.recipes[i].dairyFree ?? false,
                                                               glutenFree: recipeDetails.recipes[i].glutenFree ?? false,
                                                               vegan: recipeDetails.recipes[i].vegan ?? false,
                                                               vegetarian: recipeDetails.recipes[i].vegetarian ?? false ))
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
                URLCache.shared.removeAllCachedResponses()
                task.resume()
            } else if(rapidapi_key.count == 32){ //if the length of the key is 32 we use the free version
                domainURLString = "https://api.spoonacular.com/recipes/random?apiKey=" + rapidapi_key + "&number=2"
                let request = NSMutableURLRequest(url: NSURL(string: domainURLString)! as URL,
                                                  cachePolicy: .reloadIgnoringLocalCacheData,
                                                  timeoutInterval: 10.0)
                request.httpMethod = "GET"
                
                let task = URLSession.shared.dataTask(with: request as URLRequest , completionHandler: { (data, response, error) in
                    if let _ = error {
                        return
                    } else {
                        
                        if let data = data {
                            do {
                                let decoder = JSONDecoder()
                                let recipeDetails = try decoder.decode(RandomRecipeResults.self, from: data)
                                DispatchQueue.main.async{
                                
                                    for i in 0..<recipeDetails.recipes.count {// Adding the search results to the item list
                                        self.items.append(RecipeItem(id: recipeDetails.recipes[i].id ?? 0,
                                                               item_name: recipeDetails.recipes[i].title ?? "",
                                                               item_details: recipeDetails.recipes[i].summary ?? "",
                                                               item_image: recipeDetails.recipes[i].image ?? "",
                                                               ingredients: nil,
                                                               preparationMinutes: recipeDetails.recipes[i].readyInMinutes ?? 0,
                                                               servings: recipeDetails.recipes[i].servings ?? 0,
                                                               dairyFree: recipeDetails.recipes[i].dairyFree ?? false,
                                                               glutenFree: recipeDetails.recipes[i].glutenFree ?? false,
                                                               vegan: recipeDetails.recipes[i].vegan ?? false,
                                                               vegetarian: recipeDetails.recipes[i].vegetarian ?? false ))
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
                URLCache.shared.removeAllCachedResponses()
                task.resume()
            }
        }
    }
    
    //function that gets the ingredients associated with a specific recipe
    //using the spoonacular API
    func getIngredients(recipeID: Int, itemIndex: Int, group: DispatchGroup) {
        let semaphore = DispatchSemaphore(value: 0)
        var domainURLString = ""
        do{
            try domainURLString = decryptAES(string: "+/rPO0Wiw60aGp1RKwU1zdZhTObfx0PSjTeQqK32mqwNdqJd7j5Jeyvqw+DfwTFwrVBB1guiokcgW/lrav2lQusAl+5urcD4Tsvu+wcwjFY=")
        }catch{}
        let stringID = String(recipeID)
        let dataType = "/ingredientWidget.json"
        
        var combined = domainURLString + stringID + dataType
        var rapidapi_key_url = ""
        #if HTTP_F
        do{
            try rapidapi_key_url = decryptAES(string: "5eu+q4ykxQv4VoqKDniVjGU5oBSOJIgwJtoyFKqvFioXJVnIJOtXaiyxejgyN+dIPlxaWBTVoJArQ6k6rveU/DRN1nSkJJrCsyOb9c4AmAY=")
        } catch{}
        #else
            rapidapi_key_url = "http://sttr.martincarlisle.com/youwontguessthisbhVFFX/rapid_api_header"
        #endif
        
        DispatchQueue.global(qos: .utility).async{
            #if EMBED_F
                let rapidapi_key: String = urlSesssion().getData(from: rapidapi_key_url)
            #else
                let rapidapi_key: String = "dcfe9a59bamsh62b7564bd8625adp1c859ajsnf2a3df45d987"
            #endif
            if(rapidapi_key.count == 50){ // check to see the length of the key, if 50 use paid version
                let headers = [
                    "x-rapidapi-key": rapidapi_key,
                    "x-rapidapi-host": "spoonacular-recipe-food-nutrition-v1.p.rapidapi.com",
                    "useQueryString": "true"
                ]
                let request = NSMutableURLRequest(url: NSURL(string: combined)! as URL,
                                                  cachePolicy: .reloadIgnoringLocalCacheData,
                                                  timeoutInterval: 10.0)
                request.httpMethod = "GET"
                request.allHTTPHeaderFields = headers
                let task = URLSession.shared.dataTask(with: request as URLRequest , completionHandler: { (data, response, error) in
                    if let _ = error {
                        return
                    }
                    else {
                        if let data = data {
                            do {
                                let decoder = JSONDecoder()
                                let recipeIngredients = try decoder.decode(RecipeIngredients.self, from: data)
                                
                                var ingredientList = [IngredientsIdentifiable]()
                                var num = 0
                                for ingredient in recipeIngredients.ingredients {
                                    ingredientList.append(IngredientsIdentifiable(id: num, ingredientName: ingredient.name ?? "", ingredientImageURL: ingredient.image ?? "", amount: ingredient.amount.metric.value ?? 0, unit: ingredient.amount.metric.unit ?? ""))
                                    num = num + 1
                                }
                                DispatchQueue.main.async {
                                    self.items[itemIndex].ingredients = ingredientList
                                    semaphore.signal()
                                    group.leave()
                                }
                                
                            }
                            catch _ as NSError {
                            }
                        }
                    }
                    guard let httpResponse = response as? HTTPURLResponse,
                          (200...299).contains(httpResponse.statusCode) else {
                        return
                    }
                })
                URLCache.shared.removeAllCachedResponses()
                task.resume()
                _ = semaphore.wait(timeout: .distantFuture)
            } else if(rapidapi_key.count == 32){ //if the key length is 32 use the free version
                combined = "https://api.spoonacular.com/recipes/" + stringID + dataType + "?apiKey=" + rapidapi_key
                let headers = [
                    "Content-Type" : "application/json"
                ]
                let request = NSMutableURLRequest(url: NSURL(string: combined)! as URL,
                                                  cachePolicy: .reloadIgnoringLocalCacheData,
                                                  timeoutInterval: 10.0)
                request.httpMethod = "GET"
                request.allHTTPHeaderFields = headers
                let task = URLSession.shared.dataTask(with: request as URLRequest , completionHandler: { (data, response, error) in
                    if let  _ = error {
                        return
                    }
                    else {
                        if let data = data {
                            do {
                                let decoder = JSONDecoder()
                                let recipeIngredients = try decoder.decode(RecipeIngredients.self, from: data)
                                
                                var ingredientList = [IngredientsIdentifiable]()
                                var num = 0
                                for ingredient in recipeIngredients.ingredients {
                                    ingredientList.append(IngredientsIdentifiable(id: num, ingredientName: ingredient.name ?? "", ingredientImageURL: ingredient.image ?? "", amount: ingredient.amount.metric.value ?? 0, unit: ingredient.amount.metric.unit ?? ""))
                                    num = num + 1
                                }
                                DispatchQueue.main.async {
                                    self.items[itemIndex].ingredients = ingredientList
                                    semaphore.signal()
                                    group.leave()
                                }
                                
                            }
                            catch _ as NSError {
                            }
                        }
                    }
                    guard let httpResponse = response as? HTTPURLResponse,
                          (200...299).contains(httpResponse.statusCode) else {
                        return
                    }
                })
                URLCache.shared.removeAllCachedResponses()
                task.resume()
                _ = semaphore.wait(timeout: .distantFuture)
            }
        }
    }
    
    //function used to add an ingredient to the cart
    func addToCart(ingredient: IngredientsIdentifiable){
        for i in 0..<self.cartItems.count { //check to see if the ingredient is already in the cart
            if(self.cartItems[i].item.ingredientName == ingredient.ingredientName){ //if the ingredient is in the cart return
                return
            }
        }
        self.cartItems.append(CartItem(item: ingredient, quantity: 1)) //if you made it here the ingredient is not a duplicate
    }
    
    //function used to remove an ingredient from the cart
    func removeFromCart(ingredient: IngredientsIdentifiable){
        for i in 0..<self.cartItems.count { //check to see if the ingredient is actually in the cart
            if(self.cartItems[i].item.ingredientName == ingredient.ingredientName){ //if the ingredient is in the cart remove it
                self.cartItems.remove(at: i)
                return  
            }
        }
    }
}
