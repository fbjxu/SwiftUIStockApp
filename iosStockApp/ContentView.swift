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
    @State var isViewDisplayed = false
    
    var body: some View {
        if(!isViewDisplayed) {
            ProgressView("Fetching Data...")
        }
        
        StockListView()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}
