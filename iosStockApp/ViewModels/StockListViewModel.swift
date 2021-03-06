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
    @Published public var cash: Double = 0
    @Published public var networth: Double = 0
    @Published public var loaded: Bool = false
    
    
    //called when init the StockListView
    func load() {
        let localStorage = Storageservice()
        let webService = Webservice()
        let tickers = localStorage.getWatchlist() //get existing tickers stored in local watchlist
        self.cash = localStorage.getCash().cash
        self.stocks = []
        let portfolioTickers = localStorage.getPortfolio()
        self.portfolioItems = []
        let myGroup = DispatchGroup()
        for ticker in tickers {
            webService.addTickerAPI(ticker.ticker, self, false, 0, myGroup)
        }
        
        for portfolioTicker in portfolioTickers {
            webService.addTickerAPI(portfolioTicker.ticker, self, true, portfolioTicker.numShares, myGroup)
        }
        
        myGroup.notify(queue: .main) {
            self.getNetworth()
            self.loaded = true
            print("Finished all requests.")
        }
    }
    
    func refresh() {
        Webservice().refreshPriceSummary(self)
    }
    
    func getNetworth(){
        var positionVal: Double = 0.0
        for position in self.portfolioItems {
            positionVal += position.stock.price * position.stock.numShares
        }
        self.networth = self.cash + positionVal
    }
}
