//
//  CartItem.swift
//  STTR
//
//  Created by Brady  on 4/20/21.
//

import SwiftUI

//class for storing the information of an item in the cart
class CartItem: ObservableObject, Identifiable {
    var id = UUID().uuidString
    var item: IngredientsIdentifiable
    @Published var quantity: Int = 1
    init(item: IngredientsIdentifiable, quantity: Int){
        self.item = item
        self.quantity = quantity
    }
    var krogerReplace: KrogerItem = KrogerItem(id: "")
}

