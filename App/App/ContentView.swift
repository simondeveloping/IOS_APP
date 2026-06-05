//
//  ContentView.swift
//  App
//
//  Created by Boromir on 29.05.26.
//
import SwiftUI

struct ContentView: View {

    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("onboardingComplete") var onboardingComplete: Bool = false
    var body: some View {
        if !onboardingComplete {
            OnboardingView(onboardingComplete: $onboardingComplete)
        }else if !isLoggedIn {
            LoginView()
        } else {
            TabView {
                
                HomeView()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                
                
                EntdeckenView()
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("Entdecken")
                    }
                
                ErstellenView()
                    .tabItem {
                        Image(systemName: "plus.circle.fill")
                        Text("Erstellen")
                    }
                
                FavoritenView()
                    .tabItem {
                        Image(systemName: "heart.fill")
                        Text("Favoriten")
                    }
                
                ProfileView()
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Profil")
                    }
            }
        }
    }
};

#Preview {
    ContentView()
}
