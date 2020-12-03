//
//  PriceSummaryItem.swift
//  iosStockApp
//
//  Created by Fangbo Xu on 11/28/20.
//

import Foundation

struct PriceSummaryItem {
    let ticker: String
    var last: Double //price
    var change: Double
    var low:Double
    var bidPrice: Double
    var open: Double
    var mid: Double
    var high: Double
    var volume: Double
    
}
