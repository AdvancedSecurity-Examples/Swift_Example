//
//  KrogerAPIView.swift
//  STTR
//
//  Created by Siddharth N. on 3/10/21.
//
import Foundation
import SwiftUI
import Combine



//view used to display the kroger items associated with a specific item
//from the cart
struct KrogerView: View {
    
    @State var searchval: String
    @State var cartItem: CartItem
    @State var update: String = "update"
    
    var body: some View {
        ScrollView{
            ForEach(Database.kroger.KrogerItems) {item in
                KrogerItemView(item: item, kroger: self).onAppear(perform: {
                    update+=" " //refresh the Kroger Grocery Item Page
                })
                Spacer()
            }
        }.navigationBarTitle(Text("Select an Ingredient"),displayMode: .inline)
        Text("\(update)").font(.system(size:1)).foregroundColor(.white).onAppear(perform: {
            Database.kroger.getProducts(searchval: cartItem.item.ingredientName ?? "", krogerView: self) //search for kroger equivalent of ingredient
            update+=" "
        })
    }
    
    //function used to make the view update and reflect changes
    func updateView(){
        update+=" "
    }
}

//view used for each individual kroger item in the kroger view
struct KrogerItemView : View {
    var item: KrogerItem
    @State var isChecked = false
    @State var kroger: KrogerView
    @Environment(\.colorScheme) var colorScheme
    private static var views: [KrogerItemView] = []
    var body: some View{
        ZStack(alignment: Alignment(horizontal: .center, vertical: .top), content: {
            
            VStack{
                KrogerImageView(withURL: item.image ?? "")
                    .frame(width: UIScreen.main.bounds.width - 30, height: 250)
                    .onAppear() {
                        KrogerItemView.views.append(self)
                    }
                    .onDisappear() {
                        clearArray()
                    }
                if(colorScheme != .dark){ //light mode
                    HStack{
                        Text("$" + (item.price ?? "")).font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                            .padding(.trailing,15)
                        
                    }
                    HStack{
                        let detail: String = item.description ?? ""
                        Text(detail.withoutHTMLTags)
                            .font(.body)
                            .foregroundColor(.black)
                            .lineLimit(2)
                            .frame(width: UIScreen.main.bounds.width - 30)
                        
                        Spacer(minLength: 0)
                    }
                } else { //dark mode
                    HStack{
                        Text("$" + (item.price ?? "")).font(.body)
                            .fontWeight(.medium)
                            .padding(.trailing,15)
                            .foregroundColor(Color.gray)
                        
                    }
                    HStack{
                        let detail: String = item.description ?? ""
                        Text(detail.withoutHTMLTags)
                            .font(.body)
                            .lineLimit(2)
                            .frame(width: UIScreen.main.bounds.width - 30)
                            .foregroundColor(Color.gray)
                        Spacer(minLength: 0)
                    }
                }
                
            }
            
            HStack{
                Button (action: {
                    uncheckBoxes()
                    self.isChecked.toggle()
                    kroger.cartItem.krogerReplace = item
                },
                label: {
                    if(!isChecked){
                        ZStack{
                            Image(systemName: "plus")
                                .foregroundColor(.clear)
                                .background(Color.clear)
                                .clipShape(Rectangle())
                                .frame(width: UIScreen.main.bounds.width - 30, height:300)
                            Image(systemName: "circle")
                                .padding(.leading,UIScreen.main.bounds.width - 30)
                                .frame(width: UIScreen.main.bounds.width - 30)
                        }
                    }
                    else{
                        ZStack{
                            Image(systemName: "plus")
                                .foregroundColor(.clear)
                                .background(Color.clear)
                                .clipShape(Rectangle())
                                .frame(width: UIScreen.main.bounds.width - 30, height:300)
                            Image(systemName: "circle.fill")
                                .padding(.leading,UIScreen.main.bounds.width - 30)
                                .frame(width: UIScreen.main.bounds.width - 30)
                        }
                    }
                })
            }
        })
        .frame(width: UIScreen.main.bounds.width - 30)
        ColorDivider()
    }
    
    //function used to uncheck all of the radio buttons
    private func uncheckBoxes() {
        for box in KrogerItemView.views {
            box.isChecked = false
        }
    }
    //function used to clear the storage of items returned from Kroger
    func clearArray() {
        KrogerItemView.views.removeAll()
    }
}


