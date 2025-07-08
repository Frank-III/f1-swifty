//
//  WeatherSection.swift
//  F1-Dash
//
//  Weather dashboard section component
//

import SwiftUI

struct WeatherSection: View {
    var body: some View {
        WeatherView()
            .modifier(PlatformGlassCardModifier())
    }
}