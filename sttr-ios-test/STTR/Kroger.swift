//
//  Kroger.swift
//  STTR
//
//  Created by Siddharth N. on 3/10/21.
//
import UIKit
//struct Price: Codable{
//    var price: String?
//}
//
//struct PriceItem: Codable{
//    var prices: [Price]?
//}

struct Kroger : Identifiable{
    var id: String
    var upc: String?
    var brand: String?
    var image: String?
    var description: String?
    var price: String?
}



