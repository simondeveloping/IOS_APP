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
            Text("Seite 1").tag(0)
            Text("Seite 2").tag(1)
            Text("Seite 3").tag(2)
            VStack(){
                Text("Jetz kostenlos anmelden")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                Spacer()
                Button(action:{
                    onboardingComplete = true
                }, label: {
                    Text("Loslegen")
                })
            }.tag(3)

        }
        .tabViewStyle(.page(indexDisplayMode: .always))
    }
}
