//
//  Cart.swift
//  STTR
//
//  Created by Brady  on 4/20/21.
//

import SwiftUI

class Cart: Identifiable {
    var id = UUID().uuidString
    var item: IngredientsIdentifiable = IngredientsIdentifiable(id: 0)
    var quantity: Int = 1
    init(item: IngredientsIdentifiable, quantity: Int){
        self.item = item
        self.quantity = quantity
    }
    var krogerReplace: Kroger = Kroger(id: "")
}

