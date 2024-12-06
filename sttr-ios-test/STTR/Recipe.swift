//
//  recipeStore.swift
//  STTR
//
//  Created by elizabeth on 2/25/21.
//

import UIKit
import Combine
import Foundation



class RecipeStore : ObservableObject{
    // Cart
    @Published var cartItems: [Cart] = []
    @Published var items: [Item] = []
  
    let objectWillChange = PassthroughSubject<RecipeStore, Never>()
    
                    

    @Published var resultList :[NSDictionary] =  [] {
        willSet {
            print("I swear I'm addicted to blue cheese")
            objectWillChange.send(self)

        }
    }
 
    var shouldRedirectToUpdateView = false {
        willSet {
            objectWillChange.send(self)
        }
    }

    func searchRecipes(searchval: String, recipeView: RecipeView){


       let domainURLString = "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/complexSearch?query="
       let parameters = "&addRecipeInformation=true&offset=0&number=10"
        let combined = (domainURLString + searchval + parameters).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!


        let headers = [
            "x-rapidapi-key": "dcfe9a59bamsh62b7564bd8625adp1c859ajsnf2a3df45d987",
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
                print("Error with fetching films: \(error)")
                return
              } else {

                if let data = data {


                    do {
                        let decoder = JSONDecoder()
                        let recipeDetails = try decoder.decode(RecipeResults.self, from: data)
                        
                        // testing purposes, remove after
                        let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                        //print(jsonArray)
                        // Adding the search results to the item list
                        self.items.removeAll()
                        for i in 0..<recipeDetails.results.count {
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
                            self.getIngredients(recipeID: recipeDetails.results[i].id ?? 0, itemIndex: i)

                        }
                        // Update the view to display the search results
                        recipeView.updateView()
                        

                    } catch let error as NSError {
                        print("searchrecipes error")
                        print(error)
                    }

                }
              }

              guard let httpResponse = response as? HTTPURLResponse,
                    (200...299).contains(httpResponse.statusCode) else {
                print("Error with the response, unexpected status code: \(response)")
                return
              }
            print("here1")
            })
            task.resume()



    }

    func getIngredients(recipeID: Int, itemIndex: Int) {
        let domainURLString = "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/"
        let stringID = String(recipeID)
        let dataType = "/ingredientWidget.json"
        
        let combined = domainURLString + stringID + dataType
        



         let headers = [
             "x-rapidapi-key": "dcfe9a59bamsh62b7564bd8625adp1c859ajsnf2a3df45d987",
             "x-rapidapi-host": "spoonacular-recipe-food-nutrition-v1.p.rapidapi.com",
             "useQueryString": "true"
         ]

         let request = NSMutableURLRequest(url: NSURL(string: combined)! as URL,
                                                 cachePolicy: .useProtocolCachePolicy,
                                             timeoutInterval: 10.0)
         request.httpMethod = "GET"
         request.allHTTPHeaderFields = headers
        
        print("In getingredients")
        let task = URLSession.shared.dataTask(with: request as URLRequest , completionHandler: { (data, response, error) in
              if let error = error {
                print("Error with fetching films: \(error)")
                return
              } else {

                if let data = data {

                    do {
                        let decoder = JSONDecoder()
                        print("here in decoder")
                        let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                        print(jsonArray)
            
                        let recipeIngredients = try decoder.decode(RecipeIngredients.self, from: data)
                        print("Got past decoder")
                
                        var ingredientList = [IngredientsIdentifiable]()
                        var num = 0
                        for ingredient in recipeIngredients.ingredients {
                            ingredientList.append(IngredientsIdentifiable(id: num, ingredientName: ingredient.name, ingredientImageURL: ingredient.image, amount: ingredient.amount.metric.value, unit: ingredient.amount.metric.unit))
                            num = num + 1
                        }
                        self.items[itemIndex].ingredients = ingredientList
                        print()
                     
                        
                        
                        
                        
                        
                        

                    } catch let error as NSError {
                        print("getIngredients error")
                        print("item index: ",itemIndex)
                        print("recipeID:",recipeID)
                        print(error)
                    }

                }
              }

              guard let httpResponse = response as? HTTPURLResponse,
                    (200...299).contains(httpResponse.statusCode) else {
                print("Error with the response, unexpected status code: \(response)")
                return
              }
            print("here1")
            })
            task.resume()
       // return recipeIngredients as! RecipeIngredients
       // return recipeIngredients as! RecipeIngredients
            
        
    }

//
    func addToCart(ingredient: IngredientsIdentifiable, currentlySelected: Bool ){

        
        //[getIndex(item: item, isCartIndex: false)].isAdded = !item.isAdded

        // "add to cart" button pressed again after item already added
        if currentlySelected{
            // add to cart
            self.cartItems.append(Cart(item: ingredient, quantity: 1))
            return
        }
        else{

            // remove from cart
            
            self.cartItems.remove(at: getIndex(item: ingredient, isCartIndex: true))
        }


    }


    func getIndex(item: IngredientsIdentifiable, isCartIndex: Bool) -> Int {
        let index = self.items.firstIndex { (item1) -> Bool in
            return item.id == item1.id
        } ?? 0

        let cartIndex = self.cartItems.firstIndex { (item1) -> Bool in
            return item.id == item1.item.id
        } ?? 0

        return isCartIndex ? cartIndex : index
    }

    
}
