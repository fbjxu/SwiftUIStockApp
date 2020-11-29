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
            detailVM.stockAboutInfo = aboutInfo["description"].stringValue 
        }
    }
    
    //getNews: given a ticker, get the ticker's list of NewsItems
    func getNews(_ ticker: String, _ detailVM: DetailViewModel) {
        let url = "http://angularfinance-env.eba-m6bbnkf3.us-east-1.elasticbeanstalk.com/api/news/"+ticker //unique URL
        AF.request(url).validate().responseData{ (response) in
            
            let newsInfo = try! JSON(data: response.data!) //converting response JSON to the swifty JSON struct
            print(newsInfo.count)
            for (_, subJson): (String, JSON) in newsInfo {
                print(subJson)
            }
            
//            let news =
//                PriceSummaryItem(ticker: ticker,
//                                    last: stockPriceInfo[0]["last"].doubleValue,
//                                    change: stockPriceInfo[0]["prevClose"].doubleValue - stockPriceInfo[0]["last"].doubleValue,
//                                    low: stockPriceInfo[0]["low"].doubleValue,
//                                    bidPrice: stockPriceInfo[0]["bidPrice"].doubleValue,
//                                    open: stockPriceInfo[0]["open"].doubleValue,
//                                    mid: stockPriceInfo[0]["mid"].doubleValue)
//            detailVM.stockPriceSummaryInfo = stock
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
            print("got summary API")
            print(stockListVM.stocks)
        }
    }
    
    func refreshPriceSummary(_ stockListVM: StockListViewModel) {
        for index in 0..<stockListVM.stocks.count {//iterate all stockViewModel within StockListVM
            let ticker = stockListVM.stocks[index].stock.ticker
            let url = "http://angularfinance-env.eba-m6bbnkf3.us-east-1.elasticbeanstalk.com/api/pricesummary/"+ticker //unique URL
            print("refreshed!")
            AF.request(url).validate().responseData { (response) in
                let stockPriceInfo = try! JSON(data: response.data!)
                print(stockPriceInfo)
                stockListVM.stocks[index].stock.price = stockPriceInfo[0]["last"].doubleValue
                stockListVM.stocks[index].stock.change = stockPriceInfo[0]["prevClose"].doubleValue - stockPriceInfo[0]["last"].doubleValue
            }
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
