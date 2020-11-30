//
//  ContentView.swift
//  iosStockApp
//
//  Created by Fangbo Xu on 11/24/20.
//

import SwiftUI

struct NavigationLazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}

struct ContentView: View {
    //    @ObservedObject private var stockListVM = StockListViewModel()
    //    @ObservedObject private var searchBarVM = SearchBarViewModel()
    //    @ObservedObject var searchBar = SearchBar()
    //    @State var isShowingList = true
    
    //    var planets = ["Mercury", "Venus", "Earth", "Mars"]
//    let timer = Timer.publish(every: 15, on: .main, in: .common).autoconnect() //for refreshing stock prices
    
    //    init() {
    //        stockListVM.load()
    //        searchBar.searchBarVM = self.searchBarVM
    //        print(stockListVM.stocks)
    //        print("init")
    //    }
    
    var body: some View {
        StockListView()
            .offset(y:-55)
    }
    
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}
