//
//  DetailViewModel.swift
//  iosStockApp
//
//  Created by Fangbo Xu on 11/28/20.
//

import Foundation

class DetailViewModel: ObservableObject {
    @Published public var stockPriceSummaryInfo: PriceSummaryItem = PriceSummaryItem(ticker: "", last: 0, change: 0, low: 0, bidPrice: 0, open: 0, mid: 0)
    @Published public var stockAboutInfo: String = ""
    
    func getPriceSummary(_ ticker: String) {
        Webservice().getStockPriceSummary(ticker, self)
        Webservice().getAbout(ticker, self)
    }
    
    func getAbout(_ ticker: String) -> String {
        return self.stockAboutInfo
    }
    
    func getLast() -> String {
        return String(format: "%.2f", self.stockPriceSummaryInfo.last)
    }
    
    func getChange() -> String {
        return String(format: "%.2f", self.stockPriceSummaryInfo.change)
    }
    
    func getLow() -> String {
        return String(format: "%.2f", self.stockPriceSummaryInfo.low)
    }
    
    func getBidPrice() -> String {
        return String(format: "%.2f", self.stockPriceSummaryInfo.bidPrice)
    }
    
    func getOpen() -> String {
        return String(format: "%.2f", self.stockPriceSummaryInfo.open)
    }
    
    func getMid() -> String {
        return String(format: "%.2f", self.stockPriceSummaryInfo.mid)
    }
}
