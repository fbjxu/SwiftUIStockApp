//
//  StockViewModel.swift
//  iosStockApp
//
//  Created by Fangbo Xu on 11/25/20.
//

import Foundation

struct StockViewModel {
    var stock: Stock
    
    var ticker: String {
        return self.stock.ticker.uppercased()
    }
    
    
    var price: String {
        return String(format: "%.2f", self.stock.price)
    }
    
    var change: String {
        return String(format: "%.2f", self.stock.change)
    }
    
    var numShares:String {
        return String(format: "%.2f", self.stock.numShares)
    }
    
    var name:String {
        return self.stock.name
    }
    
    init(_ stock: Stock) {
        self.stock = stock
    }
}
