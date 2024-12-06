//
//  RecipeResults.swift
//  STTR
//
//  Created by Brady  on 4/22/21.

import Foundation

// Structs for searchRecipes()
struct RecipeResults: Codable {
    var results: [Results]
}
//struct to help perse the random recipes
struct RandomRecipeResults: Codable {
    var recipes: [Results]
}
//struct used to store the results of a recipe from spoonacular
struct Results: Codable {
    var title: String?
    var summary: String?
    var id: Int?
    var image: String?
    var readyInMinutes: Int?
    var servings: Int?
    var dairyFree: Bool?
    var glutenFree: Bool?
    var vegan: Bool?
    var vegetarian: Bool?
}

// Structs for getIngredients()
struct RecipeIngredients: Codable {
    var ingredients: [Ingredients]
}

//struct for encoding ingredients response
struct Ingredients: Codable{
    var name: String?
    var image: String?
    var amount: recipeAmount
}

//struct for encoding the amount of igredient in a recipe
struct recipeAmount: Codable {
    var metric: measurementInfo
}

//struct for encoding measurement info
struct measurementInfo: Codable {
    var value: Double?
    var unit: String?
}

//class used to denote an ingredient in a recipe
class IngredientsIdentifiable: ObservableObject, Identifiable {
    var id: Int
    var ingredientName: String?
    var ingredientImageURL: String?
    var amount: Double?
    var unit: String?
    @Published var isAdded: Bool = false
    init(id: Int, ingredientName: String, ingredientImageURL: String, amount: Double, unit: String){
        self.id = id
        self.ingredientName = ingredientName
        self.ingredientImageURL = ingredientImageURL
        self.amount = amount
        self.unit = unit
    }

}
