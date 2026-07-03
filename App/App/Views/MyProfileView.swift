//
//  MyProfileView.swift
//  App
//
//  Created by Boromir on 19.06.26.
//

import SwiftUI

struct MyProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()

    @AppStorage("userId") var userId: Int = 0
    @AppStorage("userVorname") var userVorname: String = ""
    @AppStorage("userNachname") var userNachname: String = ""
    @AppStorage("userAvatar") var userAvatar: String = ""

    @State private var vorname: String = ""
    @State private var nachname: String = ""
    @State private var email: String = ""

    var body: some View {
        Form {
            Section {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        profileAvatarView

                        Text("Profil bearbeiten")
                            .font(.headline)
                    }
                    Spacer()
                }
                .padding(.vertical, 8)
            }

            Section("Persönliche Daten") {
                TextField("Vorname", text: $vorname)
                    .autocorrectionDisabled()
                TextField("Nachname", text: $nachname)
                    .autocorrectionDisabled()
                TextField("E-Mail", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
            }

            Section {
                Button(action: saveProfile) {
                    if viewModel.isSaving {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Speichern")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(viewModel.isSaving)
            }

            if let error = viewModel.errorMessage {
                Section {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
        }
        .navigationTitle("Mein Profil")
        .task {
            await viewModel.loadProfile(for: userId)
            if let profile = viewModel.profile {
                vorname = profile.Vorname
                nachname = profile.Nachname
                email = profile.email
            } else {
                vorname = userVorname
                nachname = userNachname
            }
        }
        .onChange(of: viewModel.profile) { _, newProfile in
            guard let profile = newProfile else { return }
            vorname = profile.Vorname
            nachname = profile.Nachname
            email = profile.email
        }
    }

    @ViewBuilder
    private var profileAvatarView: some View {
        if !userAvatar.isEmpty, let url = avatarURL(path: userAvatar) {
            AsyncImage(url: url) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                } else if phase.error != nil {
                    fallbackAvatar
                } else {
                    ProgressView()
                }
            }
            .frame(width: 80, height: 80)
            .clipShape(Circle())
        } else {
            fallbackAvatar
        }
    }

    private var fallbackAvatar: some View {
        Image(systemName: "person.crop.circle.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 80, height: 80)
            .foregroundColor(.gray)
    }

    private func avatarURL(path: String) -> URL? {
        if path.hasPrefix("http://") || path.hasPrefix("https://") {
            return URL(string: path)
        }
        let encoded = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? path
        return URL(string: "https://ymwiiobmwzhdyvmpnebg.supabase.co/storage/v1/object/public/avatar/\(encoded)")
    }

    private func saveProfile() {
        guard !vorname.trimmingCharacters(in: .whitespaces).isEmpty,
              !nachname.trimmingCharacters(in: .whitespaces).isEmpty,
              !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            viewModel.errorMessage = "Bitte fülle alle Felder aus"
            return
        }

        Task {
            await viewModel.updateProfile(
                vorname: vorname.trimmingCharacters(in: .whitespaces),
                nachname: nachname.trimmingCharacters(in: .whitespaces),
                email: email.trimmingCharacters(in: .whitespaces).lowercased(),
                userId: userId
            )
        }
    }
}
