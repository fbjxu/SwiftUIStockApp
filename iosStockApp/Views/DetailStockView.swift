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
    
    
    init(_ stockTicker:String, _ stockName:String) {
        self.stockTicker = stockTicker
        self.stockName = stockName
        self.stockSummary = Stock(stockTicker)
        //grab stock details
        detailVM.getPriceSummary(stockTicker)
        
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
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
                .padding(.horizontal, 10)
                
                Spacer()
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
                        .frame(maxHeight:75)
                        
                    }
                    .padding(.horizontal, 10)
                    
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
                            .transition(.slide)
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
                    .padding(.horizontal, 10)
                    
                    Spacer()
                }
            }
            //News
            VStack {
                HStack {
                    Text("About")
                        .font(.title)
                        .padding(.vertical, 8)
                    Spacer()
                }
                
                KFImage(URL(string: "https://i.insider.com/5f9c2b106f5b3100117246dc?width=1200&format=jpeg")!)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(15)
                
                HStack {
                    Text("Business Insider")
                        .bold()
                        .foregroundColor(.gray)
                    Text("6 Days Ago")
                        .foregroundColor(.gray)
                    Spacer()
                }
                Text("Here is some title that will show up so people can read haha")
                    .bold()
                    .font(.title2)
            }
            .padding(.horizontal, 10)
            
            Divider()
            
            HStack {
                VStack {
                    HStack{
                        Text("Business Insider")
                            .bold()
                            .foregroundColor(.gray)
                        Text("6 Days Ago")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    HStack {
                        Text("Here is some title that will show up so people can read haha")
                            .bold()
                            .font(.title3)
                            .lineLimit(3)
                        Spacer()
                    }
                    
                }
                KFImage(URL(string: "https://i.insider.com/5f9c2b106f5b3100117246dc?width=1200&format=jpeg")!)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 90, height: 90)
                    .clipped()
                    .cornerRadius(10)
            }
            .padding(.horizontal, 10)
            
            
            Spacer()
            
            
        }
        .navigationBarTitle(Text(self.stockTicker), displayMode: .inline)
        
    }
}

struct Detail_Previews: PreviewProvider {
    static var previews: some View {
        return DetailStockView("TSLA", "Tesla")
    }
    
}
