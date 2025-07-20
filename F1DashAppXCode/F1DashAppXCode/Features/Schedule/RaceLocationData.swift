//
//  RaceLocationData.swift
//  F1-Dash
//
//  Race location coordinates for map display
//

import Foundation
import CoreLocation

struct RaceLocationData {
    static let locations: [String: CLLocationCoordinate2D] = [
        "Austria": CLLocationCoordinate2D(latitude: 47.2197, longitude: 14.7647),
        "United Kingdom": CLLocationCoordinate2D(latitude: 52.0786, longitude: -1.0169),
        "Belgium": CLLocationCoordinate2D(latitude: 50.4372, longitude: 5.9714),
        "Hungary": CLLocationCoordinate2D(latitude: 47.5789, longitude: 19.2486),
        "Netherlands": CLLocationCoordinate2D(latitude: 52.3888, longitude: 4.5409),
        "Italy": CLLocationCoordinate2D(latitude: 45.6156, longitude: 9.2811),
        "Azerbaijan": CLLocationCoordinate2D(latitude: 40.3725, longitude: 49.8533),
        "Singapore": CLLocationCoordinate2D(latitude: 1.2914, longitude: 103.8644),
        "United States": CLLocationCoordinate2D(latitude: 30.1328, longitude: -97.6411), // Austin
        "Mexico": CLLocationCoordinate2D(latitude: 19.4042, longitude: -99.0907),
        "Brazil": CLLocationCoordinate2D(latitude: -23.7036, longitude: -46.6997),
        "Qatar": CLLocationCoordinate2D(latitude: 25.4902, longitude: 51.4521),
        "United Arab Emirates": CLLocationCoordinate2D(latitude: 24.4539, longitude: 54.3773)
    ]
    
    static let circuitNames: [String: String] = [
        "Austria": "Red Bull Ring",
        "United Kingdom": "Silverstone Circuit",
        "Belgium": "Circuit de Spa-Francorchamps",
        "Hungary": "Hungaroring",
        "Netherlands": "Circuit Zandvoort",
        "Italy": "Autodromo Nazionale Monza",
        "Azerbaijan": "Baku City Circuit",
        "Singapore": "Marina Bay Street Circuit",
        "United States": "Circuit of the Americas",
        "Mexico": "Autódromo Hermanos Rodríguez",
        "Brazil": "Autódromo José Carlos Pace",
        "Qatar": "Lusail International Circuit",
        "United Arab Emirates": "Yas Marina Circuit"
    ]
}