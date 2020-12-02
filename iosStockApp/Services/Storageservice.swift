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
//        portfolioList = [PortfolioItem(ticker: "AAPL", numShares: 10),PortfolioItem(ticker: "GOOGL", numShares: 12),PortfolioItem(ticker: "TSLA", numShares: 5)]
//        watchList = [WatchListItem(ticker: "AAPL"), WatchListItem(ticker: "GOOGL"), WatchListItem(ticker: "AMZN"), WatchListItem(ticker: "FB")] //hard code
//        if let encoded = try? JSONEncoder().encode(watchList) {
//            UserDefaults.standard.set(encoded, forKey: "watchlistItems")
//        }
//        if let portfolioEncoded = try? JSONEncoder().encode(portfolioList) {
//            UserDefaults.standard.set(portfolioEncoded, forKey: "portfolioItems")
//        }
        //production version
        do {
            
            let storedPortfolioObjs = UserDefaults.standard.object(forKey: "portfolioItems")
            let storedWatchlistObjs = UserDefaults.standard.object(forKey: "watchlistItems")
            var storedPortfolioItems = [PortfolioItem]() //init stored Portfolio Items
            var storedWatchlistItems = [WatchListItem]() //init stored Watchlist Items
            portfolioList = []
            watchList = [] //hard code
            /*************** Reset local storage *****************/
//            if let encoded = try? JSONEncoder().encode(watchList) {
//                UserDefaults.standard.set(encoded, forKey: "watchlistItems")
//            }
//            if let portfolioEncoded = try? JSONEncoder().encode(portfolioList) {
//                UserDefaults.standard.set(portfolioEncoded, forKey: "portfolioItems")
//            }
            
            /*************** Reset local storage *****************/
            
            if (storedPortfolioObjs != nil) {
                storedPortfolioItems = try JSONDecoder().decode([PortfolioItem].self, from: storedPortfolioObjs as! Data)
            }

            if (storedWatchlistObjs != nil) {
                storedWatchlistItems = try JSONDecoder().decode([WatchListItem].self, from: storedWatchlistObjs as! Data)
            }
            print("Init: Retrieved items: \(storedPortfolioItems)")
            print("Init: Retrieved items: \(storedWatchlistItems)")
            self.portfolioList = storedPortfolioItems
            self.watchList = storedWatchlistItems
        } catch let err {
            self.portfolioList = []
            self.watchList = []
            print(err)
        }
    }
    
    func getPortfolio() -> [PortfolioItem] {
        //get existing local storage of the portfolio
        do {
            let storedPortfolioObjs = UserDefaults.standard.object(forKey: "portfolioItems")
            var storedPortfolioItems: [PortfolioItem] = []
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
            var storedWatchlistItems: [WatchListItem] = []
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
    
    func buyStock(_ inputTicker: String, _ numShares: Double,  _ price: Double, _ listVM: StockListViewModel) {
        var oldPortfolioList = self.getPortfolio()
        //if the list contains the ticker
        for(index, element) in oldPortfolioList.enumerated() {
            if (element.ticker.uppercased() == inputTicker.uppercased()) {
                //found in the list -> update item num Shares
                var updatePortfolioEntry = oldPortfolioList[index]
                updatePortfolioEntry.numShares += numShares
                oldPortfolioList[index] = updatePortfolioEntry
                self.portfolioList = oldPortfolioList
                
                if let encoded = try? JSONEncoder().encode(oldPortfolioList) {
                    Webservice().updateTickerAPI(inputTicker, listVM, true, numShares) //update the list and ask for the latest stock price
                    Webservice().updateTickerAPI(inputTicker, listVM, false, numShares) //update watchlist; this method is soft: only update when the item in list
                    UserDefaults.standard.set(encoded, forKey: "portfolioItems") //update local storage
                    print("buyStock ", String(data: encoded, encoding: .utf8)!) //debug
                }
                listVM.cash -= price * numShares
                listVM.getNetworth()
                return
            }
        }
        //did not found in the list -> append a new portfolioItem
        oldPortfolioList.append(PortfolioItem(ticker:inputTicker, numShares: numShares))
        self.portfolioList = oldPortfolioList
        if let encoded = try? JSONEncoder().encode(oldPortfolioList) {
            Webservice().addTickerAPI(inputTicker, listVM, true, numShares) //add this new ticker and ask for the latest stock price
            UserDefaults.standard.set(encoded, forKey: "portfolioItems") //update local storage
            print("buyStock ", String(data: encoded, encoding: .utf8)!) //debug
        }
        listVM.cash -= price * numShares
        listVM.getNetworth()
        return        
    }
    
    func sellStock(_ inputTicker: String, _ numShares: Double, _ price: Double, _ listVM: StockListViewModel) {
        var oldPortfolioList = self.getPortfolio()
        //iterate existing portoflio
   
        for(index, element) in oldPortfolioList.enumerated() {
            if (element.ticker.uppercased() == inputTicker.uppercased()) {
                //found in the list -> update item num Shares
                var updatePortfolioEntry = oldPortfolioList[index]
                updatePortfolioEntry.numShares -= numShares
                if (updatePortfolioEntry.numShares == 0) {
                    oldPortfolioList.remove(at:index)
                    self.portfolioList = oldPortfolioList //TODO: get rid of later
                    if let encoded = try? JSONEncoder().encode(oldPortfolioList) {
                        Webservice().updateTickerAPI(inputTicker, listVM, true, -numShares) //update the list and ask for the latest stock price
                        Webservice().updateTickerAPI(inputTicker, listVM, false, -numShares) //update watchlist; this method is soft: only update when the item in list
                        UserDefaults.standard.set(encoded, forKey: "portfolioItems") //update local storage
                        print("sellStock ", String(data: encoded, encoding: .utf8)!) //debug
                    }
                    listVM.cash += price * numShares
                    listVM.getNetworth()
                    return
                }
                oldPortfolioList[index] = updatePortfolioEntry //update existing portfolio list
                self.portfolioList = oldPortfolioList //TODO: get rid of later
                if let encoded = try? JSONEncoder().encode(oldPortfolioList) {
                    Webservice().updateTickerAPI(inputTicker, listVM, true, -numShares) //update the list and ask for the latest stock price
                    Webservice().updateTickerAPI(inputTicker, listVM, false, -numShares) //update watchlist; this method is soft: only update when the item in list
                    UserDefaults.standard.set(encoded, forKey: "portfolioItems") //update local storage
                    print("sellStock ", String(data: encoded, encoding: .utf8)!) //debug
                }
                listVM.cash += price * numShares
                listVM.getNetworth()
                return
            }
        }
    }
    
    // method used to add a new stock to watchlist
    func addWatchlistItem(_ inputTicker: String, _ listVM: StockListViewModel) {
        var oldWatchList = self.getWatchlist()
        oldWatchList.append(WatchListItem(ticker: inputTicker))
        self.watchList = oldWatchList
        if let encoded = try? JSONEncoder().encode(oldWatchList) {
            Webservice().addTickerAPI(inputTicker, listVM) //this add the new ticker and ask for the latest stock price
            UserDefaults.standard.set(encoded, forKey: "watchlistItems")
            print("addWatchlistItem ", String(data: encoded, encoding: .utf8)!)
        }
    }
    
    // method used to remove a new stock to watchlist
    func removeWatchlistItem(_ inputTicker: String, _ listVM: StockListViewModel) {
        
        //update view
        for (index, element) in listVM.stocks.enumerated() {
            if (element.ticker.uppercased() == inputTicker.uppercased()) {
                listVM.stocks.remove(at:index)
                break
            }
        }
        //update local storage
        var oldWatchList = self.getWatchlist()
        for (index, element) in oldWatchList.enumerated() { //iterate old watchlist and create new list without the input ticker stock
            if (element.ticker.uppercased() == inputTicker.uppercased()) {
                oldWatchList.remove(at:index)
                break
            }
        }

        if let encoded = try? JSONEncoder().encode(oldWatchList) {
            UserDefaults.standard.set(encoded, forKey: "watchlistItems")
            print("deleteWatchlistItem ", String(data: encoded, encoding: .utf8)!)
        }
    }
    
    func getNumShares(_ inputTicker: String) -> Double {
        var res = 0.0
        let oldPortfolioList = self.getPortfolio()
        //iterate existing portoflio
   
        for(_, element) in oldPortfolioList.enumerated() {
            if(element.ticker.uppercased() == inputTicker.uppercased()) {
                res = element.numShares
                break
            }
        }
        return res
    }
    
    func isFavored(_ inputTicker: String)->Bool {
        let watchlist = self.getWatchlist()
        for item in watchlist {
            if (item.ticker.uppercased() == inputTicker.uppercased()) {
                return true
            }
        }
        return false
    }
    
    
    
}
