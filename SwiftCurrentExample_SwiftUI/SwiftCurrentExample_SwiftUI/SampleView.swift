//
//  SampleView.swift
//  SwiftCurrentExample_SwiftUI
//
//  Created by Wiemer on 6/23/21.
//

import SwiftUI
import SwiftCurrent

struct FirstView: View, FlowRepresentable {
    var _workflowPointer: AnyFlowRepresentable?

    typealias WorkflowInput = String
    typealias WorkflowOutput = String

    private let name: String
    @State private var email = ""

    public init(with name: String) {
        self.name = name
    }

    var body: some View {
        VStack {
            Text("Welcome, \(name)!")
            TextField("Enter email", text: $email)
                .multilineTextAlignment(.center)
            Button("Move Forward") {
                proceedInWorkflow(email)
            }
            .background(email.contains("@wwt.com") ? Color.green : Color.red)
            .padding()
        }
    }
}

struct SecondView: View, FlowRepresentable {
    var _workflowPointer: AnyFlowRepresentable?

    typealias WorkflowInput = String

    private let email: String

    init(with email: String) {
        self.email = email
    }

    var body: some View {
        VStack {
            Text("That lone wolf stuff stays behind")
                .background(Color.blue)
            Button("Confirm") {
                workflow?.abandon()
            }
            .background(Color.gray)
            .padding()
        }.background(Color.red)
    }

    func shouldLoad() -> Bool {
        email.lowercased() == "lonewolf@wwt.com"
    }
}
