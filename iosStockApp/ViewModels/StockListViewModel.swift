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
    
    
    //called when init the StockListView
    func load() {
        let localStorage = Storageservice()
        let webService = Webservice()
        let tickers = localStorage.getWatchlist() //get existing tickers stored in local watchlist
        self.stocks = []
        for ticker in tickers {
            webService.addTickerAPI(ticker.ticker, self)
        }
        let portfolioTickers = localStorage.getPortfolio()
        self.portfolioItems = []
        for portfolioTicker in portfolioTickers {
            webService.addTickerAPI(portfolioTicker.ticker, self, true, portfolioTicker.numShares)
        }
    }
    
    func refresh() {
        Webservice().refreshPriceSummary(self)
    }
}
