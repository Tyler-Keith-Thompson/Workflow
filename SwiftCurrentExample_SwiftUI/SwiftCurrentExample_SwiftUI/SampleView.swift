//
//  SampleView.swift
//  SwiftCurrentExample_SwiftUI
//
//  Created by Wiemer on 6/23/21.
//

import SwiftUI
import SwiftCurrent
import SwiftCurrent_SwiftUI

struct SampleView: View {
    @State var shiftLeading = false
    private let workflow = Workflow(FirstView.self)
        .thenProceed(with: SecondView.self)

    var body: some View {
        Text("")
    }
}

struct SampleView_Previews: PreviewProvider {
    static var previews: some View {
        SampleView()
    }
}

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
                // TODO: call proceed; pass in email
                proceedInWorkflow(email)
            }
            .background(email.contains("@wwt.com") ? Color.green : Color.red)
            .padding()
        }
    }
}

struct FirstView_Previews: PreviewProvider {
    static var previews: some View {
        FirstView(with: "Noble Six")
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
                // call abandon
                workflow?.abandon()
            }
            .background(Color.gray)
            .padding()
        }.background(Color.red)
    }

    func shouldLoad() -> Bool {
        return email.lowercased() == "lonewolf@wwt.com"
    }
}

struct SecondView_Previews: PreviewProvider {
    static var previews: some View {
        SecondView(with: "lonewolf@wwt.com")
    }
}
