Directory Structure:

└── ./
    ├── Helpers.swift
    ├── ReminderForm.swift
    ├── ReminderRow.swift
    ├── RemindersApp.swift
    ├── RemindersDetail.swift
    ├── RemindersListForm.swift
    ├── RemindersListRow.swift
    ├── RemindersLists.swift
    ├── Schema.swift
    ├── SearchReminders.swift
    ├── TagRow.swift
    └── TagsForm.swift



---
File: /Helpers.swift
---

import SharingGRDB
import SwiftUI

extension Color {
  public struct HexRepresentation: QueryBindable, QueryRepresentable {
    public var queryOutput: Color
    public var queryBinding: QueryBinding {
      guard let components = UIColor(queryOutput).cgColor.components
      else {
        struct InvalidColor: Error {}
        return .invalid(InvalidColor())
      }
      let r = Int64(components[0] * 0xFF) << 24
      let g = Int64(components[1] * 0xFF) << 16
      let b = Int64(components[2] * 0xFF) << 8
      let a = Int64((components.indices.contains(3) ? components[3] : 1) * 0xFF)
      return .int(r | g | b | a)
    }
    public init(queryOutput: Color) {
      self.queryOutput = queryOutput
    }
    public init(decoder: inout some QueryDecoder) throws {
      let hex = try Int(decoder: &decoder)
      self.init(
        queryOutput: Color(
          red: Double((hex >> 24) & 0xFF) / 0xFF,
          green: Double((hex >> 16) & 0xFF) / 0xFF,
          blue: Double((hex >> 8) & 0xFF) / 0xFF,
          opacity: Double(hex & 0xFF) / 0xFF
        )
      )
    }
  }
}



---
File: /ReminderForm.swift
---

import IssueReporting
import SharingGRDB
import SwiftUI

struct ReminderFormView: View {
  @FetchAll(RemindersList.order(by: \.title)) var remindersLists
  @FetchOne var remindersList: RemindersList

  @State var isPresentingTagsPopover = false
  @State var reminder: Reminder.Draft
  @State var selectedTags: [Tag] = []

  @Dependency(\.defaultDatabase) private var database
  @Environment(\.dismiss) var dismiss

  init(reminder: Reminder.Draft, remindersList: RemindersList) {
    _remindersList = FetchOne(wrappedValue: remindersList, RemindersList.find(remindersList.id))
    self.reminder = reminder
  }

  var body: some View {
    Form {
      TextField("Title", text: $reminder.title)

      ZStack {
        if reminder.notes.isEmpty {
          TextEditor(text: .constant("Notes"))
            .foregroundStyle(.placeholder)
            .accessibilityHidden(true, isEnabled: false)
        }

        TextEditor(text: $reminder.notes)
      }
      .lineLimit(4)
      .padding([.leading, .trailing], -5)

      Section {
        Button {
          isPresentingTagsPopover = true
        } label: {
          HStack {
            Image(systemName: "number.square.fill")
              .font(.title)
              .foregroundStyle(.gray)
            Text("Tags")
              .foregroundStyle(Color(.label))
            Spacer()
            if let tagsDetail {
              tagsDetail
                .lineLimit(1)
                .truncationMode(.tail)
                .font(.callout)
                .foregroundStyle(.gray)
            }
            Image(systemName: "chevron.right")
          }
        }
      }
      .popover(isPresented: $isPresentingTagsPopover) {
        NavigationStack {
          TagsView(selectedTags: $selectedTags)
        }
      }

      Section {
        Toggle(isOn: $reminder.isDateSet.animation()) {
          HStack {
            Image(systemName: "calendar.circle.fill")
              .font(.title)
              .foregroundStyle(.red)
            Text("Date")
          }
        }
        if let dueDate = reminder.dueDate {
          DatePicker(
            "",
            selection: $reminder.dueDate[coalesce: dueDate],
            displayedComponents: [.date, .hourAndMinute]
          )
          .padding([.top, .bottom], 2)
        }
      }

      Section {
        Toggle(isOn: $reminder.isFlagged) {
          HStack {
            Image(systemName: "flag.circle.fill")
              .font(.title)
              .foregroundStyle(.red)
            Text("Flag")
          }
        }
        Picker(selection: $reminder.priority) {
          Text("None").tag(Priority?.none)
          Divider()
          Text("High").tag(Priority.high)
          Text("Medium").tag(Priority.medium)
          Text("Low").tag(Priority.low)
        } label: {
          HStack {
            Image(systemName: "exclamationmark.circle.fill")
              .font(.title)
              .foregroundStyle(.red)
            Text("Priority")
          }
        }

        Picker(selection: $reminder.remindersListID) {
          ForEach(remindersLists) { remindersList in
            Text(remindersList.title)
              .tag(remindersList)
              .buttonStyle(.plain)
              .tag(remindersList.id)
          }
        } label: {
          HStack {
            Image(systemName: "list.bullet.circle.fill")
              .font(.title)
              .foregroundStyle(remindersList.color)
            Text("List")
          }
        }
        .task(id: reminder.remindersListID) {
          await withErrorReporting {
            try await $remindersList.load(RemindersList.find(reminder.remindersListID))
          }
        }
      }
    }
    .padding(.top, -28)
    .task {
      guard let reminderID = reminder.id
      else { return }
      do {
        selectedTags = try await database.read { db in
          try Tag
            .order(by: \.title)
            .join(ReminderTag.all) { $0.id.eq($1.tagID) }
            .where { $1.reminderID.eq(reminderID) }
            .select { tag, _ in tag }
            .fetchAll(db)
        }
      } catch {
        selectedTags = []
        reportIssue(error)
      }
    }
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem {
        Button(action: saveButtonTapped) {
          Text("Save")
        }
      }
      ToolbarItem(placement: .cancellationAction) {
        Button("Cancel") {
          dismiss()
        }
      }
    }
  }

  private var tagsDetail: Text? {
    guard let tag = selectedTags.first else { return nil }
    return selectedTags.dropFirst().reduce(Text("#\(tag.title)")) { result, tag in
      result + Text(" #\(tag.title) ")
    }
  }

  private func saveButtonTapped() {
    withErrorReporting {
      try database.write { db in
        let reminderID = try Reminder.upsert { reminder }
          .returning(\.id)
          .fetchOne(db)!
        try ReminderTag
          .where { $0.reminderID.eq(reminderID) }
          .delete()
          .execute(db)
        try ReminderTag.insert {
          selectedTags.map { tag in
            ReminderTag.Draft(reminderID: reminderID, tagID: tag.id)
          }
        }
        .execute(db)
      }
    }
    dismiss()
  }
}

extension Reminder.Draft {
  fileprivate var isDateSet: Bool {
    get { dueDate != nil }
    set { dueDate = newValue ? Date() : nil }
  }
}

extension Optional {
  fileprivate subscript(coalesce coalesce: Wrapped) -> Wrapped {
    get { self ?? coalesce }
    set { self = newValue }
  }
}

struct ReminderFormPreview: PreviewProvider {
  static var previews: some View {
    let (remindersList, reminder) = try! prepareDependencies {
      $0.defaultDatabase = try Reminders.appDatabase()
      return try $0.defaultDatabase.write { db in
        let remindersList = try RemindersList.all.fetchOne(db)!
        return (
          remindersList,
          try Reminder.where { $0.remindersListID == remindersList.id }.fetchOne(db)!
        )
      }
    }
    NavigationStack {
      ReminderFormView(reminder: Reminder.Draft(reminder), remindersList: remindersList)
        .navigationTitle("Detail")
    }
  }
}



---
File: /ReminderRow.swift
---

import SharingGRDB
import SwiftUI

struct ReminderRow: View {
  let color: Color
  let isPastDue: Bool
  let notes: String
  let reminder: Reminder
  let remindersList: RemindersList
  let showCompleted: Bool
  let tags: [String]

  @State var editReminder: Reminder.Draft?
  @State var isCompleted: Bool

  @Dependency(\.defaultDatabase) private var database

  init(
    color: Color,
    isPastDue: Bool,
    notes: String,
    reminder: Reminder,
    remindersList: RemindersList,
    showCompleted: Bool,
    tags: [String]
  ) {
    self.color = color
    self.isPastDue = isPastDue
    self.notes = notes
    self.reminder = reminder
    self.remindersList = remindersList
    self.showCompleted = showCompleted
    self.tags = tags
    self.isCompleted = reminder.isCompleted
  }

  var body: some View {
    HStack {
      HStack(alignment: .firstTextBaseline) {
        Button(action: completeButtonTapped) {
          Image(systemName: isCompleted ? "circle.inset.filled" : "circle")
            .foregroundStyle(.gray)
            .font(.title2)
            .padding([.trailing], 5)
        }
        VStack(alignment: .leading) {
          title(for: reminder)

          if !notes.isEmpty {
            Text(notes)
              .font(.subheadline)
              .foregroundStyle(.gray)
              .lineLimit(2)
          }
          subtitleText
        }
      }
      Spacer()
      if !isCompleted {
        HStack {
          if reminder.isFlagged {
            Image(systemName: "flag.fill")
              .foregroundStyle(.orange)
          }
          Button {
            editReminder = Reminder.Draft(reminder)
          } label: {
            Image(systemName: "info.circle")
          }
          .tint(color)
        }
      }
    }
    .buttonStyle(.borderless)
    .swipeActions {
      Button("Delete", role: .destructive) {
        withErrorReporting {
          try database.write { db in
            try Reminder.delete(reminder).execute(db)
          }
        }
      }
      Button(reminder.isFlagged ? "Unflag" : "Flag") {
        withErrorReporting {
          try database.write { db in
            try Reminder
              .find(reminder.id)
              .update { $0.isFlagged.toggle() }
              .execute(db)
          }
        }
      }
      .tint(.orange)
      Button("Details") {
        editReminder = Reminder.Draft(reminder)
      }
    }
    .sheet(item: $editReminder) { reminder in
      NavigationStack {
        ReminderFormView(reminder: reminder, remindersList: remindersList)
          .navigationTitle("Details")
      }
    }
    .task(id: isCompleted) {
      guard !showCompleted else { return }
      guard
        isCompleted,
        isCompleted != reminder.isCompleted
      else { return }
      do {
        try await Task.sleep(for: .seconds(2))
        toggleCompletion()
      } catch {}
    }
  }

  private func completeButtonTapped() {
    if showCompleted {
      toggleCompletion()
    } else {
      isCompleted.toggle()
    }
  }

  private func toggleCompletion() {
    withErrorReporting {
      try database.write { db in
        isCompleted =
          try Reminder
          .find(reminder.id)
          .update { $0.isCompleted.toggle() }
          .returning(\.isCompleted)
          .fetchOne(db) ?? isCompleted
      }
    }
  }

  private var dueText: Text {
    if let date = reminder.dueDate {
      Text(date.formatted(date: .numeric, time: .shortened))
        .foregroundStyle(isPastDue ? .red : .gray)
    } else {
      Text("")
    }
  }

  private var subtitleText: Text {
    let tagsText = tags.reduce(Text(reminder.dueDate == nil ? "" : "  ")) { result, tag in
      result + Text("#\(tag) ")
    }
    return
      (dueText
      + tagsText
      .foregroundStyle(.gray)
      .bold())
      .font(.callout)
  }

  private func title(for reminder: Reminder) -> some View {
    return HStack(alignment: .firstTextBaseline) {
      if let priority = reminder.priority {
        Text(String(repeating: "!", count: priority.rawValue))
          .foregroundStyle(isCompleted ? .gray : remindersList.color)
      }
      Text(reminder.title)
        .foregroundStyle(isCompleted ? .gray : .primary)
    }
    .font(.title3)
  }
}

struct ReminderRowPreview: PreviewProvider {
  static var previews: some View {
    var reminder: Reminder!
    var remindersList: RemindersList!
    let _ = try! prepareDependencies {
      $0.defaultDatabase = try Reminders.appDatabase()
      try $0.defaultDatabase.read { db in
        reminder = try Reminder.all.fetchOne(db)
        remindersList = try RemindersList.all.fetchOne(db)!
      }
    }

    NavigationStack {
      List {
        ReminderRow(
          color: remindersList.color,
          isPastDue: false,
          notes: reminder.notes.replacingOccurrences(of: "\n", with: " "),
          reminder: reminder,
          remindersList: remindersList,
          showCompleted: true,
          tags: ["point-free", "adulting"]
        )
      }
    }
  }
}



---
File: /RemindersApp.swift
---

import SharingGRDB
import SwiftUI

@main
struct RemindersApp: App {
  @Dependency(\.context) var context
  static let model = RemindersListsModel()

  init() {
    if context == .live {
      try! prepareDependencies {
        $0.defaultDatabase = try Reminders.appDatabase()
      }
    }
  }

  var body: some Scene {
    WindowGroup {
      if context == .live {
        NavigationStack {
          RemindersListsView(model: Self.model)
        }
      }
    }
  }
}



---
File: /RemindersDetail.swift
---

import CasePaths
import SharingGRDB
import SwiftUI
import SwiftUINavigation

@MainActor
@Observable
class RemindersDetailModel: HashableObject {
  @ObservationIgnored @FetchAll var reminderRows: [Row]
  @ObservationIgnored @Shared var ordering: Ordering
  @ObservationIgnored @Shared var showCompleted: Bool

  let detailType: DetailType
  var isNewReminderSheetPresented = false

  @ObservationIgnored @Dependency(\.defaultDatabase) private var database

  init(detailType: DetailType) {
    self.detailType = detailType
    _ordering = Shared(wrappedValue: .dueDate, .appStorage("ordering_list_\(detailType.id)"))
    _showCompleted = Shared(
      wrappedValue: detailType == .completed,
      .appStorage("show_completed_list_\(detailType.id)")
    )
    _reminderRows = FetchAll(remindersQuery)
  }

  func orderingButtonTapped(_ ordering: Ordering) async {
    $ordering.withLock { $0 = ordering }
    await updateQuery()
  }

  func showCompletedButtonTapped() async {
    $showCompleted.withLock { $0.toggle() }
    await updateQuery()
  }

  func move(from source: IndexSet, to destination: Int) async {
    withErrorReporting {
      try database.write { db in
        var ids = reminderRows.map(\.reminder.id)
        ids.move(fromOffsets: source, toOffset: destination)
        try Reminder
          .where { $0.id.in(ids) }
          .update {
            let ids = Array(ids.enumerated())
            let (first, rest) = (ids.first!, ids.dropFirst())
            $0.position =
            rest
              .reduce(Case($0.id).when(first.element, then: first.offset)) { cases, id in
                cases.when(id.element, then: id.offset)
              }
              .else($0.position)
          }
          .execute(db)
      }
    }
    $ordering.withLock { $0 = .manual }
    await updateQuery()
  }
  
  private func updateQuery() async {
    await withErrorReporting {
      try await $reminderRows.load(remindersQuery, animation: .default)
    }
  }

  private var remindersQuery: some StructuredQueriesCore.Statement<Row> {
    let query =
    Reminder
      .where {
        if !showCompleted {
          !$0.isCompleted
        }
      }
      .order { $0.isCompleted }
      .order {
        switch ordering {
        case .dueDate: $0.dueDate.asc(nulls: .last)
        case .manual: $0.position
        case .priority: ($0.priority.desc(), $0.isFlagged.desc())
        case .title: $0.title
        }
      }
      .withTags
      .where { reminder, _, tag in
        switch detailType {
        case .all: !reminder.isCompleted
        case .completed: reminder.isCompleted
        case .flagged: reminder.isFlagged
        case .remindersList(let list): reminder.remindersListID.eq(list.id)
        case .scheduled: reminder.isScheduled
        case .tags(let tags): tag.id.ifnull(UUID(0)).in(tags.map(\.id))
        case .today: reminder.isToday
        }
      }
      .join(RemindersList.all) { $0.remindersListID.eq($3.id) }
      .select {
        Row.Columns(
          reminder: $0,
          remindersList: $3,
          isPastDue: $0.isPastDue,
          notes: $0.inlineNotes.substr(0, 200),
          tags: #sql("\($2.jsonNames)")
        )
      }
    return query
  }

  enum Ordering: String, CaseIterable {
    case dueDate = "Due Date"
    case manual = "Manual"
    case priority = "Priority"
    case title = "Title"
    var icon: Image {
      switch self {
      case .dueDate: Image(systemName: "calendar")
      case .manual: Image(systemName: "hand.draw")
      case .priority: Image(systemName: "chart.bar.fill")
      case .title: Image(systemName: "textformat.characters")
      }
    }
  }

  @CasePathable
  @dynamicMemberLookup
  enum DetailType: Hashable {
    case all
    case completed
    case flagged
    case remindersList(RemindersList)
    case scheduled
    case tags([Tag])
    case today
  }

  @Selection
  struct Row: Identifiable {
    var id: Reminder.ID { reminder.id }
    let reminder: Reminder
    let remindersList: RemindersList
    let isPastDue: Bool
    let notes: String
    @Column(as: [String].JSONRepresentation.self)
    let tags: [String]
  }
}

struct RemindersDetailView: View {
  @Bindable var model: RemindersDetailModel

  @State var isNavigationTitleVisible = false
  @State var navigationTitleHeight: CGFloat = 36

  var body: some View {
    List {
      VStack(alignment: .leading) {
        GeometryReader { proxy in
          Text(model.detailType.navigationTitle)
            .font(.system(.largeTitle, design: .rounded, weight: .bold))
            .foregroundStyle(model.detailType.color)
            .onAppear { navigationTitleHeight = proxy.size.height }
        }
      }
      .listRowSeparator(.hidden)
      ForEach(model.reminderRows) { row in
        ReminderRow(
          color: model.detailType.color,
          isPastDue: row.isPastDue,
          notes: row.notes,
          reminder: row.reminder,
          remindersList: row.remindersList,
          showCompleted: model.showCompleted,
          tags: row.tags
        )
      }
      .onMove { source, destination in
        Task { await model.move(from: source, to: destination) }
      }
    }
    .onScrollGeometryChange(for: Bool.self) { geometry in
      geometry.contentOffset.y + geometry.contentInsets.top > navigationTitleHeight
    } action: {
      isNavigationTitleVisible = $1
    }
    .listStyle(.plain)
    .sheet(isPresented: $model.isNewReminderSheetPresented) {
      if let remindersList = model.detailType.remindersList {
        NavigationStack {
          ReminderFormView(
            reminder: Reminder.Draft(remindersListID: remindersList.id),
            remindersList: remindersList
          )
            .navigationTitle("New Reminder")
        }
      }
    }
    .toolbar {
      ToolbarItem(placement: .principal) {
        Text(model.detailType.navigationTitle)
          .font(.headline)
          .opacity(isNavigationTitleVisible ? 1 : 0)
          .animation(.default.speed(2), value: isNavigationTitleVisible)
      }
      if model.detailType.is(\.remindersList) {
        ToolbarItem(placement: .bottomBar) {
          HStack {
            Button {
              model.isNewReminderSheetPresented = true
            } label: {
              HStack {
                Image(systemName: "plus.circle.fill")
                Text("New Reminder")
              }
              .bold()
              .font(.title3)
            }
            Spacer()
          }
          .tint(model.detailType.color)
        }
      }
      ToolbarItem(placement: .primaryAction) {
        Menu {
          Group {
            Menu {
              ForEach(RemindersDetailModel.Ordering.allCases, id: \.self) { ordering in
                Button {
                  Task { await model.orderingButtonTapped(ordering) }
                } label: {
                  Text(ordering.rawValue)
                  ordering.icon
                }
              }
            } label: {
              Text("Sort By")
              Text(model.ordering.rawValue)
              Image(systemName: "arrow.up.arrow.down")
            }
            Button {
              Task { await model.showCompletedButtonTapped() }
            } label: {
              Text(model.showCompleted ? "Hide Completed" : "Show Completed")
              Image(systemName: model.showCompleted ? "eye.slash.fill" : "eye")
            }
          }
          .tint(model.detailType.color)
        } label: {
          Image(systemName: "ellipsis.circle")
        }
      }
    }
    .toolbarTitleDisplayMode(.inline)
  }
}

extension RemindersDetailModel.DetailType {
  fileprivate var id: String {
    switch self {
    case .all: "all"
    case .completed: "completed"
    case .flagged: "flagged"
    case .remindersList(let list): "list_\(list.id)"
    case .scheduled: "scheduled"
    case .tags: "tags"
    case .today: "today"
    }
  }
  fileprivate var navigationTitle: String {
    switch self {
    case .all: "All"
    case .completed: "Completed"
    case .flagged: "Flagged"
    case .remindersList(let list): list.title
    case .scheduled: "Scheduled"
    case .tags(let tags):
      switch tags.count {
      case 0: "Tags"
      case 1: "#\(tags[0].title)"
      default: "\(tags.count) tags"
      }
    case .today: "Today"
    }
  }
  fileprivate var color: Color {
    switch self {
    case .all: .black
    case .completed: .gray
    case .flagged: .orange
    case .remindersList(let list): list.color
    case .scheduled: .red
    case .tags: .blue
    case .today: .blue
    }
  }
}

struct RemindersDetailPreview: PreviewProvider {
  static var previews: some View {
    let (remindersList, tag) = try! prepareDependencies {
      $0.defaultDatabase = try Reminders.appDatabase()
      return try $0.defaultDatabase.read { db in
        (
          try RemindersList.all.fetchOne(db)!,
          try Tag.all.fetchOne(db)!
        )
      }
    }
    let detailTypes: [RemindersDetailModel.DetailType] = [
      .all,
      .remindersList(remindersList),
      .tags([tag]),
    ]
    ForEach(detailTypes, id: \.self) { detailType in
      NavigationStack {
        RemindersDetailView(model: RemindersDetailModel(detailType: detailType))
      }
      .previewDisplayName(detailType.navigationTitle)
    }
  }
}



---
File: /RemindersListForm.swift
---

import IssueReporting
import SharingGRDB
import SwiftUI

struct RemindersListForm: View {
  @Dependency(\.defaultDatabase) private var database

  @State var remindersList: RemindersList.Draft
  @Environment(\.dismiss) var dismiss

  init(remindersList: RemindersList.Draft) {
    self.remindersList = remindersList
  }

  var body: some View {
    Form {
      Section {
        VStack {
          TextField("List Name", text: $remindersList.title)
            .font(.system(.title2, design: .rounded, weight: .bold))
            .foregroundStyle(remindersList.color)
            .multilineTextAlignment(.center)
            .padding()
            .textFieldStyle(.plain)
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(.buttonBorder)
      }
      ColorPicker("Color", selection: $remindersList.color)
    }
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem {
        Button("Save") {
          withErrorReporting {
            try database.write { db in
              try RemindersList.upsert { remindersList }
                .execute(db)
            }
          }
          dismiss()
        }
      }
      ToolbarItem(placement: .cancellationAction) {
        Button("Cancel") {
          dismiss()
        }
      }
    }
  }
}

struct RemindersListFormPreviews: PreviewProvider {
  static var previews: some View {
    let _ = try! prepareDependencies {
      $0.defaultDatabase = try Reminders.appDatabase()
    }
    NavigationStack {
      RemindersListForm(remindersList: RemindersList.Draft())
        .navigationTitle("New List")
    }
  }
}



---
File: /RemindersListRow.swift
---

import SharingGRDB
import SwiftUI

struct RemindersListRow: View {
  let remindersCount: Int
  let remindersList: RemindersList

  @State var editList: RemindersList?

  @Dependency(\.defaultDatabase) private var database

  var body: some View {
    HStack {
      Image(systemName: "list.bullet.circle.fill")
        .font(.largeTitle)
        .foregroundStyle(remindersList.color)
        .background(
          Color.white.clipShape(Circle()).padding(4)
        )
      Text(remindersList.title)
      Spacer()
      Text("\(remindersCount)")
        .foregroundStyle(.gray)
    }
    .swipeActions {
      Button {
        withErrorReporting {
          try database.write { db in
            try RemindersList.delete(remindersList)
              .execute(db)
          }
        }
      } label: {
        Image(systemName: "trash")
      }
      .tint(.red)
      Button {
        editList = remindersList
      } label: {
        Image(systemName: "info.circle")
      }
    }
    .sheet(item: $editList) { list in
      NavigationStack {
        RemindersListForm(remindersList: RemindersList.Draft(list))
          .navigationTitle("Edit list")
      }
      .presentationDetents([.medium])
    }
  }
}

#Preview {
  NavigationStack {
    List {
      RemindersListRow(
        remindersCount: 10,
        remindersList: RemindersList(
          id: UUID(),
          title: "Personal"
        )
      )
    }
  }
}



---
File: /RemindersLists.swift
---

import SharingGRDB
import SwiftUI
import SwiftUINavigation
import TipKit

@MainActor
@Observable
class RemindersListsModel {
  @ObservationIgnored
  @FetchAll(
    RemindersList
      .group(by: \.id)
      .order(by: \.position)
      .leftJoin(Reminder.all) { $0.id.eq($1.remindersListID) && !$1.isCompleted }
      .select {
        ReminderListState.Columns(remindersCount: $1.id.count(), remindersList: $0)
      },
    animation: .default
  )
  var remindersLists

  @ObservationIgnored
  @FetchAll(
    Tag
      .order(by: \.title)
      .withReminders
      .having { $2.count().gt(0) }
      .select { tag, _, _ in tag },
    animation: .default
  )
  var tags

  @ObservationIgnored
  @FetchOne(
    Reminder.select {
      Stats.Columns(
        allCount: $0.count(filter: !$0.isCompleted),
        flaggedCount: $0.count(filter: $0.isFlagged),
        scheduledCount: $0.count(filter: $0.isScheduled),
        todayCount: $0.count(filter: $0.isToday)
      )
    }
  )
  var stats = Stats()

  var destination: Destination?
  var searchRemindersModel = SearchRemindersModel()
  var seedDatabaseTip: SeedDatabaseTip?

  @ObservationIgnored
  @Dependency(\.defaultDatabase) private var database

  func statTapped(_ detailType: RemindersDetailModel.DetailType) {
    destination = .detail(RemindersDetailModel(detailType: detailType))
  }

  func remindersListTapped(remindersList: RemindersList) {
    destination = .detail(
      RemindersDetailModel(
        detailType: .remindersList(
          remindersList
        )
      )
    )
  }

  func tagButtonTapped(tag: Tag) {
    destination = .detail(
      RemindersDetailModel(
        detailType: .tags([tag])
      )
    )
  }

  func onAppear() {
    withErrorReporting {
      try Tips.configure()
    }
    if remindersLists.isEmpty {
      seedDatabaseTip = SeedDatabaseTip()
    }
  }

  func newReminderButtonTapped() {
    guard let remindersList = remindersLists.first?.remindersList
    else {
      reportIssue("There must be at least one list.")
      return
    }
    destination = .reminderForm(
      Reminder.Draft(remindersListID: remindersList.id),
      remindersList: remindersList
    )
  }

  func addListButtonTapped() {
    destination = .remindersListForm(RemindersList.Draft())
  }

  func listDetailsButtonTapped(remindersList: RemindersList) {
    destination = .remindersListForm(RemindersList.Draft(remindersList))
  }

  func move(from source: IndexSet, to destination: Int) {
    withErrorReporting {
      try database.write { db in
        var ids = remindersLists.map(\.remindersList.id)
        ids.move(fromOffsets: source, toOffset: destination)
        try RemindersList
          .where { $0.id.in(ids) }
          .update {
            let ids = Array(ids.enumerated())
            let (first, rest) = (ids.first!, ids.dropFirst())
            $0.position =
            rest
              .reduce(Case($0.id).when(first.element, then: first.offset)) { cases, id in
                cases.when(id.element, then: id.offset)
              }
              .else($0.position)
          }
          .execute(db)
      }
    }
  }

  #if DEBUG
  func seedDatabaseButtonTapped() {
    withErrorReporting {
      try database.write { db in
        try db.seedSampleData()
      }
    }
  }
  #endif

  @CasePathable
  enum Destination {
    case detail(RemindersDetailModel)
    case reminderForm(Reminder.Draft, remindersList: RemindersList)
    case remindersListForm(RemindersList.Draft)
  }

  @Selection
  struct ReminderListState: Identifiable {
    var id: RemindersList.ID { remindersList.id }
    var remindersCount: Int
    var remindersList: RemindersList
  }

  @Selection
  struct Stats {
    var allCount = 0
    var flaggedCount = 0
    var scheduledCount = 0
    var todayCount = 0
  }

  struct SeedDatabaseTip: Tip {
    var title: Text {
      Text("Seed Sample Data")
    }
    var message: Text? {
      Text("Tap here to quickly populate the app with test data.")
    }
    var image: Image? {
      Image(systemName: "leaf")
    }
  }
}

struct RemindersListsView: View {
  @Bindable var model: RemindersListsModel

  var body: some View {
    List {
      if model.searchRemindersModel.searchText.isEmpty {
        Section {
          Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 16) {
            GridRow {
              ReminderGridCell(
                color: .blue,
                count: model.stats.todayCount,
                iconName: "calendar.circle.fill",
                title: "Today"
              ) {
                model.statTapped(.today)
              }
              ReminderGridCell(
                color: .red,
                count: model.stats.scheduledCount,
                iconName: "calendar.circle.fill",
                title: "Scheduled"
              ) {
                model.statTapped(.scheduled)
              }
            }
            GridRow {
              ReminderGridCell(
                color: .gray,
                count: model.stats.allCount,
                iconName: "tray.circle.fill",
                title: "All"
              ) {
                model.statTapped(.all)
              }
              ReminderGridCell(
                color: .orange,
                count: model.stats.flaggedCount,
                iconName: "flag.circle.fill",
                title: "Flagged"
              ) {
                model.statTapped(.flagged)
              }
            }
            GridRow {
              ReminderGridCell(
                color: .gray,
                count: nil,
                iconName: "checkmark.circle.fill",
                title: "Completed"
              ) {
                model.statTapped(.completed)
              }
            }
          }
          .buttonStyle(.plain)
          .listRowBackground(Color.clear)
          .padding([.leading, .trailing], -20)
        }

        Section {
          ForEach(model.remindersLists) { state in
            Button {
              model.remindersListTapped(remindersList: state.remindersList)
            } label: {
              RemindersListRow(
                remindersCount: state.remindersCount,
                remindersList: state.remindersList
              )
            }
            .foregroundStyle(.primary)
          }
          .onMove(perform: model.move(from:to:))
        } header: {
          Text("My Lists")
            .font(.system(.title2, design: .rounded, weight: .bold))
            .foregroundStyle(Color(.label))
            .textCase(nil)
            .padding(.top, -16)
            .padding([.leading, .trailing], 4)
        }
        .listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))

        Section {
          ForEach(model.tags) { tag in
            Button {
              model.tagButtonTapped(tag: tag)
            } label: {
              TagRow(tag: tag)
            }
            .foregroundStyle(.primary)
          }
        } header: {
          Text("Tags")
            .font(.system(.title2, design: .rounded, weight: .bold))
            .foregroundStyle(Color(.label))
            .textCase(nil)
            .padding(.top, -16)
            .padding([.leading, .trailing], 4)
        }
        .listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
      } else {
        SearchRemindersView(model: model.searchRemindersModel)
      }
    }
    .onAppear {
      model.onAppear()
    }
    .listStyle(.insetGrouped)
    .toolbar {
      #if DEBUG
      ToolbarItem(placement: .automatic) {
          Menu {
            Button {
              model.seedDatabaseButtonTapped()
            } label: {
              Text("Seed data")
              Image(systemName: "leaf")
            }
          } label: {
            Image(systemName: "ellipsis.circle")
          }
          .popoverTip(model.seedDatabaseTip)
        }
      #endif
      ToolbarItem(placement: .bottomBar) {
        HStack {
          Button {
            model.newReminderButtonTapped()
          } label: {
            HStack {
              Image(systemName: "plus.circle.fill")
              Text("New Reminder")
            }
            .bold()
            .font(.title3)
          }
          Spacer()
          Button {
            model.addListButtonTapped()
          } label: {
            Text("Add List")
              .font(.title3)
          }
        }
      }
    }
    .sheet(item: $model.destination.reminderForm, id: \.0.id) { reminder, remindersList in
      NavigationStack {
        ReminderFormView(reminder: reminder, remindersList: remindersList)
          .navigationTitle("New Reminder")
      }
    }
    .sheet(item: $model.destination.remindersListForm) { remindersList in
      NavigationStack {
        RemindersListForm(remindersList: remindersList)
          .navigationTitle("New List")
      }
      .presentationDetents([.medium])
    }
    .searchable(text: $model.searchRemindersModel.searchText)
    .navigationDestination(item: $model.destination.detail) { detailModel in
      RemindersDetailView(model: detailModel)
    }
  }
}

private struct ReminderGridCell: View {
  let color: Color
  let count: Int?
  let iconName: String
  let title: String
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(alignment: .firstTextBaseline) {
        VStack(alignment: .leading, spacing: 8) {
          Image(systemName: iconName)
            .font(.largeTitle)
            .bold()
            .foregroundStyle(color)
            .background(
              Color.white.clipShape(Circle()).padding(4)
            )
          Text(title)
            .font(.headline)
            .foregroundStyle(.gray)
            .bold()
            .padding(.leading, 4)
        }
        Spacer()
        if let count {
          Text("\(count)")
            .font(.largeTitle)
            .fontDesign(.rounded)
            .bold()
            .foregroundStyle(Color(.label))
        }
      }
      .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
      .background(Color(.secondarySystemGroupedBackground))
      .cornerRadius(10)
    }
  }
}

#Preview {
  let _ = try! prepareDependencies {
    $0.defaultDatabase = try Reminders.appDatabase()
  }
  NavigationStack {
    RemindersListsView(model: RemindersListsModel())
  }
}



---
File: /Schema.swift
---

import Dependencies
import Foundation
import IssueReporting
import OSLog
import SharingGRDB
import SwiftUI

@Table
struct RemindersList: Hashable, Identifiable {
  let id: UUID
  @Column(as: Color.HexRepresentation.self)
  var color = Color(red: 0x4a / 255, green: 0x99 / 255, blue: 0xef / 255)
  var position = 0
  var title = ""
}

extension RemindersList.Draft: Identifiable {}

@Table
struct Reminder: Codable, Equatable, Identifiable {
  let id: UUID
  var dueDate: Date?
  var isCompleted = false
  var isFlagged = false
  var notes = ""
  var position = 0
  var priority: Priority?
  var remindersListID: RemindersList.ID
  var title = ""
}

extension Reminder.Draft: Identifiable {}

@Table
struct Tag: Hashable, Identifiable {
  let id: UUID
  var title = ""
}

enum Priority: Int, Codable, QueryBindable {
  case low = 1
  case medium
  case high
}

extension Reminder {
  static let incomplete = Self.where { !$0.isCompleted }
  static func searching(_ text: String) -> Where<Reminder> {
    Self.where {
      $0.title.collate(.nocase).contains(text)
        || $0.notes.collate(.nocase).contains(text)
    }
  }
  static let withTags = group(by: \.id)
    .leftJoin(ReminderTag.all) { $0.id.eq($1.reminderID) }
    .leftJoin(Tag.all) { $1.tagID.eq($2.id) }
}

extension Reminder.TableColumns {
  var isPastDue: some QueryExpression<Bool> {
    @Dependency(\.date.now) var now
    return !isCompleted && #sql("coalesce(date(\(dueDate)) < date(\(now)), 0)")
  }
  var isToday: some QueryExpression<Bool> {
    @Dependency(\.date.now) var now
    return !isCompleted && #sql("coalesce(date(\(dueDate)) = date(\(now)), 0)")
  }
  var isScheduled: some QueryExpression<Bool> {
    !isCompleted && dueDate.isNot(nil)
  }
  var inlineNotes: some QueryExpression<String> {
    notes.replace("\n", " ")
  }
}

extension Tag {
  static let withReminders = group(by: \.id)
    .leftJoin(ReminderTag.all) { $0.id.eq($1.tagID) }
    .leftJoin(Reminder.all) { $1.reminderID.eq($2.id) }
}

extension Tag.TableColumns {
  var jsonNames: some QueryExpression<[String].JSONRepresentation> {
    self.title.jsonGroupArray(filter: self.title.isNot(nil))
  }
}

@Table("remindersTags")
struct ReminderTag: Hashable, Identifiable {
  let id: UUID
  var reminderID: Reminder.ID
  var tagID: Tag.ID
}

func appDatabase() throws -> any DatabaseWriter {
  @Dependency(\.context) var context
  let database: any DatabaseWriter
  var configuration = Configuration()
  configuration.foreignKeysEnabled = true
  configuration.prepareDatabase { db in
    #if DEBUG
      db.trace(options: .profile) {
        if context == .live {
          logger.debug("\($0.expandedDescription)")
        } else {
          print("\($0.expandedDescription)")
        }
      }
    #endif
  }
  if context == .preview {
    database = try DatabaseQueue(configuration: configuration)
  } else {
    let path =
      context == .live
      ? URL.documentsDirectory.appending(component: "db.sqlite").path()
      : URL.temporaryDirectory.appending(component: "\(UUID().uuidString)-db.sqlite").path()
    logger.info("open \(path)")
    database = try DatabasePool(path: path, configuration: configuration)
  }
  var migrator = DatabaseMigrator()
  #if DEBUG
    migrator.eraseDatabaseOnSchemaChange = true
  #endif
  migrator.registerMigration("Create initial tables") { db in
    try #sql(
      """
      CREATE TABLE "remindersLists" (
        "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
        "color" INTEGER NOT NULL DEFAULT \(raw: 0x4a99_ef00),
        "position" INTEGER NOT NULL DEFAULT 0,
        "title" TEXT NOT NULL
      ) STRICT
      """
    )
    .execute(db)
    try #sql(
      """
      CREATE TABLE "reminders" (
        "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
        "dueDate" TEXT,
        "isCompleted" INTEGER NOT NULL DEFAULT 0,
        "isFlagged" INTEGER NOT NULL DEFAULT 0,
        "notes" TEXT,
        "position" INTEGER NOT NULL DEFAULT 0,
        "priority" INTEGER,
        "remindersListID" TEXT NOT NULL,
        "title" TEXT NOT NULL,

        FOREIGN KEY("remindersListID") REFERENCES "remindersLists"("id") ON DELETE CASCADE
      ) STRICT
      """
    )
    .execute(db)
    try #sql(
      """
      CREATE TABLE "tags" (
        "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
        "title" TEXT NOT NULL COLLATE NOCASE
      ) STRICT
      """
    )
    .execute(db)
    try #sql(
      """
      CREATE TABLE "remindersTags" (
        "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
        "reminderID" TEXT NOT NULL,
        "tagID" TEXT NOT NULL,

        FOREIGN KEY("reminderID") REFERENCES "reminders"("id") ON DELETE CASCADE,
        FOREIGN KEY("tagID") REFERENCES "tags"("id") ON DELETE CASCADE
      ) STRICT
      """
    )
    .execute(db)
  }

  try migrator.migrate(database)

  if context == .preview {
    try database.write { db in
      try db.seedSampleData()
    }
  }

  try database.write { db in
    try #sql(
      """
      CREATE TEMPORARY TRIGGER "default_position_reminders_lists" 
      AFTER INSERT ON "remindersLists"
      FOR EACH ROW BEGIN
        UPDATE "remindersLists"
        SET "position" = (SELECT max("position") + 1 FROM "remindersLists")
        WHERE "id" = NEW."id";
      END
      """
    )
    .execute(db)
    try #sql(
      """
      CREATE TEMPORARY TRIGGER "default_position_reminders" 
      AFTER INSERT ON "reminders"
      FOR EACH ROW BEGIN
        UPDATE "reminders"
        SET "position" = (SELECT max("position") + 1 FROM "reminders")
        WHERE "id" = NEW."id";
      END
      """
    )
    .execute(db)
    try #sql(
      """
      CREATE TEMPORARY TRIGGER "non_empty_reminders_lists" 
      AFTER DELETE ON "remindersLists"
      FOR EACH ROW BEGIN
        INSERT INTO "remindersLists"
        ("title", "color")
        SELECT 'Personal', \(raw: 0x4a99ef)
        WHERE (SELECT count(*) FROM "remindersLists") = 0;
      END
      """
    )
    .execute(db)
  }

  return database
}

private let logger = Logger(subsystem: "Reminders", category: "Database")

#if DEBUG
  extension Database {
    func seedSampleData() throws {
      let remindersListIDs = (0...2).map { _ in UUID() }
      let reminderIDs = (0...10).map { _ in UUID() }
      let tagIDs = (0...6).map { _ in UUID() }
      try seed {
        RemindersList(
          id: remindersListIDs[0],
          color: Color(red: 0x4a / 255, green: 0x99 / 255, blue: 0xef / 255),
          title: "Personal"
        )
        RemindersList(
          id: remindersListIDs[1],
          color: Color(red: 0xed / 255, green: 0x89 / 255, blue: 0x35 / 255),
          title: "Family"
        )
        RemindersList(
          id: remindersListIDs[2],
          color: Color(red: 0xb2 / 255, green: 0x5d / 255, blue: 0xd3 / 255),
          title: "Business"
        )
        Reminder(
          id: reminderIDs[0],
          notes: "Milk\nEggs\nApples\nOatmeal\nSpinach",
          remindersListID: remindersListIDs[0],
          title: "Groceries"
        )
        Reminder(
          id: reminderIDs[1],
          dueDate: Date().addingTimeInterval(-60 * 60 * 24 * 2),
          isFlagged: true,
          remindersListID: remindersListIDs[0],
          title: "Haircut"
        )
        Reminder(
          id: reminderIDs[2],
          dueDate: Date(),
          notes: "Ask about diet",
          priority: .high,
          remindersListID: remindersListIDs[0],
          title: "Doctor appointment"
        )
        Reminder(
          id: reminderIDs[3],
          dueDate: Date().addingTimeInterval(-60 * 60 * 24 * 190),
          isCompleted: true,
          remindersListID: remindersListIDs[0],
          title: "Take a walk"
        )
        Reminder(
          id: reminderIDs[4],
          dueDate: Date(),
          remindersListID: remindersListIDs[0],
          title: "Buy concert tickets"
        )
        Reminder(
          id: reminderIDs[5],
          dueDate: Date().addingTimeInterval(60 * 60 * 24 * 2),
          isFlagged: true,
          priority: .high,
          remindersListID: remindersListIDs[1],
          title: "Pick up kids from school"
        )
        Reminder(
          id: reminderIDs[6],
          dueDate: Date().addingTimeInterval(-60 * 60 * 24 * 2),
          isCompleted: true,
          priority: .low,
          remindersListID: remindersListIDs[1],
          title: "Get laundry"
        )
        Reminder(
          id: reminderIDs[7],
          dueDate: Date().addingTimeInterval(60 * 60 * 24 * 4),
          isCompleted: false,
          priority: .high,
          remindersListID: remindersListIDs[1],
          title: "Take out trash"
        )
        Reminder(
          id: reminderIDs[8],
          dueDate: Date().addingTimeInterval(60 * 60 * 24 * 2),
          notes: """
            Status of tax return
            Expenses for next year
            Changing payroll company
            """,
          remindersListID: remindersListIDs[2],
          title: "Call accountant"
        )
        Reminder(
          id: reminderIDs[9],
          dueDate: Date().addingTimeInterval(-60 * 60 * 24 * 2),
          isCompleted: true,
          priority: .medium,
          remindersListID: remindersListIDs[2],
          title: "Send weekly emails"
        )
        Reminder(
          id: reminderIDs[10],
          dueDate: Date().addingTimeInterval(60 * 60 * 24 * 2),
          isCompleted: false,
          remindersListID: remindersListIDs[2],
          title: "Prepare for WWDC"
        )
        Tag(id: tagIDs[0], title: "car")
        Tag(id: tagIDs[1], title: "kids")
        Tag(id: tagIDs[2], title: "someday")
        Tag(id: tagIDs[3], title: "optional")
        Tag(id: tagIDs[4], title: "social")
        Tag(id: tagIDs[5], title: "night")
        Tag(id: tagIDs[6], title: "adulting")
        ReminderTag.Draft(reminderID: reminderIDs[0], tagID: tagIDs[2])
        ReminderTag.Draft(reminderID: reminderIDs[0], tagID: tagIDs[3])
        ReminderTag.Draft(reminderID: reminderIDs[0], tagID: tagIDs[6])
        ReminderTag.Draft(reminderID: reminderIDs[1], tagID: tagIDs[2])
        ReminderTag.Draft(reminderID: reminderIDs[1], tagID: tagIDs[3])
        ReminderTag.Draft(reminderID: reminderIDs[2], tagID: tagIDs[6])
        ReminderTag.Draft(reminderID: reminderIDs[3], tagID: tagIDs[0])
        ReminderTag.Draft(reminderID: reminderIDs[3], tagID: tagIDs[1])
        ReminderTag.Draft(reminderID: reminderIDs[4], tagID: tagIDs[4])
        ReminderTag.Draft(reminderID: reminderIDs[3], tagID: tagIDs[4])
        ReminderTag.Draft(reminderID: reminderIDs[10], tagID: tagIDs[4])
        ReminderTag.Draft(reminderID: reminderIDs[4], tagID: tagIDs[5])
      }
    }
  }
#endif



---
File: /SearchReminders.swift
---

import IssueReporting
import SharingGRDB
import SwiftUI

@MainActor
@Observable
class SearchRemindersModel {
  var showCompletedInSearchResults = false
  var searchText = "" {
    didSet {
      Task { await updateQuery() }
    }
  }

  @ObservationIgnored @FetchOne var completedCount: Int = 0
  @ObservationIgnored @FetchAll var reminders: [Row]

  @ObservationIgnored @Dependency(\.defaultDatabase) private var database

  func showCompletedButtonTapped() async {
    showCompletedInSearchResults.toggle()
    await updateQuery()
  }

  func deleteCompletedReminders(monthsAgo: Int? = nil) {
    withErrorReporting {
      try database.write { db in
        try Reminder
          .searching(searchText)
          .where(\.isCompleted)
          .where {
            if let monthsAgo {
              #sql("\($0.dueDate) < date('now', '-\(raw: monthsAgo) months')")
            }
          }
          .delete()
          .execute(db)
      }
    }
  }

  private func updateQuery() async {
    await withErrorReporting {
      if searchText.isEmpty {
        showCompletedInSearchResults = false
      }
      try await $completedCount.load(
        Reminder.searching(searchText)
          .where(\.isCompleted)
          .count(),
        animation: .default
      )
      try await $reminders.load(
        Reminder
          .searching(searchText)
          .where {
            if !showCompletedInSearchResults {
              !$0.isCompleted
            }
          }
          .order { ($0.isCompleted, $0.dueDate) }
          .withTags
          .join(RemindersList.all) { $0.remindersListID.eq($3.id) }
          .select {
            Row.Columns(
              isPastDue: $0.isPastDue,
              notes: $0.inlineNotes,
              reminder: $0,
              remindersList: $3,
              tags: #sql("\($2.jsonNames)")
            )
          },
        animation: .default
      )
    }
  }

  @Selection
  struct Row: Identifiable {
    var id: Reminder.ID { reminder.id }
    let isPastDue: Bool
    let notes: String
    let reminder: Reminders.Reminder
    let remindersList: RemindersList
    @Column(as: [String].JSONRepresentation.self)
    let tags: [String]
  }
}

struct SearchRemindersView: View {
  let model: SearchRemindersModel

  init(model: SearchRemindersModel) {
    self.model = model
  }

  var body: some View {
    HStack {
      Text("\(model.completedCount) Completed")
        .monospacedDigit()
        .contentTransition(.numericText())
      if model.completedCount > 0 {
        Text("•")
        Menu {
          Text("Clear Completed Reminders")
          Button("Older Than 1 Month") {
            model.deleteCompletedReminders(monthsAgo: 1)
          }
          Button("Older Than 6 Months") {
            model.deleteCompletedReminders(monthsAgo: 6)
          }
          Button("Older Than 1 year") {
            model.deleteCompletedReminders(monthsAgo: 12)
          }
          Button("All Completed") {
            model.deleteCompletedReminders()
          }
        } label: {
          Text("Clear")
        }
        Spacer()
        Button(model.showCompletedInSearchResults ? "Hide" : "Show") {
          Task { await model.showCompletedButtonTapped() }
        }
      }
    }
    .buttonStyle(.borderless)

    ForEach(model.reminders) { reminder in
      ReminderRow(
        color: reminder.remindersList.color,
        isPastDue: reminder.isPastDue,
        notes: reminder.notes,
        reminder: reminder.reminder,
        remindersList: reminder.remindersList,
        showCompleted: model.showCompletedInSearchResults,
        tags: reminder.tags
      )
    }
  }
}

#Preview {
  @Previewable @State var searchText = "take"
  let _ = try! prepareDependencies {
    $0.defaultDatabase = try Reminders.appDatabase()
  }

  NavigationStack {
    List {
      if !searchText.isEmpty {
        SearchRemindersView(model: SearchRemindersModel())
      } else {
        Text(#"Tap "Search"..."#)
      }
    }
    .searchable(text: $searchText)
  }
}



---
File: /TagRow.swift
---

import SharingGRDB
import SwiftUI

struct TagRow: View {
  let tag: Tag
  @Dependency(\.defaultDatabase) var database
  var body: some View {
    HStack {
      Image(systemName: "number.circle.fill")
        .font(.largeTitle)
        .foregroundStyle(.gray)
        .background(
          Color.white.clipShape(Circle()).padding(4)
        )
      Text(tag.title)
      Spacer()
    }
    .swipeActions {
      Button {
        withErrorReporting {
          try database.write { db in
            try Tag.delete(tag)
              .execute(db)
          }
        }
      } label: {
        Image(systemName: "trash")
      }
      .tint(.red)
    }
  }
}

#Preview {
  NavigationStack {
    List {
      TagRow(tag: Tag(id: UUID(1), title: "optional"))
    }
  }
}



---
File: /TagsForm.swift
---

import SharingGRDB
import SwiftUI

struct TagsView: View {
  @Fetch(Tags()) var tags = Tags.Value()
  @Binding var selectedTags: [Tag]

  @Environment(\.dismiss) var dismiss

  var body: some View {
    Form {
      let selectedTagIDs = Set(selectedTags.map(\.id))
      if !tags.top.isEmpty {
        Section {
          ForEach(tags.top, id: \.id) { tag in
            TagView(
              isSelected: selectedTagIDs.contains(tag.id),
              selectedTags: $selectedTags,
              tag: tag
            )
          }
        } header: {
          Text("Top tags")
        }
      }
      if !tags.rest.isEmpty {
        Section {
          ForEach(tags.rest) { tag in
            TagView(
              isSelected: selectedTagIDs.contains(tag.id),
              selectedTags: $selectedTags,
              tag: tag
            )
          }
        }
      }
    }
    .toolbar {
      ToolbarItem {
        Button("Done") { dismiss() }
      }
    }
    .navigationTitle(Text("Tags"))
  }

  struct Tags: FetchKeyRequest {
    func fetch(_ db: Database) throws -> Value {
      let top =
        try Tag
        .withReminders
        .having { $2.count().gt(0) }
        .order { ($2.count().desc(), $0.title) }
        .select { tag, _, _ in tag }
        .limit(3)
        .fetchAll(db)

      let rest =
        try Tag
        .where { !$0.id.in(top.map(\.id)) }
        .order(by: \.title)
        .fetchAll(db)

      return Value(rest: rest, top: top)
    }
    struct Value {
      var rest: [Tag] = []
      var top: [Tag] = []
    }
  }
}

private struct TagView: View {
  let isSelected: Bool
  @Binding var selectedTags: [Tag]
  let tag: Tag

  var body: some View {
    Button {
      if isSelected {
        selectedTags.removeAll(where: { $0.id == tag.id })
      } else {
        selectedTags.append(tag)
      }
    } label: {
      HStack {
        if isSelected {
          Image.init(systemName: "checkmark")
        }
        Text(tag.title)
      }
    }
    .tint(isSelected ? .accentColor : .primary)
  }
}

#Preview {
  @Previewable @State var tags: [Tag] = []
  let _ = try! prepareDependencies {
    $0.defaultDatabase = try Reminders.appDatabase()
  }

  TagsView(selectedTags: $tags)
}

