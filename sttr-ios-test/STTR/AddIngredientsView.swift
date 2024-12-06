//
//  AddIngredientsView.swift
//  STTR
//
//  Created by Brady  on 5/13/21.
//

import SwiftUI

struct AddIngredientsView: View {
    @EnvironmentObject var recipe: RecipeStore
    
    var ingredientList: [IngredientsIdentifiable]
    var recipeName: String
    var body: some View {
        VStack(spacing: 0) {
            Text(recipeName)
                .font(.system(size: 72, weight: .bold))
                .foregroundColor(Color(red: 245/255, green: 66/255, blue: 117/255))
                .padding(.bottom,0)
            ScrollView(.vertical) {
                VStack {
                    ForEach(ingredientList) { ingredient in
                        IngredientView(ingredient: ingredient)
                        
                        
                    }

                }
            }
        }
    }
}

struct IngredientView: View {
    @EnvironmentObject var recipe: RecipeStore
    @State var isSelected = false
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
                Divider()
            }
            .padding(.leading,10)
            Spacer()
            Button(action: {
                        self.isSelected.toggle()
                        recipe.addToCart(ingredient: ingredient, currentlySelected: isSelected)
                
                
                        
                   },
                   label: {
                        if (!isSelected){
                            Text("SELECT")
                                .font(.system(size: 14, weight: .regular, design: .default))
                                .foregroundColor(Color.white)
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color.pink).frame(width: 75, height: 30))
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
