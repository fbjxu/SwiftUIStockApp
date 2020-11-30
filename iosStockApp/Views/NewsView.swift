//
//  NewsView.swift
//  iosStockApp
//
//  Created by Fangbo Xu on 11/29/20.
//

import Foundation
import SwiftUI
import KingfisherSwiftUI

struct NewsView: View {
    @ObservedObject var detailVM: DetailViewModel
    init(_ detailVM: DetailViewModel) {
        self.detailVM = detailVM
    }
    var body: some View {
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
                        HStack{
                            Text(newsItem.title)
                                .bold()
                                .font(.title2)
                                .foregroundColor(.black)
                            Spacer()
                        }
                        
                    }
                    .padding(.vertical, 6)
                }
                .contextMenu {
                    Button(action: {
                    // Action will goes here
                        UIApplication.shared.open(URL(string: newsItem.url)!)
                    }) {
                        Label("Open in Safari", systemImage: "safari")
                 
                    }
                    
                    Button(action: {
                    // Action will goes here
                        let twitterLink: String = "https://twitter.com/intent/tweet?text=Check%20out%20this%20link:%20\(newsItem.url)%20%23#CSCI571StockApp"
                        UIApplication.shared.open(URL(string: twitterLink)!)
                    }) {
                        
                        Label("Share on Twitter", systemImage: "square.and.arrow.up")
                    }
                }
                
                Divider()
                
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
                    .padding(.vertical, 6)
                    
                }
                .contextMenu {
                    Button(action: {
                    // Action will goes here
                        UIApplication.shared.open(URL(string: newsItem.url)!)
                    }) {
                        Label("Open in Safari", systemImage: "safari")
                 
                    }
                    
                    Button(action: {
                    // Action will goes here
                        UIApplication.shared.open(URL(string: "https://twitter.com/intent/tweet?text=Check%20out%20this%20link:%20\(newsItem.url)%20%23CSCI571StockApp")!)
                    }) {
                        
                        Label("Share on Twitter", systemImage: "square.and.arrow.up")
                    }
                }
            }
        }
    }
}

struct News_Previews: PreviewProvider {
    static var previews: some View {
        return NewsView(DetailViewModel())
    }
    
}

