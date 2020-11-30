//
//  SearchView.swift
//  iosStockApp
//
//  Created by Fangbo Xu on 11/27/20.
//

import Foundation
import SwiftUI

struct SearchView: View
{
    
    var planets =
        ["Mercury", "Venus", "Earth", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune"] +
        ["Ceres", "Pluto", "Haumea", "Makemake", "Eris"]
    
    @ObservedObject var searchBar: SearchBar = SearchBar()
    
    var body: some View {
        NavigationView {
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
                .navigationBarTitle("Planets")
                .add(self.searchBar)
        }
    }
}

struct Search_Previews: PreviewProvider {
    static var previews: some View {
        return SearchView()
    }
    
}
