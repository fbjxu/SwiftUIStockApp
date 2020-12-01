//
//  TradeView.swift
//  iosStockApp
//
//  Created by Fangbo Xu on 11/30/20.
//

import Foundation
import SwiftUI

struct successView: View {
    @Environment(\.presentationMode) var presentationMode
    var isBuy: Bool = true
    var stockName: String = ""
    
        
    var body: some View {
        ZStack {

                Color.green
                .edgesIgnoringSafeArea(.all)
            VStack{
                VStack{
                    Text("Congratulations!")
                        .bold()
                        .font(.title)
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                    if(isBuy) {
                        Text("You have successfully bought 1 share of \(self.stockName)")
                            .foregroundColor(.white)
                            .font(.body)
                    }
                    else {
                        Text("You have successfully sold 1 share of \(self.stockName)")
                            .foregroundColor(.white)
                            .font(.body)
                    }
                }
                .offset(y:300)
                
                Spacer()
                Button(action: {
                    //action
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 25)
                            .frame(width: 350, height: 50, alignment: .center)
                            .foregroundColor(.white)
                        Text("Done")
                            .bold()
                            .foregroundColor(.green)
                    }
                   
                }
                
                
            }
 
        }
        
    }

}

struct TradeView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var numShares = ""
    @State private var showingSuccessView = false
    @ObservedObject var listVM: StockListViewModel //from parent
    @ObservedObject var detailVM: DetailViewModel //from parent
    @State private var isBuy = false
    
    var stockTicker:String //from parent
    var stockName: String //from parent

    
    init(_ listVM: StockListViewModel, _ detailVM: DetailViewModel, _ inputTicker: String, _ inputName: String) {
        self.listVM = listVM
        self.detailVM = detailVM
        self.stockTicker = inputTicker
        self.stockName = inputName
    }
    
    var body: some View {
        if(showingSuccessView) {
            successView(isBuy: self.isBuy, stockName: self.stockName)
        } else {
            NavigationView{
                VStack{
                    Text("Trade \(self.stockName) shares")
                        .font(.title3)
                        .bold()
                        .offset(y:-50)

                    HStack{
                        TextField("0", text: self.$numShares)
                            .font(.system(size: 120))
                            .keyboardType(.numberPad)
                        Spacer()
                        Text("Share")
                            .font(.system(size: 30))
                            .offset(y:40)
                        
                   
                    }
                    HStack {
                        Spacer()
                        Text("x $\(String(format: "%.2f",self.detailVM.stockPriceSummaryInfo.last))/share = \(String(format: "%.2f", self.detailVM.stockPriceSummaryInfo.last * (Double(self.numShares) ?? 0)))")
                            .font(.body)
                    }
                    Spacer()
                    Text("$3000 available to buy \(self.stockTicker)")
                        .font(.body)
                        .foregroundColor(.gray)
                    HStack{
                        Button(action: {
                            //action
                            Storageservice().buyStock(self.stockTicker, Double(self.numShares)!, self.listVM)
                            self.isBuy = true
                            self.showingSuccessView.toggle()
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 25)
                                    .frame(width: 170, height: 50, alignment: .center)
                                    .foregroundColor(.green)
                                Text("Buy")
                                    .bold()
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Button(action: {
                            //action
                            self.isBuy = false
                            Storageservice().sellStock(self.stockTicker, Double(self.numShares)!, self.listVM)
                            self.showingSuccessView.toggle()
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 25)
                                    .frame(width: 170, height: 50, alignment: .center)
                                    .foregroundColor(.green)
                                Text("Sell")
                                    .bold()
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    
                }
                .navigationBarItems(leading: Button(action:{
                    self.presentationMode.wrappedValue.dismiss()
                }){Image(systemName: "xmark")
                                        .foregroundColor(.black)
                                        .imageScale(.large)})

            }
            .padding(.horizontal, 10)
        }
        
        
    }
}


struct Trade_Previews: PreviewProvider {
    static var previews: some View {
        return TradeView(StockListViewModel(), DetailViewModel(), "AAPL", "APPLE")
    }
    
}


struct Success_Previews: PreviewProvider {
    static var previews: some View {
        return successView()
    }
    
}
