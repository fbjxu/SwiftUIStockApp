//
//  Webservice.swift
//  iosStockApp
//
//  Created by Fangbo Xu on 11/24/20.
//

import Foundation
import Alamofire
import SwiftyJSON

class Webservice {
    
    
    //getStockPriceSummary: given a ticker, get all stock summary information including
    func getStockPriceSummary(_ ticker: String, _ detailVM: DetailViewModel, _ group: DispatchGroup = DispatchGroup()) {
        group.enter()
        let url = "http://angularfinance-env.eba-m6bbnkf3.us-east-1.elasticbeanstalk.com/api/pricesummary/"+ticker //unique URL
        AF.request(url).validate().responseData{ (response) in
            
            let stockPriceInfo = try! JSON(data: response.data!) //converting response JSON to the swifty JSON struct
            let stock =
                PriceSummaryItem(ticker: ticker,
                                    last: stockPriceInfo[0]["last"].doubleValue,
                                    change: stockPriceInfo[0]["last"].doubleValue - stockPriceInfo[0]["prevClose"].doubleValue,
                                    low: stockPriceInfo[0]["low"].doubleValue,
                                    bidPrice: stockPriceInfo[0]["bidPrice"].doubleValue,
                                    open: stockPriceInfo[0]["open"].doubleValue,
                                    mid: stockPriceInfo[0]["mid"].doubleValue,
                                    high: stockPriceInfo[0]["high"].doubleValue,
                                    volume: stockPriceInfo[0]["volume"].doubleValue)
            detailVM.stockPriceSummaryInfo = stock
            group.leave()
        }
    
    }
    
    //getAbout: given a ticker, get the company summary
    func getAbout(_ ticker: String, _ detailVM: DetailViewModel, _ group: DispatchGroup = DispatchGroup()) {
        group.enter()
        let url = "http://angularfinance-env.eba-m6bbnkf3.us-east-1.elasticbeanstalk.com/api/summary/"+ticker //unique URL
        AF.request(url).validate().responseData{ (response) in
            let aboutInfo = try! JSON(data: response.data!) //converting response JSON to the swifty JSON struct
            detailVM.stockAboutInfo = aboutInfo["description"].stringValue.replacingOccurrences(of: "\"", with: " ").trimmingCharacters(in: .whitespacesAndNewlines)
            group.leave()
        }
    }
    
    //getNews: given a ticker, get the ticker's list of NewsItems
    func getNews(_ ticker: String, _ detailVM: DetailViewModel, _ group: DispatchGroup = DispatchGroup()) {
        group.enter()
        print("called get news")
        group.leave() //TODO: remove
        return//TODO: remove
        let url = "http://stockappchart-env.eba-xpd25bx3.us-east-2.elasticbeanstalk.com/api/news/"+ticker //unique URL
        AF.request(url).validate().responseData{ (response) in
            if(response.data == nil) {
                return
            }
            let newsInfo = try! JSON(data: response.data!) //converting response JSON to the swifty JSON struct
//            print(newsInfo.count)
            var updatedNews = [NewsItem]()
            var i: Int = 1
            for (_, subJson): (String, JSON) in newsInfo {
//                print(subJson)
//                print("title:", subJson["title"])
//                print("source: ", subJson["source"]["name"])
//                print("time: ", subJson["publishedAt"])
                
                let dateString = self.parseDate(subJson["publishedAt"].stringValue)
                let newsPiece = NewsItem(id: i, source: subJson["source"]["name"].stringValue, title: subJson["title"].stringValue, url: subJson["url"].stringValue, urlToImage: subJson["urlToImage"].stringValue, publishedAt: dateString)
                updatedNews.append(newsPiece)
                i += 1
   
            }
            detailVM.stockNews = updatedNews
            group.leave()
        }
    }
    
    func parseDate(_ inputDate: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        let convertedDate = formatter.date(from: inputDate)?.addingTimeInterval(-28800) ?? Date() //get article time
        let today = Date()
        var diffComponents = Calendar.current.dateComponents([.hour], from: convertedDate, to: today)
        print("today date" + formatter.string(from: today))
        print("news date" + formatter.string(from: convertedDate))
        let hours = diffComponents.hour ?? 0
        if(hours > 24) { //if more than 24 hours
            diffComponents = Calendar.current.dateComponents([.day], from: convertedDate, to: today)
            let days = diffComponents.day ?? 0
            if (hours > 48 ) {
                return String(days) + " days ago"
            }
            return String(days) + " day ago"
        }
        if(hours > 1) {
            return String(hours) + " hours ago"
        }
        
        diffComponents = Calendar.current.dateComponents([.minute], from: convertedDate, to: today)
        let minutes = diffComponents.minute ?? 0
        return String(minutes) + " minutes ago"
    }
    
    //addTickerAPI adds the input ticker to the passed in StockListVM and update its price via REST
    func addTickerAPI(_ ticker: String, _ stockListVM: StockListViewModel, _ portfolioOption: Bool = false, _ numShares: Double = 0, _ group: DispatchGroup = DispatchGroup()) {
        group.enter()
        let url = "http://stockappchart-env.eba-xpd25bx3.us-east-2.elasticbeanstalk.com/api/nicepricesummary/"+ticker //unique URL
        AF.request(url).validate().responseData{ (response) in
            
            let stockPriceInfo = try! JSON(data: response.data!) //converting response JSON to the swifty JSON struct
            
            let stock = Stock(ticker)
            stock.price = stockPriceInfo[0][0]["last"].doubleValue
            stock.change = stockPriceInfo[0][0]["last"].doubleValue - stockPriceInfo[0][0]["prevClose"].doubleValue
//            let companynameURL = "http://angularfinance-env.eba-m6bbnkf3.us-east-1.elasticbeanstalk.com/api/summary/"+ticker //for getting name
//            AF.request(companynameURL).validate().responseData{ (response) in
//                let aboutInfo = try! JSON(data: response.data!) //converting response JSON to the swifty JSON struct
//                stock.name = aboutInfo["name"].stringValue.replacingOccurrences(of: "\"", with: " ").trimmingCharacters(in: .whitespacesAndNewlines)
//            }
            stock.name = stockPriceInfo[1]["name"].stringValue
            if(numShares == 0) {
                stock.numShares = Storageservice().getNumShares(ticker)
            } else {
                stock.numShares = numShares
            }
            
            if portfolioOption {
                stockListVM.portfolioItems.append(StockViewModel(stock))
                for (index,stockVM) in stockListVM.stocks.enumerated() {//get current stock from stockListVM
                    if(stockVM.ticker == ticker) {
                        let newWatchStock = stockListVM.stocks[index].stock //get current stock from stockListVM
                        newWatchStock.price = stock.price
                        newWatchStock.change = stock.change
                        newWatchStock.numShares = stock.numShares
                        stockListVM.stocks[index].stock = newWatchStock
                        break
                    }
                }
            }
            else {
                stockListVM.stocks.append(StockViewModel(stock))
            }
            print("addTickerAPI")
            stockListVM.getNetworth()
            group.leave()
            print("left group for \(ticker)")
        }
    }
    
    //updateTickerAPI: given a input ticker that already exists in the local storage, update its price
    func updateTickerAPI(_ ticker: String, _ stockListVM: StockListViewModel, _ portfolioOption: Bool = false, _ numShares: Double = 0) {
        let url = "http://angularfinance-env.eba-m6bbnkf3.us-east-1.elasticbeanstalk.com/api/pricesummary/"+ticker //unique URL
        AF.request(url).validate().responseData{ (response) in
            
            let stockPriceInfo = try! JSON(data: response.data!) //converting response JSON to the swifty JSON struct
            
            //portfolio Case
            if portfolioOption {
                for (index,stockVM) in stockListVM.portfolioItems.enumerated() {
                    if(stockVM.ticker == ticker) {
                        let newstock = stockListVM.portfolioItems[index].stock //get current stock from stockListVM
                        newstock.price = stockPriceInfo[0]["last"].doubleValue
                        newstock.change = stockPriceInfo[0]["last"].doubleValue - stockPriceInfo[0]["prevClose"].doubleValue
                        newstock.numShares += numShares
                        if(newstock.numShares == 0) {
                            stockListVM.portfolioItems.remove(at:index)
                            stockListVM.getNetworth()
                            print("updateTickerPrice for portfolio: removed emptied positions")
                            for (index,stockVM) in stockListVM.stocks.enumerated() {
                                if(stockVM.ticker == ticker) {
                                    let newWatchStock = stockListVM.stocks[index].stock //get current stock from stockListVM
                                    newWatchStock.price = stockPriceInfo[0]["last"].doubleValue
                                    newWatchStock.change = stockPriceInfo[0]["last"].doubleValue - stockPriceInfo[0]["prevClose"].doubleValue
                                    newWatchStock.numShares = 0
                                    stockListVM.stocks[index].stock = newWatchStock
                                    print("updateTickerPrice for watchlist")
                                    return
                                }
                            }
                            return
                        }
                        stockListVM.portfolioItems[index].stock = newstock
                        for (index,stockVM) in stockListVM.stocks.enumerated() {//get current stock from stockListVM
                            if(stockVM.ticker == ticker) {
                                let newWatchStock = stockListVM.stocks[index].stock //get current stock from stockListVM
                                newWatchStock.price = stockPriceInfo[0]["last"].doubleValue
                                newWatchStock.change = stockPriceInfo[0]["last"].doubleValue - stockPriceInfo[0]["prevClose"].doubleValue
                                newWatchStock.numShares = newstock.numShares
                                stockListVM.stocks[index].stock = newWatchStock
                                print("updateTickerPrice for watchlist")
                                return
                            }
                        }
                        stockListVM.getNetworth()
                        print("updateTickerPrice for portfolio")
                        return
                    }
                }
            } else {
                //Watchlist Case
                for (index,stockVM) in stockListVM.stocks.enumerated() {
                    if(stockVM.ticker == ticker) {
                        let newstock = stockListVM.stocks[index].stock //get current stock from stockListVM
                        newstock.price = stockPriceInfo[0]["last"].doubleValue
                        newstock.change = stockPriceInfo[0]["last"].doubleValue - stockPriceInfo[0]["prevClose"].doubleValue
                        newstock.numShares += numShares
                        stockListVM.stocks[index].stock = newstock
                        stockListVM.getNetworth()
                        print("updateTickerPrice for watchlist")
                        return
                    }
                }
                
            }
        }
    }
    
    func refreshPriceSummary(_ stockListVM: StockListViewModel) {
        for index in 0..<stockListVM.stocks.count {//iterate all stockViewModel within StockListVM
            let ticker = stockListVM.stocks[index].stock.ticker
            let url = "http://angularfinance-env.eba-m6bbnkf3.us-east-1.elasticbeanstalk.com/api/pricesummary/"+ticker //unique URL
            print("refreshed!")
            AF.request(url).validate().responseData { (response) in
                let stockPriceInfo = try! JSON(data: response.data!)
                print("updated price for \(stockListVM.stocks[index].ticker) \(stockPriceInfo[0]["last"].doubleValue)")
                let newStock = stockListVM.stocks[index].stock
                newStock.price = stockPriceInfo[0]["last"].doubleValue
                newStock.change = stockPriceInfo[0]["last"].doubleValue - stockPriceInfo[0]["prevClose"].doubleValue
                stockListVM.stocks[index].stock = newStock
                print("after update for \(newStock.ticker) \( newStock.price)")
            }
        }
        
        for index in 0..<stockListVM.portfolioItems.count {//iterate all portfolioItems within StockListVM
            let ticker = stockListVM.portfolioItems[index].stock.ticker
            let url = "http://angularfinance-env.eba-m6bbnkf3.us-east-1.elasticbeanstalk.com/api/pricesummary/"+ticker //unique URL
            print("refreshed!")
            AF.request(url).validate().responseData { (response) in
                let stockPriceInfo = try! JSON(data: response.data!)
                print("updated price for \(stockListVM.portfolioItems[index].ticker) \(stockPriceInfo[0]["last"].doubleValue)")
                let newStock = stockListVM.portfolioItems[index].stock
                newStock.price = stockPriceInfo[0]["last"].doubleValue
                newStock.change = stockPriceInfo[0]["last"].doubleValue - stockPriceInfo[0]["prevClose"].doubleValue
                stockListVM.portfolioItems[index].stock = newStock

                print("after update for \(stockListVM.portfolioItems[index].stock.ticker) \( stockListVM.portfolioItems[index].stock.price)")
            }
        }
        stockListVM.getNetworth()
    }
    
    //given a detailVM, update the stockPriceSummaryItem contained in the detailVM
    func refreshSinglePriceSummary(_ detailVM: DetailViewModel) {
        let ticker = detailVM.stockPriceSummaryInfo.ticker
        let url = "http://angularfinance-env.eba-m6bbnkf3.us-east-1.elasticbeanstalk.com/api/pricesummary/"+ticker //unique URL
        print("refreshed single price summary for detail page!")
        
        AF.request(url).validate().responseData { (response) in
            let stockPriceInfo = try! JSON(data: response.data!)
            print("updated price for \(detailVM.stockPriceSummaryInfo.ticker) \(stockPriceInfo[0]["last"].doubleValue)")
            //create new stockPriceSummaryItem
            var newStockPriceSummaryInfo = detailVM.stockPriceSummaryInfo
            newStockPriceSummaryInfo.last = stockPriceInfo[0]["last"].doubleValue
            newStockPriceSummaryInfo.change = stockPriceInfo[0]["last"].doubleValue - stockPriceInfo[0]["prevClose"].doubleValue
            newStockPriceSummaryInfo.low = stockPriceInfo[0]["low"].doubleValue
            newStockPriceSummaryInfo.bidPrice = stockPriceInfo[0]["bidPrice"].doubleValue
            newStockPriceSummaryInfo.open = stockPriceInfo[0]["open"].doubleValue
            newStockPriceSummaryInfo.mid = stockPriceInfo[0]["mid"].doubleValue
            //update the referenced detailVM
            detailVM.stockPriceSummaryInfo = newStockPriceSummaryInfo

            print("after update for \(detailVM.stockPriceSummaryInfo.ticker) \( detailVM.stockPriceSummaryInfo.last)")
        }
    }
    
    func grabAutocompletes(_ keyword: String, _ searchVM: SearchBarViewModel) {
        let url = "http://angularfinance-env.eba-m6bbnkf3.us-east-1.elasticbeanstalk.com/api/autocomplete/"+keyword //unique URL
        print("grab autocomplete from API!")
        var autocompleteItems = [SearchBarItem]()
        if keyword.count>=3 {
            AF.request(url).validate().responseData { (response) in
                let autocompleteInfo = try! JSON(data: response.data!)
//                print(test)
//                print(autocompleteInfo)
//                print(autocompleteInfo.count)
                for (_, subJson): (String, JSON) in autocompleteInfo {
//                    print(subJson["name"])
                    let autocompleteResult = SearchBarItem(ticker: subJson["ticker"].stringValue, name: subJson["name"].stringValue)
                    print(autocompleteResult)
                    autocompleteItems.append(autocompleteResult)
                }
                searchVM.suggestedStocks = autocompleteItems
            }
        }
        else {
            searchVM.suggestedStocks = []
        }
        
    }
    
}
