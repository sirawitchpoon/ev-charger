//
//  ContentView.swift
//  ev-charger
//
//  FarmCharge — EV & Drone Charger Finder
//

import SwiftUI
import Combine

struct ContentView: View {
    @StateObject private var router = Router()

    var body: some View {
        ZStack {
            FC.paper.ignoresSafeArea()

            switch router.screen {
            case .onboarding:
                OnboardingView()
            case .map:
                MapScreenView()
            case .search:
                SearchView()
            case .detail:
                StationDetailView(stationId: router.stationId)
            case .booking:
                BookingView(stationId: router.stationId)
            case .payment:
                PaymentView(stationId: router.stationId)
            case .active:
                ActiveChargingView(stationId: router.stationId)
            case .profile:
                ProfileView()
            case .trips:
                TripsView()
            }
        }
        .environmentObject(router)
        .preferredColorScheme(.light)
    }
}

#Preview {
    ContentView()
}
