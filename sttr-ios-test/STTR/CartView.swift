//
//  CartView.swift
//  STTR
//
//  Created by Brady  on 3/16/21.
//

import SwiftUI
import Foundation
        


struct CartView: View {
    @EnvironmentObject var recipe: RecipeStore
    @State var update: String = "update"
    @State var total: Float = 0
    var body: some View {
        VStack {
//            Button(action: {
//                //self.navigationController?.popToRootViewController(animated: true)
//
//            }){
//                Text("Return to Recipe")
//            }
            
            ScrollView(.vertical, showsIndicators: false){

                VStack(spacing: 0){
                    ForEach(recipe.cartItems){ cart in
                        HStack(spacing: 15){
                            
//                            ImageView(withURL: cart.item.ingredientImageURL ?? "")
//                                .frame(width: 130, height: 130)
//                                .cornerRadius(15)
                            if(cart.krogerReplace.id != ""){
                                KrogerImageView(withURL: cart.krogerReplace.image ?? "")
                                    .frame(width: 40, height: 40)
                                    .onAppear(perform: {
                                        let subPrice = Float(cart.krogerReplace.price as! String)!
                                        let priceQuant = subPrice*Float(cart.quantity)
                                        total+=priceQuant
                                        //incrementTotal(toAdd: cart.krogerReplace.price)
                                        update+=" "
                                    })
                                //total+=37.0//Float(cart.krogerReplace.price ?? 0.00)
                                
                            }
                            VStack(alignment: .leading, spacing: 10){
                                NavigationLink(destination: KrogerView(searchval: cart.item.ingredientName ?? "No ingredient found", cartItem: cart)    ){
                                    if(cart.krogerReplace.id == ""){
                                        Text(cart.item.ingredientName ?? "No ingredient found")
                                            .fontWeight(.semibold)
                                            .foregroundColor(.black)
                                            .lineLimit(2)
                                            
                                        
                                    }
                                    else{
                                        Text(cart.krogerReplace.description ?? "No ingredient found")
                                            .fontWeight(.semibold)
                                            .foregroundColor(.black)
                                            .lineLimit(2)
                                    }
                                }.isDetailLink(false)
                                  //  .frame(width: UIScreen.main.bounds.width - 30)

//                                let detail: String = cart.item.item_details
//                                Text(detail.withoutHTMLTags)
//                                    .fontWeight(.semibold)
//                                    .foregroundColor(.gray)
//                                    .lineLimit(2)
                                  //  .frame(width: UIScreen.main.bounds.width - 30)
                                
                                HStack(spacing: 8){
                                    Text("Price: ")
                                        .fontWeight(.heavy)
                                        .foregroundColor(.black)
                                    if(cart.krogerReplace.id != ""){
                                        Text("$\(cart.krogerReplace.price ?? "")").fontWeight(.heavy)
                                            .foregroundColor(.black)
                                    }
                                    Spacer(minLength: 0)
                                    VStack{
                                        Text("Quantity")
                                            .fontWeight(.semibold)
                                            .foregroundColor(.black)

                                        //Spacer(minLength: 0)
                                        HStack{
                                            Button(action: {
                                                if(cart.quantity > 0){
                                                    cart.quantity-=1
                                                }
                                                if(cart.quantity <= 0){
                                                    recipe.addToCart(ingredient: cart.item, currentlySelected: false)
                                                }
                                                update+=" "
                                                if(cart.krogerReplace.id != ""){
                                                    let subPrice = Float(cart.krogerReplace.price as! String)!
                                                    total-=subPrice
                                                }
                                                
                                            }){
                                                Image(systemName: "minus")
                                                    .font(.system(size: 10, weight: .heavy))
                                                    .foregroundColor(.black)

                                            }
                                            
                                            Text("\(cart.quantity)")
                                                .fontWeight(.heavy)
                                                .foregroundColor(.black)
                                                .padding(.vertical,5)
                                                .padding(.horizontal,8)
                                                .background(Color.black.opacity(0.06))

                                            Button(action: {cart.quantity+=1
                                                update+=" "
                                                if(cart.krogerReplace.id != ""){
                                                    let subPrice = Float(cart.krogerReplace.price as! String)!
                                                    total+=subPrice
                                                }
                                                
                                            }){
                                                Image(systemName: "plus")
                                                    .font(.system(size: 10, weight: .heavy))
                                                    .foregroundColor(.black)

                                            }
                                        }
                                    }
                                }
                            }


                        }
                        .padding()
                        .contentShape(RoundedRectangle(cornerRadius: 15))


                    }
                }

            }.onAppear(perform: { total = 0
                update+=" "
            })

            VStack{

                HStack{
                    Text(String(format: "Total: $%.2f",abs(total)))
                        .fontWeight(.heavy)
                        .foregroundColor(.gray)

                    
                }
                .padding([.top,.horizontal,.bottom])
                
                NavigationLink(destination: KrogerView(searchval: "milk", cartItem: Cart(item: IngredientsIdentifiable(id: 0), quantity: 0))){
                    Text("KROGER").font(.system(size: 20, weight: .regular, design: .default))
                        .foregroundColor(Color.white)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.pink).frame(width: 150, height: 40))
                        .padding(.trailing,15).padding(.bottom,4)
                }
                Text("\(update)").font(.system(size:1)).foregroundColor(.white)
            }
            }
        .background(Color.white)
        //.navigationBarBackButtonHidden(true)
        
        
    }
//
//    func incrementTotal(toAdd : FLoat){
//        total+=toAdd
//    }
    }






//    struct CartItems: Identifiable {
//        var id: Int
//        let product: String
//        let price, quantity: Double
//    }
    
    
//    let items: [CartItems] = [
//        .init(id: 0, product: "Product", price: 0, quantity: 0),
//        .init(id: 1, product: "Product", price: 0, quantity: 0),
//        .init(id: 2, product: "Product", price: 0, quantity: 0),
//        .init(id: 3, product: "Product", price: 0, quantity: 0),
//        .init(id: 4, product: "Product", price: 0, quantity: 0),
//        .init(id: 5, product: "Product", price: 0, quantity: 0),
//        .init(id: 6, product: "Product", price: 0, quantity: 0),
//
//
//    ]
//
//
//    var body: some View {
//
//
//
//            List {
//                ForEach (items) { item in
//                    HStack{
//                        Rectangle()
//                            .frame(width: 100, height: 100, alignment: .leading)
//
//                        VStack(alignment: .leading, spacing: 10) {
//                            Text(item.product)
//                                .frame(alignment: .leading)
//                                .font(.headline)
//                            Text("Price: " + "$" + String(format: "%.2f",item.price))
//                                .frame(alignment: .leading)
//                                .font(.subheadline)
//                            Text("Quantity: " + String(format: "%.0f",item.quantity))
//                                .frame(alignment: .leading)
//                                .font(.subheadline)
//                        }.padding(.leading, 8)
//                    }.padding(.init(top: 12, leading: 0, bottom: 12, trailing: 0))
//
//
//                }
//                VStack{
//                    Color.black.frame(height: CGFloat(1) / UIScreen.main.scale)
//                }
//                Group {
//                    VStack(alignment: .leading){
//                        HStack{
//                            Text("Subtotal: ")
//                                .frame(width: 75, height: 20, alignment: .leading)
//
//                            Text("XXXX")
//                                .frame(width: 75, height: 20, alignment: .center)
//                        }
//                        HStack{
//                            Text("Tax: ")
//                                .frame(width: 75, height: 20, alignment: .leading)
//                            Text("XXXX")
//                                .frame(width: 75, height: 20, alignment: .center)
//                        }
//                        HStack{
//                            Text("Total: ")
//                                .frame(width: 75, height: 20, alignment: .leading)
//                            Text("XXXX")
//                                .frame(width: 75, height: 20, alignment: .center)
//                        }
//
//                    }
//
//
//                }
//            }
//            .navigationBarTitle(Text("Shopping Cart"), displayMode: .inline)
//
//    }
//}
