//
//  RecipeView.swift
//  STTR
//
//  Created by elizabeth on 2/6/21.
//
import Foundation
import SwiftUI

struct RecipeView : View {
    @EnvironmentObject var session: SessionStore
    @EnvironmentObject var recipe: RecipeStore
    @State private var searchval = ""
    @Binding var showMenu: Bool
    //@State private var result: [[String: Any]] = nil
    
    // @EnvironmentObject var recipes: RecipeStore
        
    
    
    var body : some View {
        ScrollView{
            VStack{
            
                    HStack {
                        TextField("Search recipes", text: $searchval, onCommit: {recipe.searchRecipes(searchval: searchval, recipeView: self);})
                            .autocapitalization(UITextAutocapitalizationType.none)
                        
                        // Searching the recipes for the given value
                        if searchval != "" {
                            Button(action: { recipe.searchRecipes(searchval: searchval, recipeView: self); }, label: {
                                Image(systemName: "magnifyingglass")
                                    .font(.title)
                                    .foregroundColor(.gray)
                            })
                            .animation(.easeIn)
                        }
                    
                    
                    
                    
                    }.padding(.horizontal)
                    .padding(.top,10)
                    Divider()
                    Spacer()
                    
                    // Displaying the searched items
                    ForEach(recipe.items) {item in
                    //ForEach(recipes.resultList, id: \.self) {r in
                        ZStack(alignment: Alignment(horizontal: .center, vertical: .top), content: {
                            
                            VStack{
                                ImageView(withURL: item.item_image)
                                //ImageView(withURL: r.value(forKey: "image") as? String ?? "test")
                                    .frame(width: UIScreen.main.bounds.width - 30, height: 250)
                                
                                Text(item.item_name)
                                //Text(r.value(forKey: "title") as? String ?? "test")
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(.black)
                                    .frame(width: UIScreen.main.bounds.width - 30)
                                    // .lineLimit(2)
                                HStack{
                                    let detail: String = item.item_details
                                    Text(detail.withoutHTMLTags)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .lineLimit(2)
                                        .frame(width: UIScreen.main.bounds.width - 30)
                                 
                                    Spacer(minLength: 0)
                                }
                            }

                                NavigationLink(destination: AddIngredientsView(ingredientList: item.ingredients ?? [IngredientsIdentifiable](),recipeName: item.item_name)) {
                                    Image(systemName: item.isAdded ? "checkmark" : "plus")
                                        .foregroundColor(.clear)
                                        //.padding(10)
                                        .background(item.isAdded ? Color.green : Color.clear)
                                        .clipShape(Rectangle())
                                        .frame(width: UIScreen.main.bounds.width - 30, height:300)
                                        .onDisappear {
                                            updateView()
                                        }
                                        
                                    
                                }
                            
                            
                            
                            
                        })
                        .frame(width: UIScreen.main.bounds.width - 30)
                            
                        
                        Divider()
                    }
                    Spacer()
              //  }
            }

          //  }

            
        }
    }
    
    // Used to force an update on the View
    func updateView() {
        let word = searchval
        searchval = ""
        searchval = word
    
    }
        
}
