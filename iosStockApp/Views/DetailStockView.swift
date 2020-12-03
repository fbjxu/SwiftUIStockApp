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
    var timer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()
    
    var stockTicker: String = ""
    var stockName: String = ""
    private var webService = Webservice()
    private var stockSummary:Stock
    let rows = [//for stats horizontal scroll view
        GridItem(.flexible(), alignment: .leading),
        GridItem(.flexible(), alignment: .leading)
    ]
    private var threeColumnGrid = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
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
        if (!self.detailVM.detailLoaded){
            ProgressView("Fetching Data...")
        }
        else {
            
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
                                    .foregroundColor((self.detailVM.stockPriceSummaryInfo.change>=0.0) ? .green : .red)
                                
                            }
                            
                        }
                        .padding(.bottom, 20)
                        
                        Spacer()
                    }
                    //Chart
                    ChartView(stockTicker: self.stockTicker.uppercased())
                        .frame(minWidth: 100, minHeight: 440)
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
                            if(Storageservice().getNumShares(self.stockTicker)==0){
                                VStack(alignment: .leading){
                                    Text("You have 0 shares of \(self.stockTicker)")
                                    Text("Start trading!")
                                }
                            } else {
                                VStack(alignment: .leading){
                                    Text("Shares owned: \(String(format: "%.4f",Storageservice().getNumShares(self.stockTicker)))")
                                    Text(" ")
                                    Text("Market Value: $\(String(format: "%.2f",Storageservice().getNumShares(self.stockTicker) * self.detailVM.stockPriceSummaryInfo.last))")
                                }
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
                        
                        .padding(.vertical,  5)
                    }
                    .offset(y:-10)
                    
                    
                    //stats
                    VStack (alignment: .leading) {
                        
                        HStack{
                            
                            VStack (alignment:.leading, spacing: 0) {
                                Text("Stats")
                                    .font(.title)
                                    .padding(.vertical, 8)
                                ScrollView(.horizontal) {
                                    LazyHGrid(rows: threeColumnGrid, alignment: .bottom) {
                                        
                                        HStack{
                                            Text("Current Price: " + self.detailVM.getLast())
                                                .font(.body)
                                            Spacer()
                                                .frame(width: 30)
                                        }
   
                                        HStack{
                                            Text("Open Price: " + self.detailVM.getOpen())
                                                .font(.body)
                                                .multilineTextAlignment(.leading)
                                            Spacer()
                                            
                                        }
                                        
                                            
                                        HStack{
                                            Text("High: " + self.detailVM.getHigh())
                                                .font(.body)
                                            Spacer()
                                        }
                                        
                                        HStack{
                                            Text("Low: " + self.detailVM.getLow())
                                                .font(.body)
                                            Spacer()
                                        }
                                        
                                        HStack{
                                            Text("Mid: " + self.detailVM.getMid())
                                                .font(.body)
                                            Spacer()
                                        }
                                        HStack{
                                            Text("Volume: " + self.detailVM.getVolume())
                                                .font(.body)
                                            Spacer()
                                        }
                                        HStack{
                                            Text("Bid Price: " + self.detailVM.getBidPrice())
                                                .font(.body)
                                            Spacer()
                                        }
                                    }
                                    
                                    
                                }
                                .frame(minHeight:75)
                                
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
            .navigationBarItems(trailing: self.detailVM.favored ?
                                        Button(action: {
                    //stock favored
                                            self.detailVM.favored = false
                                            Storageservice().removeWatchlistItem(self.stockTicker, self.listVM)
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                        .imageScale(.large)
                                        } :
                                        Button(action: {
                    //stock not favored
                                            self.detailVM.favored = true
                                            Storageservice().addWatchlistItem(self.stockTicker, self.listVM)
                }) {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.blue)
                        .imageScale(.large)
                }
            )
            .onReceive(timer) { input in
                print("refreshed detail page")
                Webservice().refreshSinglePriceSummary(self.detailVM)
            }
            .onDisappear() {
                print("cancel timer")
                self.timer.upstream.connect().cancel()
                
            }
            
        }
        
    }
}

struct Detail_Previews: PreviewProvider {
    static var previews: some View {
        return DetailStockView("F", "Ford", StockListViewModel())
    }
    
}
