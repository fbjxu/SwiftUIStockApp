//
//  StockListView.swift
//  iosStockApp
//
//  Created by Fangbo Xu on 11/25/20.
//

import Foundation

import SwiftUI

struct StockListView: View {
    
    //    let stocks: [StockViewModel]
    @ObservedObject var listVM: StockListViewModel
    //used for input field
    @State private var newStock = ""
    
    var body: some View {
        List {
            Section(header: Text("Input Stock")) {
                HStack{
                    TextField("New Item", text: self.$newStock)
                    Button(action: {
                        //update StockListVM
                        Storageservice().addWatchlistItem(self.newStock, self.listVM)
                        //reset input
                        self.newStock=""
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                            .imageScale(.large)
                    }
                }
            }
            Section(header: Text("PORTFOLIO")) {
                ForEach(self.listVM.portfolioItems, id: \.ticker) { stock in
                    PortfolioCellView(stock: stock)
                }
            }
            
            Section(header: Text("FAVORITES")) {
                ForEach(self.listVM.stocks, id: \.ticker) { stock in
                    StockCellView(stock: stock)
                }
//                .onDelete(perform: removeItems)
                .onDelete{ indexSet in
                    let deleteItem = self.listVM.stocks[indexSet.first!]
                    Storageservice().removeWatchlistItem(deleteItem.ticker, self.listVM)
                    listVM.stocks.remove(atOffsets: indexSet)
                }
            }
            Link("Powered by Tiingo", destination: URL(string: "https://www.tiingo.com")!)
                .font(.body)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .center)

        }
        .listStyle(PlainListStyle()) //used to get rid of padding
        
        
        
        
    }
//
//    func removeItems(at offsets: IndexSet) {
//        listVM.stocks.remove(atOffsets: offsets)
//    }
}



struct StockCellView: View {
    
    let stock: StockViewModel
    
    var body: some View {
        
        return HStack {
            
            VStack(alignment: .leading) {
                Text(stock.ticker)
                    .font(.custom("Arial",size: 22))
                    .fontWeight(.bold)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                
            }
            
            Spacer()
            
            VStack {
                Text("\(stock.price)")
                    .font(.custom("Arial",size: 22))
                
                Text(stock.change)
                    .padding(5)
                    .foregroundColor(Color.green)
            }
            
        }
        
    }
    
}

struct PortfolioCellView: View {
    
    let stock: StockViewModel
    
    var body: some View {
        
        return HStack {
            
            VStack(alignment: .leading) {
                Text(stock.ticker)
                    .font(.custom("Arial",size: 22))
                    .fontWeight(.bold)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                
                Text(stock.numShares)
                    .padding(5)
                    .foregroundColor(.gray)
                
            }
            
            Spacer()
            
            VStack {
                Text("\(stock.price)")
                    .font(.custom("Arial",size: 22))
                
                Text(stock.change)
                    .padding(5)
                    .foregroundColor(Color.green)
            }
            
        }
        
    }
    
}




struct StockListView_Previews: PreviewProvider {
    static var previews: some View {
        
        let previewListVM = StockListViewModel()
        previewListVM.load()
        return StockListView(listVM: previewListVM)
    }
}

struct portfolioCell_Previews: PreviewProvider {
    static var previews: some View {
        let stockVM = StockViewModel(Stock("AAPL"))
        return PortfolioCellView(stock: stockVM)
    }
}
