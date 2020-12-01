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
    @ObservedObject var searchBar: SearchBar
    @ObservedObject private var searchBarVM: SearchBarViewModel
    @State private var newStock = ""
    
    let timer = Timer.publish(every: 15, on: .main, in: .common).autoconnect() //for refreshing stock prices

    
    init() {
        self.listVM = StockListViewModel()
        self.searchBar = SearchBar()
        self.searchBarVM = SearchBarViewModel()
        self.listVM.load()
        self.searchBar.searchBarVM = searchBarVM
    }
    
    var body: some View {
        NavigationView{
            List {
                //search
                ForEach(
                    self.searchBarVM.suggestedStocks, id:\.ticker
                ) { eachSuggestion in
                    NavigationLink(destination: NavigationLazyView(DetailStockView(eachSuggestion.ticker.uppercased(), eachSuggestion.name, self.listVM))) {
                        VStack(alignment: .leading) {
                            Text(eachSuggestion.ticker.uppercased())
                                .bold()
                            Text(eachSuggestion.name)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                //stock
                if(self.searchBar.text.isEmpty) {
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
                            HStack {
                                
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
                    
                    Section(header: Text("FAVORITES")) {
                        
                        ForEach(self.listVM.stocks, id: \.ticker) { stock in
//                            StockCellView(stock:stock)
                            HStack {

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

                                    Text("\(stock.change)")
                                        .padding(5)
                                        .foregroundColor(Color.green)
                                }

                            }
                        }
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
                
                
            }
            .add(self.searchBar)
            .listStyle(PlainListStyle()) //used to get rid of padding
            .navigationTitle("Stock")
            .navigationBarItems(trailing: EditButton())
        }
        .onReceive(timer) { input in
            print("activate timer")
            Webservice().refreshPriceSummary(self.listVM)
        }
        .onDisappear {
            print("stop timer")
        }
    }
    

}



struct StockCellView: View {
    
    var stock: StockViewModel
    
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
    
    @State var stock: StockViewModel
    
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
        return StockListView()
    }
}

struct portfolioCell_Previews: PreviewProvider {
    static var previews: some View {
        let stockVM = StockViewModel(Stock("AAPL"))
        return PortfolioCellView(stock: stockVM)
    }
}
