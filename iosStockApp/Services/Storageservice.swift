//
//  Storageservice.swift
//  iosStockApp
//
//  Created by Fangbo Xu on 11/26/20.
//

import Foundation

struct WatchListItem: Codable {
    var ticker: String
}

struct PortfolioItem: Codable {
    var ticker: String
    var numShares: Double
}

//Storageservice stores the portfolioList and watchList along with their helper methods
class Storageservice {
    var portfolioList: [PortfolioItem]
    var watchList: [WatchListItem]
    
    init() {
        //testing version
        self.portfolioList = []
        self.watchList = [WatchListItem(ticker: "AAPL"), WatchListItem(ticker: "GOOGL"), WatchListItem(ticker: "AMZN"), WatchListItem(ticker: "FB")] //hard code
        if let encoded = try? JSONEncoder().encode(watchList) {
            UserDefaults.standard.set(encoded, forKey: "watchlistItems")
        }
        //production version
//        do {
//            let storedPortfolioObjs = UserDefaults.standard.object(forKey: "portfolioItems")
//            let storedWatchlistObjs = UserDefaults.standard.object(forKey: "watchlistItems")
//            var storedPortfolioItems = [PortfolioItem]() //init stored Portfolio Items
//            var storedWatchlistItems = [WatchListItem]() //init stored Watchlist Items
//            if (storedPortfolioObjs != nil) {
//                storedPortfolioItems = try JSONDecoder().decode([PortfolioItem].self, from: storedPortfolioObjs as! Data)
//            }
//
//            if (storedWatchlistObjs != nil) {
//                storedWatchlistItems = try JSONDecoder().decode([WatchListItem].self, from: storedWatchlistObjs as! Data)
//            }
//            print("Init: Retrieved items: \(storedPortfolioItems)")
//            print("Init: Retrieved items: \(storedWatchlistItems)")
//            self.portfolioList = storedPortfolioItems
//            self.watchList = storedWatchlistItems
//        } catch let err {
//            self.portfolioList = []
//            self.watchList = []
//            print(err)
//        }
    }
    
    func getPortfolio() -> [PortfolioItem] {
        //get existing local storage of the portfolio
        do {
            let storedPortfolioObjs = UserDefaults.standard.object(forKey: "portfolioItems")
            var storedPortfolioItems = [PortfolioItem]()
            if (storedPortfolioObjs != nil) {
                storedPortfolioItems = try JSONDecoder().decode([PortfolioItem].self, from: storedPortfolioObjs as! Data)
            }
            print("Retrieved items: \(storedPortfolioItems)")
            return storedPortfolioItems
        } catch let err {
            print(err)
            return []
        }
    }
    
    func getWatchlist() -> [WatchListItem]{
        //get existing local storage of the portfolio
        do {
            let storedWatchlistObjs = UserDefaults.standard.object(forKey: "watchlistItems")
            var storedWatchlistItems = [WatchListItem]()
            if (storedWatchlistObjs != nil) {
                storedWatchlistItems = try JSONDecoder().decode([WatchListItem].self, from: storedWatchlistObjs as! Data)
            }
            print("getWatchlist items: \(storedWatchlistItems)")
            return storedWatchlistItems
            
            
        } catch let err {
            print(err)
            return []
        }
    }
    
    func updatePortfolioItem(_ ticker: String, _ numShares: Double) {
       
    }
    
    // method used to add a new stock to watchlist
    func addWatchlistItem(_ inputTicker: String, _ listVM: StockListViewModel) {
        var oldWatchList = self.getWatchlist()
        oldWatchList.append(WatchListItem(ticker: inputTicker))
        self.watchList = oldWatchList
        if let encoded = try? JSONEncoder().encode(oldWatchList) {
            Webservice().summaryAPI(inputTicker, listVM) //this add the new ticker and ask for the latest stock price
            UserDefaults.standard.set(encoded, forKey: "watchlistItems")
            print("addWatchlistItem ", String(data: encoded, encoding: .utf8)!)
        }
    }
    
    // method used to remove a new stock to watchlist
    func removeWatchlistItem(_ inputTicker: String, _ listVM: StockListViewModel) {
        let oldWatchList = self.getWatchlist()
        var newWatchlist = [WatchListItem]()
        for watchlistItem in oldWatchList { //iterate old watchlist and create new list without the input ticker stock
            if (watchlistItem.ticker != inputTicker) {
                newWatchlist.append(WatchListItem(ticker: watchlistItem.ticker))
            }
        }
        //update the local storage with the newly created watchlist
        self.watchList = newWatchlist
        if let encoded = try? JSONEncoder().encode(newWatchlist) {
            UserDefaults.standard.set(encoded, forKey: "watchlistItems")
            print("deleteWatchlistItem ", String(data: encoded, encoding: .utf8)!)
        }
    }
    
    
    
}
