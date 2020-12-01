//
//  DetailStockView.swift
//  iosStockApp
//
//  Created by Fangbo Xu on 11/28/20.
//

import Foundation
import SwiftUI
import KingfisherSwiftUI



struct DetailStockView: View {
    @ObservedObject var detailVM =  DetailViewModel()
    @ObservedObject var listVM: StockListViewModel
    @State private var showingTradeSheet = false
    
    var stockTicker: String = ""
    var stockName: String = ""
    private var webService = Webservice()
    private var stockSummary:Stock
    let items = 1...10
    let rows = [
        GridItem(.flexible(), alignment: .leading),
        GridItem(.flexible(), alignment: .leading)
    ]
    private var threeColumnGrid = [GridItem(.flexible()), GridItem(.flexible())]
    
    @State private var aboutExpand: Bool = false
    
    
    init(_ stockTicker:String, _ stockName:String, _ listVM: StockListViewModel) {
        self.listVM = listVM
        self.stockTicker = stockTicker
        self.stockName = stockName
        self.stockSummary = Stock(stockTicker)
        //grab stock details
        detailVM.getPriceSummary(stockTicker)
        
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 0) {
                //symbol and prices
                HStack{
                    
                    
                    VStack (alignment:.leading) {
                        Text(self.stockTicker.uppercased())
                            .font(.largeTitle)
                            .bold()
                        
                        
                        Text(self.stockName)
                            .foregroundColor(.gray)
                        
                        HStack {
                            Text("$"+self.detailVM.getLast())
                                .font(.title)
                                .bold()
                            Text("$("+self.detailVM.getChange()+")")
                                .font(.title2)
                            
                        }
                        
                    }
//                    .padding(.horizontal, 10)
                    
                    Spacer()
                }
                
                //portfolio
                
                VStack (alignment: .leading) {
                    
                    HStack{
                        
                        VStack (alignment:.leading, spacing: 0) {
                            Text("Portfolio")
                                .font(.title)
                                .padding(.vertical, 8)
                            

                            
                        }
                        Spacer()
                            
                    }
                    HStack {
                        VStack(alignment: .leading){
                            Text("You have 0 shares of \(self.stockTicker)")
                            Text("Start trading!")
                        }
                        Spacer()
                            
                        Button(action: {
                            self.showingTradeSheet.toggle()
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 25)
                                    .frame(width: 130, height: 50, alignment: .center)
                                    .foregroundColor(.green)
                                Text("Trade")
                                    .bold()
                                    .foregroundColor(.white)
                            }
                        }
                        .sheet(isPresented: $showingTradeSheet) {
                            TradeView(self.listVM, self.detailVM, stockTicker, stockName)
                        }
                        
                    }
                    
                    .padding(.vertical,  10)
                }
                

                //stats
                VStack (alignment: .leading) {
                    
                    HStack{
                        
                        VStack (alignment:.leading, spacing: 0) {
                            Text("Stats")
                                .font(.title)
                                .padding(.vertical, 8)
                            ScrollView(.horizontal) {
                                LazyHGrid(rows: threeColumnGrid) {
                                    
                                    Text("Current Price: " + self.detailVM.getLast())
                                        .font(.body)
                                    
                                    
                                    
                                    Text("Open Price: " + self.detailVM.getOpen())
                                        .font(.body)
                                        .multilineTextAlignment(.leading)
                                        .padding(.leading, -18.0)
                                    
                                    
                                    Text("Low: " + self.detailVM.getLow())
                                        .font(.body)
                                    
                                    Text("Mid: " + self.detailVM.getMid())
                                        .font(.body)
                                        .padding(.leading, -18.0)
                                    
                                    Text("Bid Price: " + self.detailVM.getBidPrice())
                                        .font(.body)
                                }
                                
                                
                            }
//                            .frame(maxHeight:100)
                            
                        }
//                        .padding(.horizontal, 10)
                        
                        Spacer()
                    }
                }
                
                //about
                VStack (alignment: .leading) {
                    
                    HStack{
                        
                        VStack (alignment:.leading, spacing: 0) {
                            Text("About")
                                .font(.title)
                                .padding(.vertical, 8)
                            
                            Text(detailVM.stockAboutInfo)
                                .lineLimit(aboutExpand ? nil:/*@START_MENU_TOKEN@*/2/*@END_MENU_TOKEN@*/)
                            
                            
                            if(!aboutExpand){
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        withAnimation {
                                            self.aboutExpand.toggle()
                                        }
                                        
                                    }) {
                                        Text("Show more...")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            
                            if(aboutExpand) {
                                HStack {
                                    Spacer()
                                    Button(action: {self.aboutExpand.toggle()}) {
                                        withAnimation {
                                            Text("Show less...")
                                        }
                                        .foregroundColor(.gray)
                                    }
                                }
                            }
                            
                            
                        }
//                        .padding(.horizontal, 10)
                        
                        Spacer()
                    }
                }
                
                
                //News
                //first news
                NewsView(self.detailVM)
                Spacer()
                
                
            }
        }
        .padding(.horizontal, 10)
        .navigationBarTitle(Text(self.stockTicker), displayMode: .inline)
        
    }
}

struct Detail_Previews: PreviewProvider {
    static var previews: some View {
        return DetailStockView("TSLA", "Tesla", StockListViewModel())
    }
    
}
