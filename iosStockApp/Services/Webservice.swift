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
    
    func summaryAPI(_ ticker: String, _ stockListVM: StockListViewModel) {
        let url = "http://angularfinance-env.eba-m6bbnkf3.us-east-1.elasticbeanstalk.com/api/pricesummary/"+ticker //unique URL
        AF.request(url).validate().responseData{ (response) in
            
            let stockPriceInfo = try! JSON(data: response.data!) //converting response JSON to the swifty JSON struct
            let stock = Stock(ticker, stockPriceInfo[0]["last"].doubleValue, stockPriceInfo[0]["prevClose"].doubleValue - stockPriceInfo[0]["last"].doubleValue)
            let newStockViewModel = StockViewModel(stock)
            stockListVM.stocks.append(newStockViewModel)
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
    
}
