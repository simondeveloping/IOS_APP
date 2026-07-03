//
//  MyOrdersView.swift
//  App
//
//  Created by Merry on 19.06.26.
//
import SwiftUI

struct MyOrdersView: View {
    @ObservedObject var viewModel: MyOrdersViewModel
    @State private var orderToEdit: Order?
    @State private var orderToDelete: Order?
    @State private var showScanner = false

    var body: some View {
        VStack(spacing: 0) {

            // Erfolgs-Banner
            if viewModel.showSuccessBanner {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Auftrag erfolgreich erstellt!")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Spacer()
                }
                .padding()
                .background(Color.green.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)
                .padding(.top, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            Group {
                if viewModel.isLoading && viewModel.orders.isEmpty {
                    ProgressView()
                } else if viewModel.orders.isEmpty {
                    ContentUnavailableView(
                        "Keine Aufträge",
                        systemImage: "doc.text",
                        description: Text("Du hast noch keine Aufträge erstellt.")
                    )
                } else {
                    List {
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.footnote)
                                .foregroundStyle(.red)
                        }

                        ForEach(viewModel.orders) { order in
                            OrderRowView(order: order)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        orderToDelete = order
                                    } label: {
                                        Label("Löschen", systemImage: "trash")
                                    }

                                    Button {
                                        orderToEdit = order
                                    } label: {
                                        Label("Bearbeiten", systemImage: "pencil")
                                    }
                                    .tint(.blue)
                                }
                        }
                    }
                    .refreshable {
                        await viewModel.fetchMyOrders()
                    }
                }
            }
        }
        .task {
            await viewModel.fetchMyOrders()
            await viewModel.loadCategories()
        }
        .onChange(of: viewModel.showSuccessBanner) { _, isShowing in
            if isShowing {
                Task {
                    try? await Task.sleep(for: .seconds(3))
                    withAnimation {
                        viewModel.showSuccessBanner = false
                    }
                }
            }
        }
        .sheet(isPresented: $showScanner) {
            OrderScannerSheetView()
        }
        .sheet(item: $orderToEdit) { order in
            EditOrderView(
                order: order,
                categories: viewModel.categories,
                isSaving: viewModel.isSaving,
                errorMessage: viewModel.errorMessage
            ) { draft in
                await viewModel.updateOrder(order, draft: draft)
            }
        }
        .alert("Auftrag löschen?", isPresented: deleteAlertBinding) {
            Button("Abbrechen", role: .cancel) {
                orderToDelete = nil
            }
            Button("Löschen", role: .destructive) {
                guard let orderToDelete else { return }
                Task {
                    await viewModel.deleteOrder(orderToDelete)
                    self.orderToDelete = nil
                }
            }
        } message: {
            Text("Dieser Auftrag wird dauerhaft gelöscht.")
        }
    }

    private var deleteAlertBinding: Binding<Bool> {
        Binding(
            get: { orderToDelete != nil },
            set: { isPresented in
                if !isPresented {
                    orderToDelete = nil
                }
            }
        )
    }
}

private struct OrderRowView: View {
    let order: Order

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(order.title)
                .font(.headline)

            Text(order.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            HStack(spacing: 12) {
                Label(order.location, systemImage: "mappin.and.ellipse")
                Label(order.date.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            if let price = order.price {
                Text(price, format: .currency(code: Locale.current.currency?.identifier ?? "EUR"))
                    .font(.caption)
                    .fontWeight(.semibold)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct EditOrderView: View {
    let order: Order
    let categories: [Category]
    let isSaving: Bool
    let errorMessage: String?
    let onSave: (EditOrderDraft) async -> Bool

    @Environment(\.dismiss) private var dismiss
    @State private var title: String
    @State private var description: String
    @State private var price: String
    @State private var categoryId: Int?
    @State private var location: String
    @State private var date: Date
    @State private var isFlexibleTime: Bool
    @State private var notes: String

    init(
        order: Order,
        categories: [Category],
        isSaving: Bool,
        errorMessage: String?,
        onSave: @escaping (EditOrderDraft) async -> Bool
    ) {
        self.order = order
        self.categories = categories
        self.isSaving = isSaving
        self.errorMessage = errorMessage
        self.onSave = onSave
        _title = State(initialValue: order.title)
        _description = State(initialValue: order.description)
        _price = State(initialValue: order.price.map { String($0) } ?? "")
        _categoryId = State(initialValue: order.categoryId.map { Int($0) })
        _location = State(initialValue: order.location)
        _date = State(initialValue: order.date)
        _isFlexibleTime = State(initialValue: order.isFlexibleTime)
        _notes = State(initialValue: order.notes)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Auftrag") {
                    TextField("Titel", text: $title)
                    TextField("Ort", text: $location)
                    TextField("Preis", text: $price)
                        .keyboardType(.decimalPad)
                    DatePicker("Datum", selection: $date, displayedComponents: .date)
                    Toggle("Flexible Uhrzeit", isOn: $isFlexibleTime)
                }

                Section("Kategorie") {
                    if categories.isEmpty {
                        Text("Keine Kategorien verfügbar")
                            .foregroundStyle(.secondary)
                    } else {
                        Picker("Kategorie", selection: $categoryId) {
                            Text("Keine Kategorie").tag(nil as Int?)
                            ForEach(categories) { category in
                                Text(category.title).tag(Optional(category.id))
                            }
                        }
                    }
                }

                Section("Beschreibung") {
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                }

                Section("Hinweise") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Auftrag bearbeiten")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                    .disabled(isSaving)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            let draft = EditOrderDraft(
                                title: title,
                                description: description,
                                price: price,
                                categoryId: categoryId,
                                location: location,
                                date: date,
                                isFlexibleTime: isFlexibleTime,
                                notes: notes
                            )

                            if await onSave(draft) {
                                dismiss()
                            }
                        }
                    } label: {
                        if isSaving {
                            ProgressView()
                        } else {
                            Text("Speichern")
                        }
                    }
                    .disabled(isSaving)
                }
            }
        }
    }
}
