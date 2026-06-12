//
//  ErstellenView.swift
//  App
//
//  Created by Merry on 29.05.26.
//
import SwiftUI

struct ErstellenView: View {

    @StateObject private var vm = ErstellenViewModel()

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(spacing: 20) {

                    // Titel
                    VStack(alignment: .leading, spacing: 6) {

                        Text("Was ist zu tun?")
                            .font(.headline)
                            .fontWeight(.bold)

                        TextField(
                            "z.B. Glühbirne wechseln",
                            text: $vm.title
                        )
                        .textFieldStyle(.roundedBorder)
                    }

                    // Beschreibung
                    VStack(alignment: .leading, spacing: 6) {

                        Text("Beschreibung")
                            .font(.headline)
                            .fontWeight(.bold)

                        ZStack(alignment: .topLeading) {

                            if vm.description.isEmpty {
                                Text("z.B. Die Glühbirne im Flur ist defekt und muss ausgetauscht werden.")
                                    .foregroundStyle(.tertiary)
                                    .padding(.horizontal, 5)
                                    .padding(.top, 8)
                            }

                            TextEditor(text: $vm.description)
                                .frame(height: 120)
                                .scrollContentBackground(.hidden)
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.gray.opacity(0.3))
                        )
                    }

                    // Preis
                    VStack(alignment: .leading, spacing: 6) {

                        Text("Preisvorstellung")
                            .font(.headline)
                            .fontWeight(.bold)

                        TextField(
                            "z.B. 20 €",
                            text: $vm.price
                        )
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                    }

                    // Kategorie
                    VStack(alignment: .leading, spacing: 6) {

                        Text("Kategorie")
                            .font(.headline)
                            .fontWeight(.bold)

                        if let error = vm.categoriesError {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)

                        } else if vm.categories.isEmpty {
                            HStack {
                                Text("Lade Kategorien…")
                                    .foregroundStyle(.secondary)
                                Spacer()
                                ProgressView()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )

                        } else {
                            Menu {
                                ForEach(vm.categories) { category in
                                    Button(category.title) {
                                        vm.categoryId = category.id
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(vm.categories.first(where: { $0.id == vm.categoryId })?.title ?? "Kategorie wählen")
                                        .foregroundStyle(vm.categoryId == nil ? .secondary : .primary)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundStyle(.secondary)
                                        .font(.subheadline)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(Color(.systemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                            }
                        }
                    }

                    // Ort
                    VStack(alignment: .leading, spacing: 6) {

                        Text("Ort")
                            .font(.headline)
                            .fontWeight(.bold)

                        TextField(
                            "z.B. München, Maxvorstadt",
                            text: $vm.location
                        )
                        .textFieldStyle(.roundedBorder)
                    }

                    // Datum
                    VStack(alignment: .leading, spacing: 6) {

                        Text("Datum")
                            .font(.headline)
                            .fontWeight(.bold)

                        DatePicker(
                            "Datum wählen",
                            selection: $vm.date,
                            displayedComponents: .date
                        )
                        .labelsHidden()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // Flexible Uhrzeit
                    Toggle(isOn: $vm.flexibleTime) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Flexible Uhrzeit")
                                .font(.headline)
                                .fontWeight(.bold)
                            Text("Ich bin zeitlich flexibel")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    // Hinweise
                    VStack(alignment: .leading, spacing: 6) {

                        Text("Zusätzliche Hinweise")
                            .font(.headline)
                            .fontWeight(.bold)

                        ZStack(alignment: .topLeading) {

                            if vm.notes.isEmpty {
                                Text("z.B. Bitte Werkzeug mitbringen, Parkplatz vorhanden.")
                                    .foregroundStyle(.tertiary)
                                    .padding(.horizontal, 5)
                                    .padding(.top, 8)
                            }

                            TextEditor(text: $vm.notes)
                                .frame(height: 100)
                                .scrollContentBackground(.hidden) 
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.gray.opacity(0.3))
                        )
                    }

                    Button {

                        Task {
                            await vm.createJob()
                        }

                    } label: {

                        if vm.isLoading {
                            ProgressView()
                        } else {
                            Text("Veröffentlichen")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)

                }
                .padding()
            }
            .navigationTitle("Auftrag erstellen")
            .task {
                await vm.loadCategories()
            }
        }
    }
}

#Preview {
    ErstellenView()
}
