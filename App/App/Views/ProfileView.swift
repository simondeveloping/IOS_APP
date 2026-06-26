//
//  ProfileView.swift
//  App
//
//  Created by Boromir on 19.06.26.
//


import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()

    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("userVorname") var userVorname: String = ""
    @AppStorage("userNachname") var userNachname: String = ""
    @AppStorage("userId") var userId: Int = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    
                    HStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                            .foregroundColor(.gray)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            // Hier ist der Name jetzt dynamisch!
                            HStack(){
                                Text(userVorname.isEmpty ? "Benutzer" : userVorname)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Text(userNachname.isEmpty ? " " : userNachname)
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                           
                            Text("Privatperson")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "star")
                                    .font(.caption)
                                Text("\(String(format: "%.1f", viewModel.averageRating).replacingOccurrences(of: ".", with: ",")) (\(viewModel.ratingCount) Bewertungen)")
                                    .font(.caption)
                            }
                            .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 5)
                    
                    VStack(spacing: 0) {
                        NavigationLink(destination: MyProfileView()) {
                            ProfileRow(icon: "person", title: "Mein Profil", subtitle: "Öffentliches Profil anzeigen und bearbeiten", trailingIcon: "")
                        }
                    }
                    .modifier(CardModifier())
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Aufträge")
                            .font(.headline)
                            .padding(.horizontal, 5)
                        
                        VStack(spacing: 0) {
                            ProfileRow(icon: "calendar", title: "Meine Aufträge", subtitle: "Angebotene und angenommene Aufträge")
                            Divider().padding(.leading, 45)
                            ProfileRow(icon: "message", title: "Meine Anfragen", subtitle: "Anfragen, die ich gestellt habe")
                            Divider().padding(.leading, 45)
                            NavigationLink(destination: BewertungenView(userId: userId)) {
                                ProfileRow(icon: "bell", title: "Bewertungen", subtitle: "Erhaltene und abgegebene Bewertungen", trailingIcon: "")
                            }
                        }
                        .modifier(CardModifier())
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Einstellungen")
                            .font(.headline)
                            .padding(.horizontal, 5)
                        
                        VStack(spacing: 0) {
                            ProfileRow(icon: "gearshape", title: "Benachrichtigungen", subtitle: "Einstellungen anpassen")
                            Divider().padding(.leading, 45)
                            ProfileRow(icon: "creditcard", title: "Zahlungsmethoden", subtitle: "Verwalte deine Zahlungsarten")
                            Divider().padding(.leading, 45)
                            
                        }
                        .modifier(CardModifier())
                    }
                    
                    Button(action: {
                        Task {
                            await logoutUser()
                        }
                    }) {
                        HStack(spacing: 16) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.title2)
                                .foregroundColor(.red)
                                .frame(width: 30)
                            
                            Text("Abmelden")
                                .font(.headline)
                                .foregroundColor(.red)
                            
                            Spacer()
                        }
                        .padding()
                        .modifier(CardModifier())
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                }
                .padding()
            }
            .navigationBarHidden(true)
            .task {
                guard userId > 0 else { return }
                await viewModel.loadRatings(for: userId)
            }
        }
    }
    
    func logoutUser() async {
        do {
           
            userVorname = ""
            userNachname = ""
            userId = 0
            isLoggedIn = false
        } catch {
            print("Fehler beim Abmelden: \(error.localizedDescription)")
        }
    }
}

struct ProfileRow: View {
    var icon: String
    var title: String
    var subtitle: String
    var trailingIcon: String = "chevron.right"
    var trailingColor: Color = Color(.systemGray3)
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.primary)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if !trailingIcon.isEmpty {
                Image(systemName: trailingIcon)
                    .foregroundColor(trailingColor)
                    .font(trailingIcon == "chevron.right" ? .footnote : .title3)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(.systemBackground))
    }
}

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray5), lineWidth: 1)
            )
    }
}

#Preview {
    ProfileView()
}
