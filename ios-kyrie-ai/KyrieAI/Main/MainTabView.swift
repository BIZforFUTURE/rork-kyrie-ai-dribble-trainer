//
//  MainTabView.swift
//  KyrieAI
//
//  Root tab bar after onboarding + assessment.
//

import SwiftUI

struct MainTabView: View {
    let profile: PlayerProfile
    @State private var selection: Int = 0

    private var tabSelection: Binding<Int> {
        Binding(
            get: { selection },
            set: { newValue in
                if newValue != selection { Haptics.select() }
                selection = newValue
            }
        )
    }

    var body: some View {
        TabView(selection: tabSelection) {
            HomeView(profile: profile)
                .tabItem { Label("Today", systemImage: "house.fill") }
                .tag(0)
            TrainHubView(profile: profile)
                .tabItem { Label("Train", systemImage: "figure.basketball") }
                .tag(1)
            ProgressDashboardView(profile: profile)
                .tabItem { Label("Progress", systemImage: "chart.line.uptrend.xyaxis") }
                .tag(2)
            ProfileView(profile: profile)
                .tabItem { Label("Profile", systemImage: "person.fill") }
                .tag(3)
        }
        .tint(Theme.primary)
        .preferredColorScheme(.dark)
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Theme.background)
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}
