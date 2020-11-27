//
//  Stock.swift
//  iosStockApp
//
//  Created by Fangbo Xu on 11/24/20.
//

import Foundation

class Stock: Codable {
    let ticker: String
    var price: Double
    var change: Double
    
    init(_ ticker:String, _ price: Double, _ change: Double) {
        self.ticker = ticker
        self.price = price
        self.change = change
    }
}


