//
//  Onboarding.swift
//  App
//
//  Created by Boromir on 05.06.26.
//
import SwiftUI

struct OnboardingView : View{
    @State private var currentTab = 0
    @Binding var onboardingComplete: Bool
    var body : some View{
        TabView (selection: $currentTab){
            VStack(spacing: 20) {
                Image(systemName: "house.and.flag.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .foregroundColor(.blue)
                
                Text("Willkommen bei Neighborly")
                    .font(.title)
                    .fontWeight(.bold)
                Text("Deine App für lokale Nachbarschaftshilfe.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }.tag(0)
            
            VStack(spacing: 20) {
                Image(systemName: "shippingbox.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .foregroundColor(.orange)
                
                Text("Schwere Dinge?")
                    .font(.title)
                    .fontWeight(.bold)
                Text("Finde starke Nachbarn, die dir beim Möbeltragen helfen.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }.tag(1)
            
            VStack(spacing: 20) {
                Image(systemName: "lightbulb.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .foregroundColor(.yellow)
                
                Text("Kleine Reparaturen")
                    .font(.title)
                    .fontWeight(.bold)
                Text("Jemand in deiner Nähe hat bestimmt eine Leiter und kann helfen.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }.tag(2)
            VStack(spacing: 20) {
                Text("Bereit zu helfen?")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Melde dich jetzt an und werde Teil der größten Helfer-Community in deiner Nähe.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
                
                Button(action: {
                    onboardingComplete = true
                }, label: {
                    Text("Loslegen")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                })
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
            .padding(.horizontal, 20)
            .tag(3)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}
