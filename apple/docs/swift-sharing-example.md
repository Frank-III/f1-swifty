Directory Structure:

└── ./
    ├── Internal
    │   ├── CaseStudy.swift
    │   └── Text+Template.swift
    ├── APIClient.swift
    ├── AppStorageSharedState.swift
    ├── CaseStudiesApp.swift
    ├── FileStorageSharedState.swift
    ├── FirebaseDemo.swift
    ├── GlobalRouter.swift
    ├── GRDBDemo.swift
    ├── InMemorySharedState.swift
    ├── InteractionWithAppStorageView.swift
    ├── Notifications.swift
    ├── SharedStateInObservableModel.swift
    ├── SharedStateInView.swift
    ├── SharedStateInViewController.swift
    └── SwiftUIBindingFromShared.swift



---
File: /Internal/CaseStudy.swift
---

import SwiftUI
import UIKitNavigation

@MainActor
protocol CaseStudy {
  var readMe: String { get }
  var caseStudyTitle: String { get }
  var caseStudyNavigationTitle: String { get }
  var usesOwnLayout: Bool { get }
  var isPresentedInSheet: Bool { get }
}
protocol SwiftUICaseStudy: CaseStudy, View {}
protocol UIKitCaseStudy: CaseStudy, UIViewController {}

extension CaseStudy {
  var caseStudyNavigationTitle: String { caseStudyTitle }
  var isPresentedInSheet: Bool { false }
}
extension SwiftUICaseStudy {
  var usesOwnLayout: Bool { false }
}
extension UIKitCaseStudy {
  var usesOwnLayout: Bool { true }
}

@resultBuilder
@MainActor
enum CaseStudyViewBuilder {
  @ViewBuilder
  static func buildBlock() -> some View {}
  @ViewBuilder
  static func buildExpression(_ caseStudy: some SwiftUICaseStudy) -> some View {
    SwiftUICaseStudyButton(caseStudy: caseStudy)
  }
  @ViewBuilder
  static func buildExpression(_ caseStudy: some UIKitCaseStudy) -> some View {
    UIKitCaseStudyButton(caseStudy: caseStudy)
  }
  static func buildPartialBlock(first: some View) -> some View {
    first
  }
  @ViewBuilder
  static func buildPartialBlock(accumulated: some View, next: some View) -> some View {
    accumulated
    next
  }
}

struct SwiftUICaseStudyButton<C: SwiftUICaseStudy>: View {
  let caseStudy: C
  @State var isPresented = false
  var body: some View {
    if caseStudy.isPresentedInSheet {
      Button(caseStudy.caseStudyTitle) {
        isPresented = true
      }
      .sheet(isPresented: $isPresented) {
        CaseStudyView {
          caseStudy
        }
      }
    } else {
      NavigationLink(caseStudy.caseStudyTitle) {
        CaseStudyView {
          caseStudy
        }
      }
    }
  }
}

struct UIKitCaseStudyButton<C: UIKitCaseStudy>: View {
  let caseStudy: C
  @State var isPresented = false
  var body: some View {
    if caseStudy.isPresentedInSheet {
      Button(caseStudy.caseStudyTitle) {
        isPresented = true
      }
      .sheet(isPresented: $isPresented) {
        UIViewControllerRepresenting {
          ((caseStudy as? UINavigationController)
            ?? UINavigationController(rootViewController: caseStudy))
            .setUp(caseStudy: caseStudy)
        }
        .modifier(CaseStudyModifier(caseStudy: caseStudy))
      }
    } else {
      NavigationLink(caseStudy.caseStudyTitle) {
        UIViewControllerRepresenting {
          caseStudy
        }
        .modifier(CaseStudyModifier(caseStudy: caseStudy))
      }
    }
  }
}

extension UINavigationController {
  func setUp(caseStudy: some CaseStudy) -> Self {
    self.viewControllers[0].title = caseStudy.caseStudyNavigationTitle
    self.viewControllers[0].navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "About",
      primaryAction: UIAction { [weak self] _ in
        self?.present(
          UIHostingController(
            rootView: Form {
              Text(template: caseStudy.readMe)
            }
            .presentationDetents([.medium])
          ),
          animated: true
        )
      })
    return self
  }
}

struct CaseStudyModifier<C: CaseStudy>: ViewModifier {
  let caseStudy: C
  @State var isAboutPresented = false
  func body(content: Content) -> some View {
    content
      .navigationTitle(caseStudy.caseStudyNavigationTitle)
      .toolbar {
        ToolbarItem {
          Button("About") { isAboutPresented = true }
        }
      }
      .sheet(isPresented: $isAboutPresented) {
        Form {
          Text(template: caseStudy.readMe)
        }
        .presentationDetents([.medium])
      }
  }
}

struct CaseStudyView<C: SwiftUICaseStudy>: View {
  @ViewBuilder let caseStudy: C
  @State var isAboutPresented = false
  var body: some View {
    if caseStudy.usesOwnLayout {
      VStack {
        caseStudy
      }
      .modifier(CaseStudyModifier(caseStudy: caseStudy))
    } else {
      Form {
        caseStudy
      }
      .modifier(CaseStudyModifier(caseStudy: caseStudy))
    }
  }
}

struct CaseStudyGroupView<Title: View, Content: View>: View {
  @CaseStudyViewBuilder let content: Content
  @ViewBuilder let title: Title

  var body: some View {
    Section {
      content
    } header: {
      title
    }
  }
}

extension CaseStudyGroupView where Title == Text {
  init(_ title: String, @CaseStudyViewBuilder content: () -> Content) {
    self.init(content: content) { Text(title) }
  }
}

extension SwiftUICaseStudy {
  fileprivate func navigationLink() -> some View {
    NavigationLink(caseStudyTitle) {
      self
    }
  }
}

#Preview("SwiftUI case study") {
  NavigationStack {
    CaseStudyView {
      DemoCaseStudy()
    }
  }
}

#Preview("SwiftUI case study group") {
  NavigationStack {
    Form {
      CaseStudyGroupView("Group") {
        DemoCaseStudy()
      }
    }
  }
}

private struct DemoCaseStudy: SwiftUICaseStudy {
  let caseStudyTitle = "Demo Case Study"
  let readMe = """
    Hello! This is a demo case study.

    Enjoy!
    """
  var body: some View {
    Text("Hello!")
  }
}

private class DemoCaseStudyController: UIViewController, UIKitCaseStudy {
  let caseStudyTitle = "Demo Case Study"
  let readMe = """
    Hello! This is a demo case study.

    Enjoy!
    """
}



---
File: /Internal/Text+Template.swift
---

import SwiftUI

extension Text {
  init(template: String, _ style: Font.TextStyle = .body) {
    enum Style: Hashable {
      case code
      case emphasis
      case strong
    }

    var segments: [Text] = []
    var currentValue = ""
    var currentStyles: Set<Style> = []

    func flushSegment() {
      var text = Text(currentValue)
      if currentStyles.contains(.code) {
        text = text.font(.system(style, design: .monospaced))
      }
      if currentStyles.contains(.emphasis) {
        text = text.italic()
      }
      if currentStyles.contains(.strong) {
        text = text.bold()
      }
      segments.append(text)
      currentValue.removeAll()
    }

    for character in template {
      switch (character, currentStyles.contains(.code)) {
      case ("*", false):
        flushSegment()
        currentStyles.toggle(.strong)
      case ("_", false):
        flushSegment()
        currentStyles.toggle(.emphasis)
      case ("`", _):
        flushSegment()
        currentStyles.toggle(.code)
      default:
        currentValue.append(character)
      }
    }
    flushSegment()

    self = segments.reduce(Text(verbatim: ""), +)
  }
}

extension Set {
  fileprivate mutating func toggle(_ element: Element) {
    if contains(element) {
      remove(element)
    } else {
      insert(element)
    }
  }
}



---
File: /APIClient.swift
---

import SwiftUI

struct APIClientView: SwiftUICaseStudy {
  let readMe = """
    See the dedicated API Client demo in the repo at ./Examples/APIClientDemo.
    """
  let caseStudyTitle = "API Client"

  var body: some View {
    Text("See the dedicated API Client demo in the repo at ./Examples/APIClientDemo.")
  }
}



---
File: /AppStorageSharedState.swift
---

import Sharing
import SwiftUI

struct AppStorageStateView: SwiftUICaseStudy {
  let caseStudyTitle = "@Shared(.appStorage)"
  let readMe = """
    Demonstrates how to use `appStorage` persistence strategy to persist simple pieces of data \
    to user defaults. This tool works when installed directly in a SwiftUI view, just like \
    `@AppStorage`, but most importantly it still works when installed in othe parts of your app, \
    including `@Observable` models, UIKit view controllers, and more.
    """

  @State private var model = Model()

  var body: some View {
    Section {
      Text("\(model.count)")
      Button("Decrement") {
        model.$count.withLock { $0 -= 1 }
      }
      Button("Increment") {
        model.$count.withLock { $0 += 1 }
      }
    }
  }
}

@Observable
private class Model {
  @ObservationIgnored
  @Shared(.appStorage("count")) var count = 0
}

#Preview {
  NavigationStack {
    CaseStudyView {
      AppStorageStateView()
    }
  }
}



---
File: /CaseStudiesApp.swift
---

import Dependencies
import SwiftUI

@main
struct CaseStudiesApp: App {
  var body: some Scene {
    WindowGroup {
      NavigationStack {
        RootView()
      }
    }
  }
}

private struct RootView: View {
  var body: some View {
    Form {
      CaseStudyGroupView("Persistence strategies") {
        InMemorySharedStateView()
        AppStorageStateView()
        FileStorageSharedState()
      }
      CaseStudyGroupView("SwiftUI") {
        InteractionWithAppStorageView()
        SharedStateInView()
        SharedStateInObservableModelView()
        SwiftUIBindingFromSharedView()
        GlobalRouterView()
      }
      CaseStudyGroupView("UIKit") {
        SharedStateInViewController()
      }
      CaseStudyGroupView("Custom SharedKey") {
        NotificationsView()
        APIClientView()
        GRDBView()
        FirebaseView()
      }
    }
    .navigationTitle(Text("Case studies"))
  }
}

#Preview {
  NavigationStack {
    RootView()
  }
}



---
File: /FileStorageSharedState.swift
---

import Dependencies
import Sharing
import SwiftUI

struct Timestamp: Codable, Identifiable {
  let id: UUID
  var value: Date
}

struct FileStorageSharedState: SwiftUICaseStudy {
  let caseStudyTitle = "@Share(.fileStorage)"
  let readMe = """
    This case study demonstrates how to use the built-in `fileStorage` strategy to persist data
    to the file system. Changes made to the `timestamps` state is automatically saved to disk,
    and if the file on disk ever changes its contents will be loaded into the `timestamps` state
    automatically.
    """

  @Shared(.fileStorage(.documentsDirectory.appending(component: "timestamps.json")))
  var timestamps: [Timestamp] = []

  var body: some View {
    Section {
      Button("Clear") {
        withAnimation {
          $timestamps.withLock { $0 = [] }
        }
      }
    }
    .toolbar {
      ToolbarItem {
        Button {
          withAnimation {
            $timestamps.withLock {
              $0.append(Timestamp(id: UUID(), value: Date()))
            }
          }
        } label: {
          Image(systemName: "plus")
        }
      }
    }

    if !timestamps.isEmpty {
      Section {
        ForEach(timestamps) { timestamp in
          Text(timestamp.value, format: Date.FormatStyle(date: .numeric, time: .standard))
        }
        .onDelete { indexSet in
          $timestamps.withLock {
            $0.remove(atOffsets: indexSet)
          }
        }
      } header: {
        Text("Timestamps")
      }
    }
  }
}

#Preview {
  NavigationStack {
    CaseStudyView {
      FileStorageSharedState()
    }
  }
}



---
File: /FirebaseDemo.swift
---

import SwiftUI

struct FirebaseView: SwiftUICaseStudy {
  let readMe = """
    See the dedicated Firebase demo in the repo at ./Examples/FirebaseDemo.
    """
  let caseStudyTitle = "Firebase"

  var body: some View {
    Text("See the dedicated Firebase demo in the repo at ./Examples/FirebaseDemo.")
  }
}



---
File: /GlobalRouter.swift
---

import Sharing
import SwiftUI

private enum Route: Codable, Hashable {
  case plainView
  case observableModel
  case viewController
}

private let readMe = """
  This demonstrates how one can hold onto the global routing information for an app in a \
  `@Shared` value so that any part of the app can read from and write to it. This allows views \
  _and_ `@Observable` models to make changes to the routes.

  Further, the routes are automatically persisted to disk so that the state of the app will \
  be restored when the app is relaunched.
  """

struct GlobalRouterView: SwiftUICaseStudy {
  let readMe = CaseStudies.readMe
  let caseStudyTitle = "Global Router"
  let isPresentedInSheet = true
  let usesOwnLayout = true

  @Shared(.path) private var path

  var body: some View {
    NavigationStack(path: Binding($path)) {
      RootView()
        .navigationDestination(for: Route.self) { route in
          switch route {
          case .plainView:
            PlainView()
          case .observableModel:
            ViewWithObservableModel()
          case .viewController:
            ViewController.Representable()
              .navigationTitle(Text("UIKit controller"))
          }
        }
        .navigationTitle(caseStudyTitle)
    }
  }
}

private struct RootView: View {
  @Shared(.path) var path

  var body: some View {
    Form {
      Text(template: readMe)

      Section {
        Button("Go to plain SwiftUI view") {
          $path.withLock { $0.append(.plainView) }
        }
        Button("Go to view with @Observable model") {
          $path.withLock { $0.append(.observableModel) }
        }
        Button("Go to UIViewController") {
          $path.withLock { $0.append(.viewController) }
        }
      }
    }
  }
}

private struct PlainView: View {
  @Shared(.path) var path

  var body: some View {
    Form {
      Text(
        template: """
          This screen holds onto `@Shared(.path)` directly in the view and can mutate it directly.
          """
      )
      Section {
        Button("Go to plain SwiftUI view") {
          $path.withLock { $0.append(.plainView) }
        }
        Button("Go to view with @Observable model") {
          $path.withLock { $0.append(.observableModel) }
        }
        Button("Go to UIViewController") {
          $path.withLock { $0.append(.viewController) }
        }
      }
    }
    .navigationTitle(Text("Plain SwiftUI view"))
  }
}

private struct ViewWithObservableModel: View {
  @Observable class Model {
    @ObservationIgnored @Shared(.path) var path
  }
  @State var model = Model()

  var body: some View {
    Form {
      Text(
        template: """
          This screen holds onto `@Shared(.path)` in an `@Observable` model. This shows that even
          models can mutate the global router directly.
          """)
      Section {
        Button("Go to plain SwiftUI view") {
          model.$path.withLock { $0.append(.plainView) }
        }
        Button("Go to view with @Observable model") {
          model.$path.withLock { $0.append(.observableModel) }
        }
        Button("Go to UIViewController") {
          model.$path.withLock { $0.append(.viewController) }
        }
      }
    }
    .navigationTitle(Text("@Observable model"))
  }
}

private class ViewController: UIViewController {
  @Shared(.path) var path

  override func viewDidLoad() {
    super.viewDidLoad()

    let label = UILabel()
    label.text = """
      This screen holds onto the @Shared(.path) in a UIKit view controller. This shows that even \
      UIKit can mutate the global router directly.
      """
    label.numberOfLines = 0
    label.lineBreakMode = .byWordWrapping
    let screenAButton = UIButton(type: .system)
    screenAButton.setTitle("Go to plain SwiftUI view", for: .normal)
    screenAButton.addAction(
      UIAction { [weak self] _ in
        self?.$path.withLock { $0.append(.plainView) }
      },
      for: .touchUpInside
    )
    let screenBButton = UIButton(type: .system)
    screenBButton.setTitle("Go to view with @Observable model", for: .normal)
    screenBButton.addAction(
      UIAction { [weak self] _ in
        self?.$path.withLock { $0.append(.plainView) }
      },
      for: .touchUpInside
    )
    let screenCButton = UIButton(type: .system)
    screenCButton.setTitle("Go to UIViewController", for: .normal)
    screenCButton.addAction(
      UIAction { [weak self] _ in
        self?.$path.withLock { $0.append(.plainView) }
      },
      for: .touchUpInside
    )
    let stackView = UIStackView(
      arrangedSubviews: [
        label,
        screenAButton,
        screenBButton,
        screenCButton,
      ]
    )
    stackView.axis = .vertical
    stackView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(stackView)
    NSLayoutConstraint.activate([
      stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
      stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
      stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
    ])
  }

  struct Representable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController { ViewController() }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
  }
}

extension SharedReaderKey where Self == FileStorageKey<[Route]>.Default {
  fileprivate static var path: Self {
    Self[
      .fileStorage(.documentsDirectory.appending(path: "path.json")),
      default: []
    ]
  }
}

#Preview {
  CaseStudyView {
    GlobalRouterView()
  }
}



---
File: /GRDBDemo.swift
---

import SwiftUI

struct GRDBView: SwiftUICaseStudy {
  let readMe = """
    See the dedicated GRDB demo in the repo at ./Examples/GRDBDemo.
    """
  let caseStudyTitle = "GRDB"

  var body: some View {
    Text("See the dedicated GRDB demo in the repo at ./Examples/GRDBDemo.")
  }
}



---
File: /InMemorySharedState.swift
---

import Sharing
import SwiftUI

struct InMemorySharedStateView: SwiftUICaseStudy {
  let caseStudyTitle = "@Shared(.inMemory)"
  let readMe = """
    This case study demonstrates how to use the built-in `inMemory` strategy to share state \
    globally (and safely) with the entire app, but its contents will be cleared out when the \
    app is restarted.

    Note that `@Shared(.inMemory)` differs from `@State` in that `@State` will be cleared out \
    when navigating away from this view and coming back. Whereas the `@Shared` value is persisted \
    globally for the entire lifetime of the app.
    """

  @Shared(.inMemory("count")) var sharedCount = 0
  @State var stateCount = 0

  var body: some View {
    Section {
      Text("\(stateCount)")
      Button("Increment") {
        stateCount += 1
      }
      Button("Decrement") {
        stateCount -= 1
      }
    } header: {
      Text("@State")
    }

    Section {
      Text("\(sharedCount)")
      Button("Increment") {
        $sharedCount.withLock { $0 += 1 }
      }
      Button("Decrement") {
        $sharedCount.withLock { $0 -= 1 }
      }
    } header: {
      Text("@Shared(.inMemory)")
    }
  }
}

#Preview {
  NavigationStack {
    CaseStudyView {
      InMemorySharedStateView()
    }
  }
}



---
File: /InteractionWithAppStorageView.swift
---

import Dependencies
import Sharing
import SwiftUI

struct InteractionWithAppStorageView: SwiftUICaseStudy {
  let caseStudyTitle = "Interaction with @AppStorage"
  let caseStudyNavigationTitle = "With @AppStorage"
  let readMe = """
    This case study demonstrates that `@Shared(.appStorage)` interacts with regular `@AppStorage` \
    exactly as you would expect. A change in one instantly updates the other.

    You might not typically want to use `@Shared(.appStorage)` directly in a SwiftUI view since \
    `@AppStorage` is available. But there are a few differences between the two that you may \
    find interesting.

    • In previews and tests, `@Shared(.appStorage)` operates on a quarantined instance of user \
    defaults that will not bleed over to other tests, previews or simulators.
    • `@Shared(.appStorage)` primarily uses KVO to observe changes to user defaults, which means \
    it will update when changes are made from other processes, such as widgets.
    • Because of its reliance on KVO, it is possible to animate changes to the value held in \
    app storage.
    """

  @Shared(.appStorage("count")) var sharedCount = 0
  @AppStorage("count") var appStorageCount = 0

  var body: some View {
    Section {
      Button("Reset UserDefaults directly") {
        UserDefaults.standard.set(0, forKey: "count")
      }
    }

    Section {
      Text("\(sharedCount)")
      Button("Increment") {
        $sharedCount.withLock { $0 += 1 }
      }
      Button("Decrement") {
        $sharedCount.withLock { $0 -= 1 }
      }
    } header: {
      Text("@Shared(.appStorage)")
    }

    Section {
      Text("\(appStorageCount)")
      Button("Increment") {
        appStorageCount += 1
      }
      Button("Decrement") {
        appStorageCount -= 1
      }
    } header: {
      Text("@AppStorage")
    }
  }
}

#Preview("Standard user defaults") {
  let _ = prepareDependencies { $0.defaultAppStorage = .standard }
  NavigationStack {
    CaseStudyView {
      InteractionWithAppStorageView()
    }
  }
}

#Preview("Quarantined user defaults") {
  let _ = UserDefaults(
    suiteName: "\(NSTemporaryDirectory())co.pointfree.Sharing.\(UUID().uuidString)"
  )!
  @Dependency(\.defaultAppStorage) var store
  NavigationStack {
    CaseStudyView {
      InteractionWithAppStorageView()
    }
  }
  .defaultAppStorage(store)
}



---
File: /Notifications.swift
---

import ConcurrencyExtras
import Sharing
import SwiftUI

struct NotificationsView: SwiftUICaseStudy {
  let readMe = """
    This application demonstrates how to use the `@SharedReader` tool to introduce a piece of \
    read-only state to your feature whose true value lives in an external system. In this case, \
    the state is the number of times a screenshot is taken, which is counted from the \
    `userDidTakeScreenshotNotification` notification, as well as the number of times the app has \
    been backgrounded, which is counted from the `willResignActiveNotification` notification.

    Run this application in the simulator, and take a few screenshots by going to \
    *Device › Trigger Screenshot* in the menu, and observe that the UI counts the number of times \
    that happens. And then background the app and re-open the app to see that the UI counts the \
    number of times you do that.
    """
  let caseStudyTitle = "Notifications"

  @SharedReader(.count(UIApplication.userDidTakeScreenshotNotification)) var screenshotCount = 0
  @SharedReader(.count(UIApplication.willResignActiveNotification)) var resignCount = 0

  var body: some View {
    Section {
      Text("Number of screenshots: \(screenshotCount)")
      Text("Number of times resigned active: \(resignCount)")
    }
  }
}

extension SharedReaderKey where Self == NotificationKey<Int> {
  static func count(_ name: Notification.Name) -> Self {
    Self(initialValue: 0, name: name) { value, _ in value += 1 }
  }
}

private struct NotificationKey<Value: Sendable>: SharedReaderKey {
  let name: Notification.Name
  let transform: @Sendable (Notification) -> Value

  init(
    initialValue: Value,
    name: Notification.Name,
    transform: @escaping @Sendable (inout Value, Notification) -> Void
  ) {
    self.name = name
    let value = LockIsolated(initialValue)
    self.transform = { notification in
      nonisolated(unsafe) let notification = notification
      return value.withValue {
        transform(&$0, notification)
        return $0
      }
    }
  }

  var id: some Hashable { name }

  func load(context _: LoadContext<Value>, continuation: LoadContinuation<Value>) {
    continuation.resumeReturningInitialValue()
  }

  func subscribe(
    context: LoadContext<Value>, subscriber: SharedSubscriber<Value>
  ) -> SharedSubscription {
    nonisolated(unsafe) let token = NotificationCenter.default.addObserver(
      forName: name,
      object: nil,
      queue: nil
    ) { notification in
      subscriber.yield(transform(notification))
    }
    return SharedSubscription {
      NotificationCenter.default.removeObserver(token)
    }
  }
}



---
File: /SharedStateInObservableModel.swift
---

import Sharing
import SwiftUI

@Observable
private class Model {
  @ObservationIgnored
  @Shared(.appStorage("count")) var count = 0
}

struct SharedStateInObservableModelView: SwiftUICaseStudy {
  let caseStudyTitle = "Shared state in @Observable model"
  let caseStudyNavigationTitle = "In @Observable"
  let readMe = """
    This case study demonstrates that one can use `@Shared(.appStorage)` (and really any kind of \
    `@Shared` value) in an `@Observable` model, and it will work as expected. This is in contrast \
    to `@AppStorage` and other SwiftUI property wrappers, which only work when used directly \
    in SwiftUI views.
    """

  @State private var model = Model()

  var body: some View {
    Text("\(model.count)")
    Button("Decrement") {
      model.$count.withLock { $0 -= 1 }
    }
    Button("Increment") {
      model.$count.withLock { $0 += 1 }
    }
  }
}

#Preview {
  NavigationStack {
    CaseStudyView {
      SharedStateInObservableModelView()
    }
  }
}



---
File: /SharedStateInView.swift
---

import Sharing
import SwiftUI

struct SharedStateInView: SwiftUICaseStudy {
  let caseStudyTitle = "Shared state in SwiftUI view"
  let caseStudyNavigationTitle = "In SwiftUI"
  let readMe = """
    Demonstrates how to use a `@Shared` value directly in a SwiftUI view.
    """

  @Shared(.appStorage("count")) var count = 0

  var body: some View {
    Text("\(count)")
    Button("Decrement") {
      $count.withLock { $0 -= 1 }
    }
    Button("Increment") {
      $count.withLock { $0 += 1 }
    }
  }
}

#Preview {
  NavigationStack {
    CaseStudyView {
      SharedStateInView()
    }
  }
}



---
File: /SharedStateInViewController.swift
---

import Sharing
import UIKit
import UIKitNavigation

final class SharedStateInViewController: UIViewController, UIKitCaseStudy {
  let caseStudyTitle = "Shared state in UIKit view controller"
  let caseStudyNavigationTitle = "In UIKit"
  let readMe = """
    Demonstrates how to use a `@Shared` value directly in a UIKit view controller.
    """

  @Shared(.appStorage("count")) var count = 0

  override func viewDidLoad() {
    super.viewDidLoad()

    let countLabel = UILabel()

    let incrementButton = UIButton(type: .system)
    incrementButton.setTitle("Increment", for: .normal)
    incrementButton.addAction(
      UIAction { [weak self] _ in
        self?.$count.withLock { $0 += 1 }
      },
      for: .touchUpInside
    )
    let decrementButton = UIButton(type: .system)
    decrementButton.setTitle("Decrement", for: .normal)
    decrementButton.addAction(
      UIAction { [weak self] _ in
        self?.$count.withLock { $0 -= 1 }
      },
      for: .touchUpInside
    )
    let stackView = UIStackView(arrangedSubviews: [
      countLabel,
      incrementButton,
      decrementButton,
    ])
    stackView.alignment = .center
    stackView.axis = .vertical
    stackView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(stackView)

    NSLayoutConstraint.activate([
      stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
    ])

    observe { [weak self] in
      guard let self else { return }

      countLabel.text = count.description
    }
  }
}

#Preview {
  SharedStateInViewController()
}



---
File: /SwiftUIBindingFromShared.swift
---

//
//  SharedStateInView 2.swift
//  Examples
//
//  Created by Brandon Williams on 11/26/24.
//

import Sharing
import SwiftUI

struct SwiftUIBindingFromSharedView: SwiftUICaseStudy {
  let caseStudyTitle = "SwiftUI bindings"
  let readMe = """
    Demonstrates how to derive a binding to a piece of shared state.

    Any piece of shared state can be turned into a SwiftUI `Binding` by using the special \
    `Binding.init(_:)` initializer.
    """

  @Shared(.appStorage("count")) var count = 0

  var body: some View {
    Section {
      Stepper("\(count)", value: Binding($count))
    } header: {
      Text("SwiftUI Binding")
    }
  }
}

#Preview {
  NavigationStack {
    CaseStudyView {
      SharedStateInView()
    }
  }
}

