//
//  StockListViewModel.swift
//  iosStockApp
//
//  Created by Fangbo Xu on 11/25/20.
//

import Foundation

class StockListViewModel: ObservableObject {
    @Published public var stocks: [StockViewModel] = [StockViewModel]()
    @Published public var portfolioItems: [StockViewModel] = [StockViewModel]()
    @Published public var cash: Double = 20000
    
    
    //called when init the StockListView
    func load() {
        let localStorage = Storageservice()
        let webService = Webservice()
        let tickers = localStorage.getWatchlist() //get existing tickers stored in local watchlist
        self.stocks = []
        let portfolioTickers = localStorage.getPortfolio()
        self.portfolioItems = []
        for ticker in tickers {
            webService.addTickerAPI(ticker.ticker, self)
        }
        
        for portfolioTicker in portfolioTickers {
            webService.addTickerAPI(portfolioTicker.ticker, self, true, portfolioTicker.numShares)
        }
        print("haha load returned")
    }
    
    func refresh() {
        Webservice().refreshPriceSummary(self)
    }
}
