//
//  StockListViewModel.swift
//  iosStockApp
//
//  Created by Fangbo Xu on 11/25/20.
//

import Foundation

class StockListViewModel: ObservableObject {
    @Published public var stocks: [StockViewModel] = [StockViewModel]()
    
    //called when init the StockListView
    func load() {
        let tickers = Storageservice().getWatchlist() //get existing tickers stored in local watchlist
        self.stocks = []
        for ticker in tickers {
            Webservice().summaryAPI(ticker.ticker, self)
        }
        
    }
    
    func refresh() {
        Webservice().refreshPriceSummary(self)
    }
}
