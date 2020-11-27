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
    var numShares: Double
    
    init(_ ticker:String) {
        self.ticker = ticker
        self.price = 0
        self.change = 0
        self.numShares = 0
    }
}


