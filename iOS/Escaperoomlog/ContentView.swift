import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager

    @State private var showingAdd = false
    @State private var showingPaywall = false
    @State private var showingSettings = false
    @State private var editingItem: Room?

    var body: some View {
        NavigationStack {
            ZStack {
                EscaperoomlogTheme.background.ignoresSafeArea()
                if store.items.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .navigationTitle("Escape Room Log")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        if store.canAddMore || purchases.isPro {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
        }
        .sheet(isPresented: $showingAdd) {
            EntryFormView(itemToEdit: nil) { newItem in
                store.add(newItem)
            }
        }
        .sheet(item: $editingItem) { item in
            EntryFormView(itemToEdit: item) { updated in
                store.update(updated)
            }
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundStyle(EscaperoomlogTheme.accentBright)
            Text("No rooms yet")
                .font(EscaperoomlogTheme.headlineFont)
                .foregroundStyle(.white)
            Text("Tap + to log your first one.")
                .font(EscaperoomlogTheme.captionFont)
                .foregroundStyle(.white.opacity(0.7))
        }
    }

    private var list: some View {
        List {
            ForEach(store.items) { item in
                Button {
                    editingItem = item
                } label: {
                    row(for: item)
                }
                .accessibilityIdentifier("row_\(item.id.uuidString)")
            }
            .onDelete { offsets in
                store.delete(at: offsets)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private func row(for item: Room) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.venue).font(EscaperoomlogTheme.headlineFont).foregroundStyle(EscaperoomlogTheme.ink)
            Text(item.completionTime).font(EscaperoomlogTheme.bodyFont).foregroundStyle(EscaperoomlogTheme.secondaryInk)
            Text(item.outcome).font(EscaperoomlogTheme.captionFont).foregroundStyle(EscaperoomlogTheme.secondaryInk)
            HStack(spacing: 2) {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= item.rating ? "star.fill" : "star")
                        .font(.caption2)
                        .foregroundStyle(EscaperoomlogTheme.accent)
                }
            }
        }
        .padding(.vertical, 6)
        .listRowBackground(EscaperoomlogTheme.cardBackground)
    }
}

struct EntryFormView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: Store
    let itemToEdit: Room?
    let onSave: (Room) -> Void

    @State private var venue: String
    @State private var completionTime: String
    @State private var outcome: String
    @State private var rating: Int
    @FocusState private var focusedField: Bool

    init(itemToEdit: Room?, onSave: @escaping (Room) -> Void) {
        self.itemToEdit = itemToEdit
        self.onSave = onSave
        _venue = State(initialValue: itemToEdit?.venue ?? "")
        _completionTime = State(initialValue: itemToEdit?.completionTime ?? "")
        _outcome = State(initialValue: itemToEdit?.outcome ?? "")
        _rating = State(initialValue: itemToEdit?.rating ?? 3)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Venue") {
                    TextField("Venue", text: $\venue)
                        .focused($focusedField)
                        .accessibilityIdentifier("field_venue")
                }
                Section("Time") {
                    TextField("Time", text: $\completionTime)
                        .accessibilityIdentifier("field_completionTime")
                }
                Section("Outcome") {
                    TextField("Outcome", text: $\outcome, axis: .vertical)
                        .accessibilityIdentifier("field_outcome")
                }
                Section("Rating") {
                    Picker("Rating", selection: $rating) {
                        ForEach(1...5, id: \.self) { Text("\($0)").tag($0) }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = false
            }
            .navigationTitle(itemToEdit == nil ? "New Entry" : "Edit Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let base = itemToEdit ?? Room(venue: venue, completionTime: completionTime, outcome: outcome)
                        var updated = base
                        updated.venue = venue
                        updated.completionTime = completionTime
                        updated.outcome = outcome
                        updated.rating = rating
                        onSave(updated)
                        dismiss()
                    }
                    .disabled(venue.trimmingCharacters(in: .whitespaces).isEmpty)
                    .accessibilityIdentifier("saveButton")
                }
            }
        }
    }
}
