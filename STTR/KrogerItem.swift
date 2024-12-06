//
//  Kroger.swift
//  STTR
//
//  Created by Siddharth N. on 3/10/21.
//
import UIKit

//struct used to store information about Kroger Items
//used to store and replace items in the cart
struct KrogerItem : Identifiable{
    var id: String
    var upc: String?
    var brand: String?
    var image: String?
    var description: String?
    var price: String?
}



