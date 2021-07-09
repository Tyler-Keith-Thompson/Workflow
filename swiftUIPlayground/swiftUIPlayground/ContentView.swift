//
//  ContentView.swift
//  swiftUIPlayground
//
//  Created by Richard Gist on 7/9/21.
//

import SwiftUI
import Foundation

struct ContentView: View {
    @State var counter = 0
    @State var show = false
    var body: some View {
        VStack {
            Text("Hello, world!")
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
                .background(Color.red)
            if true {
                model.view
//                    .frame(maxWidth: .infinity, alignment: .center)
//                    .transition(.slide)
//                    .animation(.spring())
            }
            if show {
                Text("Updated value: \(counter)")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .transition(.slide)
                    .animation(.none)
            }
            Button("UpdateView") {
                switch counter % 10 {
                    case 2: model.view = AnyView(Image(systemName: "heart"))
                    case 3: model.view = AnyView(getFR1())
                    case 4: model.view = AnyView(getFR2())
                    default: model.view = AnyView(Text("Update \(counter)"))
                }
            }
            Button("Update counter") {
                withAnimation {
                    counter += 1
                }
            }
            Button("Toggle views") {
                withAnimation {
                    show.toggle()
                }
            }
        }
    }

    @ViewBuilder func getFR1() -> some View {
        if true {
            FR1()
                .frame(maxWidth: .infinity, alignment: .center)
                .transition(.slide)
                .animation(.spring())
        }
    }
    @ViewBuilder func getFR2() -> some View {
        if true {
            FR2()
                .frame(maxWidth: .infinity, alignment: .center)
                .transition(.slide)
                .animation(.spring())
        }
    }

    @ObservedObject var model = Model()
    class Model: ObservableObject {
        @Published var view = AnyView(EmptyView())
    }
}

struct FR1: View {
    var body: some View {
        Text("This is FR1")
    }
}
struct FR2: View {
    var body: some View {
        Text("This is FR2")
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
