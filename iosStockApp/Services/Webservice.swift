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
    func getStockPriceSummary(_ ticker: String, _ detailVM: DetailViewModel) {
        let url = "http://angularfinance-env.eba-m6bbnkf3.us-east-1.elasticbeanstalk.com/api/pricesummary/"+ticker //unique URL
        AF.request(url).validate().responseData{ (response) in
            
            let stockPriceInfo = try! JSON(data: response.data!) //converting response JSON to the swifty JSON struct
            let stock =
                PriceSummaryItem(ticker: ticker,
                                    last: stockPriceInfo[0]["last"].doubleValue,
                                    change: stockPriceInfo[0]["prevClose"].doubleValue - stockPriceInfo[0]["last"].doubleValue,
                                    low: stockPriceInfo[0]["low"].doubleValue,
                                    bidPrice: stockPriceInfo[0]["bidPrice"].doubleValue,
                                    open: stockPriceInfo[0]["open"].doubleValue,
                                    mid: stockPriceInfo[0]["mid"].doubleValue)
            detailVM.stockPriceSummaryInfo = stock
        }
    
    }
    
    //getAbout: given a ticker, get the company summary
    func getAbout(_ ticker: String, _ detailVM: DetailViewModel) {
        let url = "http://angularfinance-env.eba-m6bbnkf3.us-east-1.elasticbeanstalk.com/api/summary/"+ticker //unique URL
        AF.request(url).validate().responseData{ (response) in
            let aboutInfo = try! JSON(data: response.data!) //converting response JSON to the swifty JSON struct
            detailVM.stockAboutInfo = aboutInfo["description"].stringValue.replacingOccurrences(of: "\"", with: " ").trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    //getNews: given a ticker, get the ticker's list of NewsItems
    func getNews(_ ticker: String, _ detailVM: DetailViewModel) {
        print("called get news")
//        return
        let url = "http://angularfinance-env.eba-m6bbnkf3.us-east-1.elasticbeanstalk.com/api/news/"+ticker //unique URL
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
                let newsPiece = NewsItem(id: i, source: subJson["source"]["name"].stringValue, title: subJson["title"].stringValue, url: subJson["url"].stringValue, urlToImage: subJson["urlToImage"].stringValue, publishedAt: subJson["publishedAt"].stringValue)
                updatedNews.append(newsPiece)
                i += 1
   
            }
            detailVM.stockNews = updatedNews
        }
    }
    
    
    
    //addTickerAPI adds the input ticker to the passed in StockListVM and update its price via REST
    func addTickerAPI(_ ticker: String, _ stockListVM: StockListViewModel, _ portfolioOption: Bool = false, _ numShares: Double = 0) {
        let url = "http://angularfinance-env.eba-m6bbnkf3.us-east-1.elasticbeanstalk.com/api/pricesummary/"+ticker //unique URL
        AF.request(url).validate().responseData{ (response) in
            
            let stockPriceInfo = try! JSON(data: response.data!) //converting response JSON to the swifty JSON struct
            let stock = Stock(ticker)
            stock.price = stockPriceInfo[0]["last"].doubleValue
            stock.change = stockPriceInfo[0]["prevClose"].doubleValue - stockPriceInfo[0]["last"].doubleValue
            if portfolioOption {
                stock.numShares = numShares
            }
            if portfolioOption {
                stockListVM.portfolioItems.append(StockViewModel(stock))
            }
            else {
                stockListVM.stocks.append(StockViewModel(stock))
            }
            print("addTickerAPI")
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
                        newstock.change = stockPriceInfo[0]["prevClose"].doubleValue - stockPriceInfo[0]["last"].doubleValue
                        newstock.numShares += numShares
                        if(newstock.numShares == 0) {
                            stockListVM.portfolioItems.remove(at:index)
                            print("updateTickerPrice for portfolio: removed emptied positions")
                            return
                        }
                        stockListVM.portfolioItems[index].stock = newstock
                        print("updateTickerPrice for portfolio")
                        return
                    }
                }
            } else {
                //Watchlist Case
                for (index,stockVM) in stockListVM.stocks.enumerated() {
                    if(stockVM.ticker == ticker) {
                        let newstock = stockListVM.portfolioItems[index].stock //get current stock from stockListVM
                        newstock.price = stockPriceInfo[0]["last"].doubleValue
                        newstock.change = stockPriceInfo[0]["prevClose"].doubleValue - stockPriceInfo[0]["last"].doubleValue
                        newstock.numShares = numShares
                        stockListVM.portfolioItems[index].stock = newstock
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
                newStock.change = stockPriceInfo[0]["prevClose"].doubleValue - stockPriceInfo[0]["last"].doubleValue
                stockListVM.stocks[index].stock = newStock
//                stockListVM.stocks[index].stock.price = stockPriceInfo[0]["last"].doubleValue
//                stockListVM.stocks[index].stock.change = stockPriceInfo[0]["prevClose"].doubleValue - stockPriceInfo[0]["last"].doubleValue
                print("after update for \(newStock.ticker) \( newStock.price)")
            }
        }
        
        for index in 0..<stockListVM.portfolioItems.count {//iterate all stockViewModel within StockListVM
            let ticker = stockListVM.portfolioItems[index].stock.ticker
            let url = "http://angularfinance-env.eba-m6bbnkf3.us-east-1.elasticbeanstalk.com/api/pricesummary/"+ticker //unique URL
            print("refreshed!")
            AF.request(url).validate().responseData { (response) in
                let stockPriceInfo = try! JSON(data: response.data!)
                print("updated price for \(stockListVM.portfolioItems[index].ticker) \(stockPriceInfo[0]["last"].doubleValue)")
                let newStock = stockListVM.portfolioItems[index].stock
                newStock.price = stockPriceInfo[0]["last"].doubleValue
                newStock.change = stockPriceInfo[0]["prevClose"].doubleValue - stockPriceInfo[0]["last"].doubleValue
                stockListVM.portfolioItems[index].stock = newStock

                print("after update for \(stockListVM.portfolioItems[index].stock.ticker) \( stockListVM.portfolioItems[index].stock.price)")
            }
        }
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
            newStockPriceSummaryInfo.change = stockPriceInfo[0]["prevClose"].doubleValue - stockPriceInfo[0]["last"].doubleValue
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
