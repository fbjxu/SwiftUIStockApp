//
//  DetailViewModel.swift
//  iosStockApp
//
//  Created by Fangbo Xu on 11/28/20.
//

import Foundation

class DetailViewModel: ObservableObject {
    @Published public var stockPriceSummaryInfo: PriceSummaryItem = PriceSummaryItem(ticker: "", last: 0, change: 0, low: 0, bidPrice: 0, open: 0, mid: 0, high:0, volume:0)
    @Published public var stockNews: [NewsItem] = [NewsItem]()
    @Published public var stockAboutInfo: String = ""
    @Published public var detailLoaded = false
    @Published public var favored = false
    
    func getPriceSummary(_ ticker: String) {
        let detailPageGroup = DispatchGroup()
        Webservice().getStockPriceSummary(ticker, self, detailPageGroup)
        Webservice().getAbout(ticker, self, detailPageGroup)
        Webservice().getNews(ticker, self, detailPageGroup)
        detailPageGroup.notify(queue: .main) {
            self.favored = Storageservice().isFavored(ticker)
            self.detailLoaded = true
            print("Finished all requests for detail page.")
        }
        
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
    
    func getHigh() -> String {
        return String(format: "%.2f", self.stockPriceSummaryInfo.high)
    }
    
    func getVolume() -> String {
        let largeNumber = self.stockPriceSummaryInfo.volume
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value:largeNumber))
        return String(formattedNumber ?? "0")
    }
    
}
