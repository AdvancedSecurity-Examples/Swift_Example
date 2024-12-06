//
//  KrogerAPIView.swift
//  STTR
//
//  Created by Siddharth N. on 3/10/21.
//
import Foundation
import SwiftUI
import Combine




struct KrogerView: View {
    @EnvironmentObject var kroger: KrogerAPI
    @State var searchval: String
    @State var cartItem: CartItem
    @State var update: String = "update"
    
    var body: some View {
        ScrollView{
            ForEach(kroger.KrogerItems) {item in
                KrogerItemView(item: item, kroger: self).onAppear(perform: {
                    update+=" " //refresh the Kroger Grocery Item Page
                })
                Spacer()
            }
        }.navigationBarTitle(Text("Select an Ingredient"),displayMode: .inline)
        Text("\(update)").font(.system(size:1)).foregroundColor(.white).onAppear(perform: {
            kroger.getProducts(searchval: cartItem.item.ingredientName ?? "", krogerView: self)
            update+=" "
        })
    }
    func updateView(){
        update+=" "
    }
}
struct KrogerItemView : View {
    var item: KrogerItem
    @State var isChecked = false
    @State var kroger: KrogerView
    private static var views: [KrogerItemView] = []
    var body: some View{
        ZStack(alignment: Alignment(horizontal: .center, vertical: .top), content: {
            
            VStack{
                KrogerImageView(withURL: item.image ?? "")
                    //ImageView(withURL: r.value(forKey: "image") as? String ?? "test")
                    .frame(width: UIScreen.main.bounds.width - 30, height: 250)
                    .onAppear() {
                        KrogerItemView.views.append(self)
                    }
                    .onDisappear() {
                        clearArray()
                    }
                HStack{
                    // .lineLimit(2)
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
                                //.padding(10)
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
                                //.padding(10)
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
        Divider()
    }
    
    private func uncheckBoxes() {
        for box in KrogerItemView.views {
            box.isChecked = false
        }
    }
    
    func clearArray() {
        KrogerItemView.views.removeAll()
    }
}


