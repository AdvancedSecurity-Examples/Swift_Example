//
//  AddIngredientsView.swift
//  STTR
//
//  Created by Brady  on 5/13/21.
//

import SwiftUI

//view used for choosing ingredients from the recipe selected
//displays data from spoonacular API call
struct AddIngredientsView: View {
    @EnvironmentObject var recipe: RecipeInfo
    
    var ingredientList: [IngredientsIdentifiable]
    var recipeItem: RecipeItem
    var recipeName: String
    var body: some View {
        VStack(spacing: 0) {
            Text(recipeName)
                .font(.system(size: 72, weight: .bold))
                .foregroundColor(Color.blue)
                .padding(.bottom,0)
            ScrollView(.vertical) {
                VStack {
                    //makes an individual view for each ingredient in the recipe
                    ForEach(recipeItem.ingredients ?? [IngredientsIdentifiable]()) { ingredient in
                        IngredientView(recipeItem: recipeItem, ingredient: ingredient)
                    }
                }
            }
        }
    }
}

//view for specific ingredient
struct IngredientView: View {
    @EnvironmentObject var recipe: RecipeInfo
    var recipeItem: RecipeItem
    var ingredient: IngredientsIdentifiable
    
    
    var body: some View {
        HStack{
            VStack(alignment: .leading, spacing: 3) {
                Text(ingredient.ingredientName ?? "")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundColor(Color(.darkGray))


                HStack(spacing: 3){
                    Text(String(ingredient.amount ?? 0.0))
                        .font(.system(size: 14))
                        .fontWeight(.light)
                    Text(ingredient.unit ?? "")
                        .font(.system(size: 14))
                        .fontWeight(.light)
                    
                }
                ColorDivider()
            }
            .padding(.leading,10)
            Spacer()
            Button(action: {
                if (!ingredient.isAdded){ //add or remove ingredient depending on state
                    recipe.addToCart(ingredient: ingredient)
                    
                } else {
                    recipe.removeFromCart(ingredient: ingredient)
                }
                ingredient.isAdded.toggle()
                   },
                   label: {
                    if (!ingredient.isAdded){ //select or unselect depending on whether it has been clicked or not
                            Text("SELECT")
                                .font(.system(size: 14, weight: .regular, design: .default))
                                .foregroundColor(Color.white)
                                .background(RoundedRectangle(cornerRadius: 10)
                                .fill(Color.blue)
                                .frame(width: 75, height: 30))
                                .padding(.trailing,15)
                        }
                        else{
                            Text("SELECTED")
                                .font(.system(size: 14, weight: .regular, design: .default))
                                .foregroundColor(Color.white)
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray2)).frame(width: 77, height: 30))
                                .padding(.trailing,15)
                        }
                   }) 
        }
    }
}
