//
//  SwiftCurrentExample_SwiftUIApp.swift
//  SwiftCurrentExample_SwiftUI
//
//  Created by Richard Gist on 6/21/21.
//

import Foundation
import SwiftUI
import SwiftCurrent

@main
struct SwiftCurrentExample_SwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
//            ContentView()
//            SampleView()
//            Tester()
            WorkflowItem(FirstView.self)
            WorkflowView(isPresented: .constant(true))
                .thenProceed(with: WorkflowItem(FirstView.self))
                .thenProceed(with: WorkflowItem(SecondView.self))
            WorkflowView(isPresented: .constant(true), args: "MY name is!")
                .thenProceed(with: WorkflowItem(FirstView.self))
                .thenProceed(with: WorkflowItem(SecondView.self))

            WorkflowView(isPresented: .constant(true))
                .thenProceed(with: WorkflowItem(FirstView.self))
                .thenProceed(with: WorkflowItem(SecondView.self)
                                .launchStyle(.default)
                                .presentationType(.default)
                                .persistence(.removedAfterProceeding)
                                .padding(10)
                                .transition(.opacity))
                .launchStyle(.default) // launch style of WorkflowView, could be moved to the top, depends on consumer
                .onAbandon {
                    print("abandoned")
                }
        }
    }
}

struct Tester: View {
    @State var show = false

    var body: some View {
        VStack {
            HStack {
                Text("Header Area")
            }
            HStack {
                VStack {
                    Text("Static Side Pane")
                    Button(show ? "Hide" : "Show") { show.toggle() }
                        .foregroundColor(Color.green)
                    Image(uiImage: .actions)
                }

                NavigationView {
                    NavigationLink(
                        destination: Text("FR1"),
                        isActive: $show,
                        label: {
                            Text("Launch button")
                        })
                }

//                TabView {
//                    Text("FR1")
////                        .tabItem {
////                            Text("Tabby")
////                        }
//                    Text("FR2")
////                        .tabItem {
////                            Text("Tabby2")
////                        }
//                }

//                Menu("Breakdown") {
//                    Text("FR1")
//                    Text("FR2")
//                }
                // Inspiration:
//                LazyVStack(alignment: .center, spacing: nil, pinnedViews: [], content: {
//                    ForEach(1...10, id: \.self) { count in
//                        Text("Placeholder \(count)")
//                    }
//                })

            }
            HStack {
                Text("Footer Area")
            }


        }.background(Color.blue)
    }
}

struct Tester_Previews: PreviewProvider {
    static var previews: some View {
        Tester()
//        WorkflowView {
//            WorkflowItem<SecondView>()
//                .padding()
//                .foregroundColor(.blue)
//                .transition(.slide)
//            WorkflowItem<FirstView>()
//        }

    }
}
