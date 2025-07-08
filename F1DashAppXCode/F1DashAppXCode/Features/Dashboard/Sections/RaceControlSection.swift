//
//  RaceControlSection.swift
//  F1-Dash
//
//  Race control dashboard section component
//

import SwiftUI

struct RaceControlSection: View {
    var body: some View {
        RaceControlView()
            .modifier(PlatformGlassCardModifier())
    }
}