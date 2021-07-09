import SwiftUI
print("Starting API Spike")
/*
 The style being implemented:
 WorkflowView(isPresented: $showWorkflow)
         .thenProceed(with: WorkflowItem(FR1.self))
         .thenProceed(with: WorkflowItem(FR2.self)
                               .launchStyle(.modal)
                               .presentationType(.navigationStack)
                               .persistence(.removedAfterProceeding)
                               .padding(10)
                               .transition(.fade))
         .thenProceed(with: WorkflowItem(FR3.self)
         .launchStyle(.modal) // launch style of WorkflowView, could be moved to the top, depends on consumer
         .onAbandon {
             showWorkflow = false
         }

 Erase everything to start, then after it is working, start getting everything back to types

 Start with the API and then get it to actually do it correctly
 */

//struct WorkflowView: View {
//    @Binding var isPresented: Bool
//    var body: some View { EmptyView() }
////    @State var anyWorkflow: AnyWorkflow?
//
//    func thenProceed<Content: View>(with wi: Content) -> Self { // This has some sort of type information at this point so that the user can be forced to do the right thing with adding the right type for Input/Output
//        if let proto = wi as? Metadata {
//            print("GUARD LET: Casted to Metadata: \(proto)")
//            print("And the base type is: \(proto.metadata.subjectType) which is lies because it really is an Any.Type")
//        } else {
//            print("FATAL ERROR: Failed to cast: \(wi)")
//        }
//
//        print("I can call type(of:) but does that help?: \(type(of: wi))")
//
//        return self
//    }
//
//    func onFinish(_ closure: (Any) -> Void) -> Self { self }// maybe adds to something on the VM
//    func onAbandon(_ closure: () -> Void) -> Self { self }// maybe adds to something on the VM [abandon1, abandon2](maybe)
//    func launchStyle(_ style: LaunchStyle) -> Self { self }
//}
//
//protocol Metadata {
//    var metadata: FlowRepresentableMetadata { get }
//}
//
//extension ModifiedContent: Metadata where Content: Metadata {
//    var metadata: FlowRepresentableMetadata { content.metadata }
//}
//
//struct WorkflowItem: View, Metadata {
//    var body: some View { EmptyView() }
//    var metadata: FlowRepresentableMetadata
//
//    init<FR: FlowRepresentable>(_: FR.Type) {
//        metadata = FlowRepresentableMetadata(FR.self)
//    }
//
//    func launchStyle(_ style: LaunchStyle) -> Self { self } // update metadata here
//    func presentationType(_ presentation: PresentationType) -> Self { self } // update metadata here
//    func persistence(_ persistence: Persistence) -> Self { self } // update metadata here
//}
//
//enum LaunchStyle {
//    case modal
//}
//enum PresentationType { case navigationStack }
//enum Persistence { case removedAfterProceeding }
//protocol FlowRepresentable {
//    associatedtype Input
//}
//class FlowRepresentableMetadata {
//    public let subjectType: Any.Type
//    init<FR: FlowRepresentable>(_ type: FR.Type) {
//        subjectType = FR.self
//    }
//}
//
//class Workflow<F: FlowRepresentable> {}
//class AnyWorkflow {
//    init<F: FlowRepresentable>(_ workflow: Workflow<F>) {}
//    func append(metadata: FlowRepresentableMetadata) { }
//}
//
//// MARK: EXAMPLE and TESTING
//struct FR1: FlowRepresentable { typealias Input = Never }
//struct FR2: FlowRepresentable { typealias Input = Never }
//struct FR3: FlowRepresentable { typealias Input = Never }
//struct TestView: View {
//    @State var showWorkflow = false
//    var body: some View {
//        // Testing View
//        WorkflowView(isPresented: $showWorkflow)
//            .launchStyle(.modal)
//            .thenProceed(with: WorkflowItem(FR1.self))
//            .thenProceed(with: WorkflowItem(FR1.self).launchStyle(.modal))
//            .thenProceed(with: WorkflowItem(FR1.self).padding())
//            .thenProceed(with: Text("This is not right"))
//            .onFinish { args in print("Completed with \(args)") }
//            .onAbandon { print("Abandoned") }
//            .padding()
//            .onAppear()
//
//        // Example View
//        WorkflowView(isPresented: $showWorkflow)
//                .thenProceed(with: WorkflowItem(FR1.self))
//                .thenProceed(with: WorkflowItem(FR2.self)
//                                      .launchStyle(.modal)
//                                      .presentationType(.navigationStack)
//                                      .persistence(.removedAfterProceeding)
//                                      .padding(10)
//                                      .transition(.opacity))
//                .thenProceed(with: WorkflowItem(FR3.self))
//                .launchStyle(.modal) // launch style of WorkflowView, could be moved to the top, depends on consumer
//                .onAbandon {
//                    showWorkflow = false
//                }
//    }
//}
//
//var wv = WorkflowView(isPresented: .constant(true))
//print("\(WorkflowItem(FR1.self))\n")
//print("\(wv.thenProceed(with: WorkflowItem(FR1.self)))\n")
//print("\(wv.thenProceed(with: WorkflowItem(FR1.self).padding()))\n")
//print("\(wv.thenProceed(with: WorkflowItem(FR1.self).accentColor(Color.blue).padding()))\n")
//print("\(wv.thenProceed(with: WorkflowItem(FR1.self).borderedCaption()))\n")
//print("\(wv.thenProceed(with: WorkflowItem(FR1.self).popover(isPresented: .constant(true), content: { Text("") })))\n")
//print("\(wv.thenProceed(with: Text("This should break")))\n")
//print("\(wv.thenProceed(with: Text("Also breaks").bold()))\n")
//
////let wi = WorkflowItem(FR1.self)
////print("WorkflowItem:\n")
////print("- Base: \(wi)")
////print("- Mirror: \(Mirror(reflecting: wi))")
////print("- subject: \(Mirror(reflecting: wi).subjectType)")
////print("- children: \(Mirror(reflecting: wi).children)")
////print("\n\n\n\n")
////
////let modifiedWi = WorkflowItem(FR1.self).padding()
////print("modified WorkflowItem:\n")
////print("- Base: \(modifiedWi)")
////print("- Mirror: \(Mirror(reflecting: modifiedWi))")
////print("- subject: \(Mirror(reflecting: modifiedWi).subjectType)")
//
//print("RAN \(Date())")
////print("\(Text("Foo"))\n\n")
////print("\(Text("Foo").padding())\n\n")
////print("\(Text("Foo").padding().frame(width: 100, height: 200, alignment: .bottom))\n\n")
////
////print("\(Text("Foo").padding().frame(width: 100, height: 200, alignment: .bottom).printBodyType())\n\n")
////
////print("\(Text("Foo").background(Color.red).frame(width: 100, height: 200, alignment: .bottom).background(Color.blue))\n\n")
////print("\(Text("Foo").frame(width: 100, height: 200, alignment: .bottom).background(Color.red).background(Color.blue))\n\n")
////
////extension View {
////    func printBodyType() {
////        print("Body type: \(Body.self)")
////    }
////}
//
//
//struct BorderedCaption: ViewModifier {
//    func body(content: Content) -> some View {
//        content
//            .font(.caption2)
//            .padding(10)
//            .overlay(
//                RoundedRectangle(cornerRadius: 15)
//                    .stroke(lineWidth: 1)
//            )
//            .foregroundColor(Color.blue)
//    }
//}
//extension View {
//    func borderedCaption() -> some View {
//        modifier(BorderedCaption())
//    }
//}






// MARK: MODIFIER SPIKE

print("Starting Modifier spike")

// MARK: EXPLORING AND TRYING CASTING
struct BorderedCaption: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.caption2)
            .padding(10)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(lineWidth: 1)
            )
            .foregroundColor(Color.blue)
    }
}
extension View {
    func borderedCaption() -> some View {
        modifier(BorderedCaption())
    }
}

struct FR1: View {
    var body: some View {
        Text("THIS IS FR1")
    }
}
struct FR2: View {
    var body: some View {
        Text("This is FR2")
    }
}

struct WorkflowView: View {
    var body: some View {
        AnyView(FR1()).background(Color.blue)
    }
}

let workflow = WorkflowView()
print("workflow = \(workflow.body))")
print("modified workflow = \(workflow.modifier(BorderedCaption()))")
print("modified workflow body = \(workflow.body.modifier(BorderedCaption()))")
print("\n\n")

let modifiedThing = workflow.body.modifier(BorderedCaption())

print(modifiedThing)
print(type(of: modifiedThing))
var castIt = modifiedThing as? ModifiedContent<ModifiedContent<AnyView, _BackgroundModifier<Color>>, BorderedCaption>
castIt?.content.content
castIt?.content.content = AnyView(FR2())
castIt?.content.content

castIt?.content



func getSomeView() -> some View { AnyView(FR1().background(Color.red)) }
let foo = getSomeView()
foo
var cast = foo as? ModifiedContent<AnyView, _BackgroundModifier<Color>>
type(of: foo)
cast





// MARK: TRYING CIRCULAR REFERENCING IDEA
protocol MetadataView {
    var metadata: Metadata { get }
    func updateView(with newView: AnyView)
}
class Metadata {
    var circularReference: AnyView?
    var customView = AnyView(Text("Simulate FR1"))
}
struct WorkflowItem: View, MetadataView {
    @ObservedObject private var model = Model(view: AnyView(EmptyView()))
    let metadata: Metadata
    var body: some View {
        model.view
    }

    func updateView(with newView: AnyView) {
        model.view = newView
    }

    private class Model: ObservableObject {
        @Published var view: AnyView
        init(view: AnyView) { self.view = view }
    }
}
let metadata = Metadata()

var workflowItem = WorkflowItem(metadata: metadata)
    .frame(width: 100, height: 100, alignment: .center)
    .background(Color.blue)

metadata.circularReference = AnyView(workflowItem)
(workflowItem as? SwiftUI.ModifiedContent<SwiftUI.ModifiedContent<WorkflowItem, SwiftUI._FrameLayout>, SwiftUI._BackgroundModifier<SwiftUI.Color>>)?.content.content.updateView(with: AnyView(Text("Replaced").background(Color.red)))

workflowItem

extension ModifiedContent: MetadataView where Content: MetadataView {
    var metadata: Metadata { content.metadata }
    func updateView(with newView: AnyView) {
        content.updateView(with: newView)
    }
}
struct WorkflowView2: View {
    @ObservedObject var model = Model()
    var body: some View {
        model.view
    }

    func thenPresent<Content: View>(_ newView: Content) -> Self {
        type(of: newView)
        guard let meta = newView as? MetadataView else { return self }

        meta.metadata.circularReference = AnyView(newView)

        return self
    }

    class Model: ObservableObject {
        @Published var view = AnyView(EmptyView())

        func proceed(metadata: Metadata) {

            view = metadata.circularReference!
        }
    }
}

let meta = WorkflowItem(metadata: Metadata())
    .background(Color.green)
    .frame(width: 100, height: 100, alignment: .center)
    .background(Color.yellow) as? MetadataView

let foo2 = WorkflowView2()
    .thenPresent(WorkflowItem(metadata: Metadata())
                    .background(Color.green)
                    .frame(width: 100, height: 100, alignment: .center)
                    .background(Color.yellow))

foo2.model.proceed(metadata: metadata)

print(" the full deal \(AnyView(Text("SEE MEEEEEE")))")

foo2
