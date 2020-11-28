//
//  ContentView.swift
//  iosStockApp
//
//  Created by Fangbo Xu on 11/24/20.
//

import SwiftUI



struct ContentView: View {
    @ObservedObject private var stockListVM = StockListViewModel()
    @State var isShowingList = true
    
    var planets = ["Mercury", "Venus", "Earth", "Mars"]
    @ObservedObject var searchBar = SearchBar()
    
    let timer = Timer.publish(every: 15, on: .main, in: .common).autoconnect() //for refreshing stock prices
    
    init() {
        stockListVM.load()
        print(stockListVM.stocks)
        print("init")
    }
    
    var body: some View {
        NavigationView{
            VStack(alignment: .leading, spacing: 0) {
                //search part
                List {
                    ForEach(
                        planets.filter {
                            searchBar.text.isEmpty ||
                                $0.localizedStandardContains(searchBar.text)
                        },
                        id: \.self
                    ) { eachPlanet in
                        Text(eachPlanet)
                    }
                }
                .listStyle(PlainListStyle()) //used to get rid of padding
                .add(self.searchBar)
                .navigationTitle("Stock")
                .navigationBarItems(trailing: EditButton())
                
                //stock list part
                if(self.searchBar.text.isEmpty){
                    StockListView(listVM: self.stockListVM)
                        .onReceive(timer) { input in
                            stockListVM.refresh()
                        }
                }
                
                
                
                
            }
            
        }
        
        
    }
    
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
            ContentView()
            ContentView()
        }
    }
}
