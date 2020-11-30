//
//  TradeView.swift
//  iosStockApp
//
//  Created by Fangbo Xu on 11/30/20.
//

import Foundation
import SwiftUI



struct TradeView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var numShares = ""
    
    var body: some View {
        NavigationView{
            VStack{
                Text("Trade XXX shares")
                    .font(.title3)
                    .bold()
                    .offset(y:-50)

                HStack{
                    TextField("0", text: self.$numShares)
                        .font(.system(size: 120))
                        .keyboardType(.numberPad)
                    Spacer()
                    Text("Share")
                        .font(.system(size: 30))
                        .offset(y:40)
                    
               
                }
                HStack {
                    Spacer()
                    Text("x $100/share = $4000")
                        .font(.body)
                }
                Spacer()
                Text("$3000 available to buy XXX")
                    .font(.body)
                    .foregroundColor(.gray)
                HStack{
                    
                }
                
            }
            .navigationBarItems(leading: Button(action:{
                self.presentationMode.wrappedValue.dismiss()
            }){Image(systemName: "xmark")
                                    .foregroundColor(.black)
                                    .imageScale(.large)})

        }
        .padding(.horizontal, 10)
        
    }
}


struct Trade_Previews: PreviewProvider {
    static var previews: some View {
        return TradeView()
    }
    
}
