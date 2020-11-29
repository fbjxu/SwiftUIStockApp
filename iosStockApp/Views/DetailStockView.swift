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
                
                ForEach(self.detailVM.stockNews, id:\.id) { newsItem in
                    if (newsItem.id == 1) {
                        Button(action: {UIApplication.shared.open(URL(string: newsItem.url)!)}
                        ) {
                            VStack {
                                HStack {
                                    Text("News")
                                        .font(.title)
                                        .padding(.vertical, 8)
                                        .foregroundColor(.black)
                                    Spacer()
                                }
                                
                                KFImage(URL(string: newsItem.urlToImage)!)
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(15)
                                
                                HStack {
                                    Text(newsItem.source)
                                        .bold()
                                        .foregroundColor(.gray)
                                    Text(newsItem.publishedAt)
                                        .foregroundColor(.gray)
                                    Spacer()
                                }
                                Text(newsItem.title)
                                    .bold()
                                    .font(.title2)
                                    .foregroundColor(.black)
                            }
        //                    .padding(.horizontal, 10)
                        }
                        .contextMenu {
                            Button(action: {
                            // Action will goes here
                            }) {
                                Label("Open in Safari", systemImage: "safari")
                         
                            }
                            
                            Button(action: {
                            // Action will goes here
                            }) {
                                
                                Label("Share on Twitter", systemImage: "square.and.arrow.up")
                            }
                        }
                    }
                    else {
                        Button(action: {
                            UIApplication.shared.open(URL(string: newsItem.url)!)
                        }) {
                            HStack {
                                VStack {
                                    HStack{
                                        Text(newsItem.source)
                                            .bold()
                                            .foregroundColor(.gray)
                                        Text(newsItem.publishedAt)
                                            .foregroundColor(.gray)
                                        Spacer()
                                    }
                                    HStack {
                                        Text(newsItem.title)
                                            .foregroundColor(.black)
                                            .bold()
                                            .font(.title3)
                                            .lineLimit(3)
                                        Spacer()
                                    }
                                    
                                }
                                KFImage(URL(string: newsItem.urlToImage)!)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 90, height: 90)
                                    .clipped()
                                    .cornerRadius(10)
                                    
                            }
                        }
                        .contextMenu {
                            Button(action: {
                            // Action will goes here
                            }) {
                                Label("Open in Safari", systemImage: "safari")
                         
                            }
                            
                            Button(action: {
                            // Action will goes here
                            }) {
                                
                                Label("Share on Twitter", systemImage: "square.and.arrow.up")
                            }
                        }
                    }
                }
                
                
//                Button(action: {
//                    UIApplication.shared.open(URL(string: detailVM.stockNews[0].url)!)
//                }) {
//                    VStack {
//                        HStack {
//                            Text("News")
//                                .font(.title)
//                                .padding(.vertical, 8)
//                                .foregroundColor(.black)
//                            Spacer()
//                        }
//
//                        KFImage(URL(string: detailVM.stockNews[0].urlToImage)!)
//                            .resizable()
//                            .scaledToFit()
//                            .cornerRadius(15)
//
//                        HStack {
//                            Text(detailVM.stockNews[0].source)
//                                .bold()
//                                .foregroundColor(.gray)
//                            Text(detailVM.stockNews[0].publishedAt)
//                                .foregroundColor(.gray)
//                            Spacer()
//                        }
//                        Text(detailVM.stockNews[0].title)
//                            .bold()
//                            .font(.title2)
//                            .foregroundColor(.black)
//                    }
////                    .padding(.horizontal, 10)
//                }
//                .contextMenu {
//                    Button(action: {
//                    // Action will goes here
//                    }) {
//                        Label("Open in Safari", systemImage: "safari")
//
//                    }
//
//                    Button(action: {
//                    // Action will goes here
//                    }) {
//
//                        Label("Share on Twitter", systemImage: "square.and.arrow.up")
//                    }
//                }
//
//
//                Divider()
//                Button(action: {
//                    UIApplication.shared.open(URL(string: "https://www.google.com")!)
//                }) {
//                    HStack {
//                        VStack {
//                            HStack{
//                                Text("Business Insider")
//                                    .bold()
//                                    .foregroundColor(.gray)
//                                Text("6 Days Ago")
//                                    .foregroundColor(.gray)
//                                Spacer()
//                            }
//                            HStack {
//                                Text("Here is some title that will show up so people can read haha")
//                                    .foregroundColor(.black)
//                                    .bold()
//                                    .font(.title3)
//                                    .lineLimit(3)
//                                Spacer()
//                            }
//
//                        }
//                        KFImage(URL(string: "https://i.insider.com/5f9c2b106f5b3100117246dc?width=1200&format=jpeg")!)
//                            .resizable()
//                            .scaledToFill()
//                            .frame(width: 90, height: 90)
//                            .clipped()
//                            .cornerRadius(10)
//
//                    }
//                }
//                .contextMenu {
//                    Button(action: {
//                    // Action will goes here
//                    }) {
//                        Label("Open in Safari", systemImage: "safari")
//
//                    }
//
//                    Button(action: {
//                    // Action will goes here
//                    }) {
//
//                        Label("Share on Twitter", systemImage: "square.and.arrow.up")
//                    }
//                }
//                .padding(.horizontal, 10)
                
                
                Spacer()
                
                
            }
        }
        .padding(.horizontal, 10)
        .navigationBarTitle(Text(self.stockTicker), displayMode: .inline)
        
    }
}

struct Detail_Previews: PreviewProvider {
    static var previews: some View {
        return DetailStockView("TSLA", "Tesla")
    }
    
}
