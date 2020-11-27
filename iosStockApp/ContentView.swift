//
//  ContentView.swift
//  iosStockApp
//
//  Created by Fangbo Xu on 11/24/20.
//

import SwiftUI



struct ContentView: View {
    @ObservedObject private var stockListVM = StockListViewModel()
    
    let timer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()
    
    init() {
        stockListVM.load()
        print(stockListVM.stocks)
        print("init")
    }
    
    var body: some View {
//        let showStocks = self.stockListVM.stocks
        NavigationView{
//            StockListView(stocks: showStocks)
            StockListView(listVM: self.stockListVM)
                .onReceive(timer) { input in
                    stockListVM.refresh()
                }
            
            .navigationTitle("Stock")
            .navigationBarItems(trailing: EditButton())
        }
        
    }
    
  
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
