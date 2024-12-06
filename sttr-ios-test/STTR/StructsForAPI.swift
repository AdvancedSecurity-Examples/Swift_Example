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

struct Ingredients: Codable{
    var name: String?
    var image: String?
    var amount: recipeAmount
}

struct recipeAmount: Codable {
    var metric: measurementInfo
}

struct measurementInfo: Codable {
    var value: Double?
    var unit: String?
}

struct IngredientsIdentifiable: Identifiable {
    var id: Int
    var ingredientName: String?
    var ingredientImageURL: String?
    var amount: Double?
    var unit: String?
   // var isAdded: Bool = false

}
