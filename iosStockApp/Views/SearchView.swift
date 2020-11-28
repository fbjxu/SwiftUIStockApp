//
//  SearchView.swift
//  iosStockApp
//
//  Created by Fangbo Xu on 11/27/20.
//

import Foundation
import SwiftUI

struct SearchView: View {
    var planets = ["Mercury", "Venus", "Earth", "Mars"]
    @ObservedObject var searchBar = SearchBar()
    
    var body: some View {
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
        
    }
}

struct Search_Previews: PreviewProvider {
    static var previews: some View {
        return SearchView()
    }
    
}
