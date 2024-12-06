//
//  Item.swift
//  STTR
//
//  Created by Brady  on 4/20/21.
//

import SwiftUI

//struct for storing info about a recipe
struct RecipeItem: Identifiable {
    
    var id: Int
    var item_name: String
    var item_details: String
    var item_image: String
    var isAdded: Bool = false
    var ingredients: [IngredientsIdentifiable]?
    var preparationMinutes: Int
    var servings: Int
    var dairyFree: Bool
    var glutenFree: Bool
    var vegan: Bool
    var vegetarian: Bool
}
