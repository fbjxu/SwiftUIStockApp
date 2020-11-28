//
//  SearchbarViewModel.swift
//  iosStockApp
//
//  Created by Fangbo Xu on 11/28/20.
//

import Foundation


class SearchBarViewModel: ObservableObject {
    @Published public var suggestedStocks: [SearchBarItem] = [SearchBarItem]()
 
    func refreshList(_ keyword: String) {
        Webservice().grabAutocompletes(keyword ,self)
        print(self.suggestedStocks)
    }
    
    
}
