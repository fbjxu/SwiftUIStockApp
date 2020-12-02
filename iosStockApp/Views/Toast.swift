//
//  Toast.swift
//  iosStockApp
//
//  Created by Fangbo Xu on 12/2/20.
//

import Foundation
import SwiftUI

struct Toast<Presenting>: View where Presenting: View {

    /// The binding that decides the appropriate drawing in the body.
    @Binding var isShowing: Bool
    /// The view that will be "presenting" this toast
    let presenting: () -> Presenting
    /// The text to show
    let text: Text

    var body: some View {

        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                
                self.presenting()
//                    .blur(radius: self.isShowing ? 1 : 0)

                VStack {
                    self.text
                        .foregroundColor(.white)
                        .font(.title3)
                }
                .frame(width: geometry.size.width - 80,
                       height: geometry.size.height / 14)
                
                .background(Color.gray)
                .foregroundColor(Color.primary)
                .cornerRadius(30)
                .transition(.slide)
                .opacity(self.isShowing ? 1 : 0)
//                .onAppear {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                      withAnimation {
//                        self.isShowing = false
//                      }
//                    }
//                }

            }

        }

    }

}


extension View {

    func toast(isShowing: Binding<Bool>, text: Text) -> some View {
        Toast(isShowing: isShowing,
              presenting: { self },
              text: text)
    }

}

struct exampleView: View {

    @State var showToast: Bool = false

    var body: some View {
        NavigationView {
            List(0..<100) { item in
                Text("\(item)")
            }
            .navigationBarTitle(Text("A List"), displayMode: .large)
            .navigationBarItems(trailing: Button(action: {
                withAnimation {
                    self.showToast.toggle()
                }
            }){
                Text("Toggle toast")
            })
        }
        .toast(isShowing: $showToast, text: Text("Hello toast!"))
    }

}


struct toast_Previews: PreviewProvider {
    static var previews: some View {
        return exampleView()
    }
    
}
