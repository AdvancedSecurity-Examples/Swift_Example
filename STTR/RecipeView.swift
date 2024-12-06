//
//  RecipeView.swift
//  STTR
//
//  Created by elizabeth on 2/6/21.
//
import Foundation
import SwiftUI

//view used to replace the normal divider
//this is used throughout the entire app
//it changes color to make the light mode
//as well as dark mode look better
struct ColorDivider: View {
    var height: CGFloat = 2
    var direction: Axis.Set = .horizontal
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        ZStack {
            Rectangle()
                .fill(colorScheme == .dark ? Color(red: 0.278, green: 0.278, blue: 0.290) : Color(red: 0.706, green: 0.706, blue: 0.714))
                .frame(height: height)
                .edgesIgnoringSafeArea(.horizontal)
        }.onAppear(perform:{
        })
    }
}

//view used to display recipes gotten from the spoonacular API
//includes a search bar and scrollable view
struct RecipeView : View {
    @EnvironmentObject var session: SessionStore
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var recipe: RecipeInfo
    @State private var searchval = ""
    @Binding var showMenu: Bool
    @State var showPopup: Bool = false //used for popup views related to each ingredient'ss info
    @State var itemSelected: RecipeItem = RecipeItem(id: 0, item_name: "Test", item_details: "", item_image: "", preparationMinutes: 0, servings: 0, dairyFree: false, glutenFree: false, vegan: false, vegetarian: false) //used to store info related to popup
        
    
    var body : some View {

            VStack{
                HStack {
                    //textfield used for searching
                    TextField("Search recipes", text: $searchval, onCommit: {
                        recipe.countRecipeAPIrequests = 0
                        recipe.items.removeAll()
                        recipe.searchRecipes(searchval: searchval);
                        
                        
                    }).onAppear(perform: {
                        if(searchval == ""){ //if the search bar is empty populate the list with random recipes
                            recipe.countRecipeAPIrequests = 0
                            recipe.items.removeAll()
                            recipe.getRandomRecipes()
                        }
                    })
                    .disableAutocorrection(true)
                    .autocapitalization(UITextAutocapitalizationType.none)
                    // Searching the recipes for the given value
                    if searchval != "" {
                        Button(action: {
                            recipe.searchRecipes(searchval: searchval);
                            recipe.countRecipeAPIrequests = 0
                            recipe.items.removeAll()
                            
                        }, label: {
                            Image(systemName: "magnifyingglass")
                                .font(.title)
                                .foregroundColor(.gray)
                        })
                        .animation(.easeIn)
                    }
                }.padding(.horizontal)
                .padding(.top, 10)
                VStack{
                    ColorDivider()
                    List(0..<recipe.items.count, id: \.self){ i in //scrollable view of all the recipes returned
                        
                        if (i == recipe.items.count - 1){
                            RecipeItemView(item: recipe.items[i], searchval: searchval, isLast: true, parent: self, index: i)
                        }
                        else{
                            if (i < recipe.items.count - 1) {
                                RecipeItemView(item: recipe.items[i], searchval: searchval, isLast: false, parent: self, index: i)
                            }
                        }
                    }
                    ColorDivider()
                }
            }
            //popup view only shown after selecting a recipe
            HalfModalView(isShown: $showPopup, modalHeight: 7*UIScreen.main.bounds.height/8){
                PopupView(item : itemSelected)
            }.onDisappear(perform: {
                self.showPopup = false
            })
        }
    
    // function used to force an update on the View
    func updateView() {
        let word = searchval
        searchval = ""
        searchval = word
        
    }
    
}

//view used to display the info of a specific recipe
struct RecipeItemView: View {
    @EnvironmentObject var recipe: RecipeInfo
    @Environment(\.colorScheme) var colorScheme //used to determine dark or light mode
    var item: RecipeItem
    var searchval: String
    var isLast: Bool
    var parent : RecipeView
    var index: Int
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .top), content: {
            VStack{
                ImageView(withURL: item.item_image)
                    .frame(width: UIScreen.main.bounds.width - 30)
                VStack{
                    if(colorScheme != .dark){ //light mode
                        Text(item.item_name)
                            .font(.callout)
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                            .frame(width: UIScreen.main.bounds.width - 30, height: (UIScreen.main.bounds.height/3 - UIScreen.main.bounds.height/4)/4)
                    } else { //dark mode
                        Text(item.item_name)
                            .font(.callout)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(width: UIScreen.main.bounds.width - 30, height: (UIScreen.main.bounds.height/3 - UIScreen.main.bounds.height/4)/4)
                    }
                    let detail: String = item.item_details
                    if (self.isLast){
                        Text(detail.withoutHTMLTags)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .frame(width: UIScreen.main.bounds.width - 30, height: 3*(UIScreen.main.bounds.height/3 - UIScreen.main.bounds.height/4)/4)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    //check to see if there are 50 requests and if there aren't search for more
                                    if (recipe.countRecipeAPIrequests != 50){
                                        recipe.searchRecipes(searchval: searchval)
                                    }
                                }
                            }
                    }
                    Text(detail.withoutHTMLTags)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(width: UIScreen.main.bounds.width - 30, height: 3*(UIScreen.main.bounds.height/3 - UIScreen.main.bounds.height/4)/4)
                    ColorDivider()
                }.frame(width: UIScreen.main.bounds.width - 30, height: (UIScreen.main.bounds.height/3 - UIScreen.main.bounds.height/4))
            }.frame(width: UIScreen.main.bounds.width - 30, height: UIScreen.main.bounds.height/3)

            Button(action: {
                self.parent.itemSelected = item
                let group = DispatchGroup()
                group.enter()
                DispatchQueue.main.async{
                    self.recipe.getIngredients(recipeID: item.id, itemIndex: index, group: group)
                }
                group.notify(queue: .main){
                    self.parent.itemSelected = self.recipe.items[index]
                    self.parent.showPopup.toggle()
                }
            }){
                Image(systemName: "plus")
                    .foregroundColor(.clear)
                    .background(item.isAdded ? Color.green : Color.clear)
                    .clipShape(Rectangle())
                    .frame(width: UIScreen.main.bounds.width - 30, height: UIScreen.main.bounds.height/3)
            }
        })
        .frame(width: UIScreen.main.bounds.width - 30, height: UIScreen.main.bounds.height/3)
        
    }
}

//view used to popup a display with nutritional info from the selected recipe
struct PopupView : View {
    @EnvironmentObject var session: SessionStore
    @EnvironmentObject var recipe: RecipeInfo
    @Environment(\.colorScheme) var colorScheme //used to determine light or dark mode
    var item: RecipeItem
    
    var body : some View {
        if(colorScheme != .dark){ //light mode
            VStack{
                Group{
                    Text("\(item.item_name)").bold().font(.system(size: 45, weight: .regular, design: .default)).frame(width: UIScreen.main.bounds.width-50)
                    Spacer().frame(height: UIScreen.main.bounds.height/20)
                    Text("Vegetarian: ") + Text("\(item.vegetarian ? "Yes" : "No")")
                    Spacer().frame(height:  UIScreen.main.bounds.height/18)
                    Text("Vegan: ") + Text("\(item.vegan ? "Yes" : "No")")
                    Spacer().frame(height:  UIScreen.main.bounds.height/18)
                }
                Group{
                    Text("Dairy Free: ") + Text("\(item.dairyFree ? "Yes" : "No")")
                    Spacer().frame(height:  UIScreen.main.bounds.height/18)
                    Text("Gluten Free: ") + Text("\(item.glutenFree ? "Yes" : "No")")
                    Spacer().frame(height:  UIScreen.main.bounds.height/18)
                    Text("Preparation Time: ") + Text("\(item.preparationMinutes)")  + Text(" Mins")
                    Spacer().frame(height:  UIScreen.main.bounds.height/18)
                    Text("Serves: ") + Text("\(item.servings)")
                }
                Spacer().frame(height:  UIScreen.main.bounds.height/18)
                //links to the view to select ingredients
                NavigationLink(destination: AddIngredientsView(ingredientList: item.ingredients ?? [IngredientsIdentifiable](),recipeItem: item, recipeName: item.item_name)) {
                    Text("See Ingredients").font(.system(size: 20, weight: .regular, design: .default))
                        .foregroundColor(Color.white)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.pink).frame(width: 150, height: 30))
                        .padding(.trailing,15)
                }
            }
            .background(RoundedRectangle(cornerRadius: 20).fill(Color.blue).frame(width: UIScreen.main.bounds.width-50, height: 3*UIScreen.main.bounds.height/4))
        } else{ //dark mode
            VStack{
                Group{
                    Text("\(item.item_name)").bold().font(.system(size: 45, weight: .regular, design: .default)).frame(width: UIScreen.main.bounds.width-50).foregroundColor(Color.pink)
                    Spacer().frame(height: UIScreen.main.bounds.height/20)
                    Text("Vegetarian: ").foregroundColor(Color.pink) + Text("\(item.vegetarian ? "Yes" : "No")").foregroundColor(Color.pink)
                    Spacer().frame(height:  UIScreen.main.bounds.height/18)
                    Text("Vegan: ").foregroundColor(Color.pink) + Text("\(item.vegan ? "Yes" : "No")").foregroundColor(Color.pink)
                    Spacer().frame(height:  UIScreen.main.bounds.height/18)
                }
                Group{
                    Text("Dairy Free: ").foregroundColor(Color.pink) + Text("\(item.dairyFree ? "Yes" : "No")").foregroundColor(Color.pink)
                    Spacer().frame(height:  UIScreen.main.bounds.height/18)
                    Text("Gluten Free: ").foregroundColor(Color.pink) + Text("\(item.glutenFree ? "Yes" : "No")").foregroundColor(Color.pink)
                    Spacer().frame(height:  UIScreen.main.bounds.height/18)
                    Text("Preparation Time: ").foregroundColor(Color.pink) + Text("\(item.preparationMinutes)").foregroundColor(Color.pink)  + Text(" Mins").foregroundColor(Color.pink)
                    Spacer().frame(height:  UIScreen.main.bounds.height/18)
                    Text("Serves: ").foregroundColor(Color.pink) + Text("\(item.servings)").foregroundColor(Color.pink)
                }
                Spacer().frame(height:  UIScreen.main.bounds.height/18)
                NavigationLink(destination: AddIngredientsView(ingredientList: item.ingredients ?? [IngredientsIdentifiable](),recipeItem: item, recipeName: item.item_name)) {
                    Text("See Ingredients").font(.system(size: 20, weight: .regular, design: .default))
                        .foregroundColor(Color.white)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.pink).frame(width: 150, height: 30))
                        .padding(.trailing,15)
                }
            }
            .background(RoundedRectangle(cornerRadius: 20).fill(Color(red: 0.15, green: 0.25, blue: 0.75 )).frame(width: UIScreen.main.bounds.width-50, height: 3*UIScreen.main.bounds.height/4))
        }
    }
}
