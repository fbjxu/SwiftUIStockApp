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
    
    var today: String = ""
    var timer = Timer.publish(every: 15, on: .main, in: .common).autoconnect() //for refreshing stock prices
    
    
    init() {
        self.listVM = StockListViewModel()
        self.searchBar = SearchBar()
        self.searchBarVM = SearchBarViewModel()
        self.listVM.load()
        self.searchBar.searchBarVM = searchBarVM
        let today = Date()
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "MMM d y"
        self.today = formatter1.string(from: today)
    }
    
    var body: some View {
        
        if(!self.listVM.loaded) {
            ProgressView("Fetching Data...")
        }
        else{
            NavigationView{
                List {
                    //search
                    if(!self.searchBar.text.isEmpty) {
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
                    }
                    
                    
                    //Date
                    if(self.searchBar.text.isEmpty) {
                        VStack (alignment: .leading) {
                            Text("\(self.today)")
                                .font(.custom("Arial", size: 32))
                                .fontWeight(.bold)
                                .foregroundColor(Color.gray)
                        }
                        /******************TEST ONLY*********/
//                        Section(header: Text("Input Stock")) {
//                            HStack{
//                                TextField("New Item", text: self.$newStock)
//                                Button(action: {
//                                    //update StockListVM
//                                    Storageservice().addWatchlistItem(self.newStock, self.listVM)
//                                    //reset input
//                                    self.newStock=""
//                                }) {
//                                    Image(systemName: "plus.circle.fill")
//                                        .foregroundColor(.green)
//                                        .imageScale(.large)
//                                }
//                            }
//                        }
                        Section(header: Text("PORTFOLIO")) {
                            VStack{
                                Text("Net Worth")
                                    .font(.title)
                                Text("\(String(format: "%.2f", self.listVM.networth))")
                                    .font(.title)
                                    .bold()
                            }
                            ForEach(self.listVM.portfolioItems, id: \.ticker) { stock in
                                NavigationLink(destination: NavigationLazyView(DetailStockView(stock.ticker.uppercased(), stock.name, self.listVM))) {
                                    HStack {
                                        
                                        VStack(alignment: .leading) {
                                            Text(stock.ticker)
                                                .font(.custom("Arial",size: 22))
                                                .fontWeight(.bold)
                                            //                                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                            
                                            Text(stock.numShares)
                                                .foregroundColor(.gray)
                                            
                                        }
                                        
                                        Spacer()
                                        
                                        VStack(alignment: .trailing) {
                                            Text("\(stock.price)")
                                                .font(.custom("Arial",size: 22))
                                            
                                            if(stock.stock.change == 0 ) {
                                                
                                                Text("\(stock.change)")
                                                    
                                                    .foregroundColor(.gray)
                                            }
                                            else {
                                                HStack {
                                                    if(stock.stock.change>0) {
                                                        Image(systemName: "arrow.up.forward")
                                                    }
                                                    else {
                                                        Image(systemName: "arrow.up.forward")
                                                            .rotationEffect(.degrees(90))
                                                    }
                                                    Text("\(stock.change)")
                                                }
                                                
                                                .foregroundColor(stock.stock.change>=0 ? .green : .red)
                                            }
                                        }
                                        
                                    }
                                }
                                
                            }
                            .onMove{ (indexSet, index) in
                                listVM.portfolioItems.move(fromOffsets: indexSet, toOffset: index)
                            }
                        }
                        
                        Section(header: Text("FAVORITES")) {
                            
                            ForEach(self.listVM.stocks, id: \.ticker) { stock in
                                //                            StockCellView(stock:stock)
                                NavigationLink(destination: NavigationLazyView(DetailStockView(stock.ticker.uppercased(), stock.name, self.listVM))) {
                                    HStack {
                                        
                                        VStack(alignment: .leading) {
                                            Text(stock.ticker)
                                                .font(.custom("Arial",size: 22))
                                                .fontWeight(.bold)
                                            //                                    Text(stock.numShares)
                                            //                                        .foregroundColor(.gray)
                                            //                                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                                            if(stock.stock.numShares>0) {
                                                Text(stock.numShares)
                                                    .foregroundColor(.gray)
                                            } else {
                                                Text(stock.name)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        VStack(alignment: .trailing) {
                                            Text("\(stock.price)")
                                                .font(.custom("Arial",size: 22))
                                            
                                            if(stock.stock.change == 0 ) {
                                                
                                                Text("\(stock.change)")
                                                    
                                                    .foregroundColor(.gray)
                                            }
                                            else {
                                                HStack {
                                                    if(stock.stock.change>0) {
                                                        Image(systemName: "arrow.up.forward")
                                                    }
                                                    else {
                                                        Image(systemName: "arrow.up.forward")
                                                            .rotationEffect(.degrees(90))
                                                    }
                                                    Text("\(stock.change)")
                                                }
                                                
                                                .foregroundColor(stock.stock.change>=0 ? .green : .red)
                                            }
                                        }
                                        
                                    }
                                }
                                
                            }
                            .onDelete{ indexSet in
                                let deleteItem = self.listVM.stocks[indexSet.first!]
                                Storageservice().removeWatchlistItem(deleteItem.ticker, self.listVM)
//                                listVM.stocks.remove(atOffsets: indexSet)
                            }
                            .onMove{ (indexSet, index) in
                                listVM.stocks.move(fromOffsets: indexSet, toOffset: index)
                            }
                        }
                        Link("Powered by Tiingo", destination: URL(string: "https://www.tiingo.com")!)
                            .font(.footnote)
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
                if(!self.searchBar.text.isEmpty) {
                    print("do not update")
                    
                } else {
                    print("refresh list prices")
                    Webservice().refreshPriceSummary(self.listVM)
                }
                
            }
            
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
            
            VStack(alignment: .trailing) {
                Text("\(stock.price)")
                    .font(.custom("Arial",size: 22))
                
                if(stock.stock.change == 0 ) {
                    
                    Text("\(stock.change)")
                        
                        .foregroundColor(.gray)
                }
                else {
                    HStack {
                        if(stock.stock.change>0) {
                            Image(systemName: "arrow.up.forward")
                        }
                        else {
                            Image(systemName: "arrow.up.forward")
                                .rotationEffect(.degrees(90))
                        }
                        Text("\(stock.change)")
                    }
                    
                    .foregroundColor(stock.stock.change>=0 ? .green : .red)
                }
            }
            
        }
        
    }
    
}

struct PortfolioCellView: View {
    
    var stock: StockViewModel
    
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
            
            VStack(alignment: .trailing) {
                Text("\(stock.price)")
                    .font(.custom("Arial",size: 22))
                HStack{
                    Image(systemName: "line.diagonal.arrow")
                        .rotationEffect(.degrees(90))
                    Text(stock.change)
                        .padding(5)
                    
                }
                .foregroundColor(stock.stock.change>=0 ? .green : .red)
                
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


struct favCell_Previews: PreviewProvider {
    static var previews: some View {
        let stockVM = StockViewModel(Stock("AAPL"))
        stockVM.stock.change = -10
        return StockCellView(stock: stockVM)
    }
}
