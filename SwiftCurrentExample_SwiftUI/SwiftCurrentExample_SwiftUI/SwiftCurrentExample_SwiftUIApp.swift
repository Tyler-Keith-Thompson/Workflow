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
    @State var presentingWorkflowView = false
    var body: some Scene {
        WindowGroup {
            Text("I'm running, you're broken")
            WorkflowView(isPresented: $presentingWorkflowView.animation(.spring()), args: "String in")
                .thenProceed(with: WorkflowItem(FirstView.self)
                                .applyModifiers {
                                    if true {
                                        $0.background(Color.gray)
                                            .transition(.slide)
                                            .animation(.spring())
                                    }
                                }
                )
                .thenProceed(with: WorkflowItem(ThirdView.self)
                                .applyModifiers {
                                    if true {
                                        $0.background(Color.gray)
                                            .transition(.slide)
                                            .animation(.spring())
                                    }
                                }
                )
                .thenProceed(with: WorkflowItem(FirstView.self)
                                .applyModifiers {
                                    if true {
                                        $0.background(Color.gray)
                                            .transition(.slide)
                                            .animation(.spring())
                                    }
                                }
                )
                .thenProceed(with: WorkflowItem(SecondView.self)
                                .launchStyle(.default)
                                .presentationType(.default)
                                .persistence(.removedAfterProceeding)
                                .applyModifiers {
                                    if true {
                                        $0.padding(10)
                                            .background(Color.purple)
                                            .transition(.slide)
                                            .animation(.spring())
                                    }
                                }
                )
                .launchStyle(.default) // launch style of WorkflowView, could be moved to the top, depends on consumer
                .onAbandon {
                    print("PresentingWorkflowView: \($presentingWorkflowView)")
                }
                .onFinish { args in
                    print("Finished 1: \(args)")
                }
                .onFinish { args in
                    print("Finished 2: \(args)")
                }
            NotWorkflowView(isPresented: $presentingWorkflowView)
        }
    }
}

struct NotWorkflowView: View {
    @Binding var isPresented: Bool
    @StateObject private var model = NotWorkflowViewModel()
    var body: some View {
        if isPresented {
            model.body
            Button("update Body of model") { model.updateBody() }
        } else {
            Button("Toggle") { isPresented.toggle() }
        }
    }

    private class NotWorkflowViewModel: ObservableObject {
        @Published var body = AnyView(EmptyView())

        var counter = 0
        func updateBody() {
            counter += 1
            body = AnyView(Text("Updated the body: \(counter)"))
        }
    }
}
