//
//  String+CountryFlag.swift
//  F1DashAppXCode
//
//  Extension to convert country codes to flag emojis
//

import Foundation

extension String {
    /// Converts a 2-letter country code to its flag emoji
    var countryFlag: String {
        let base: UInt32 = 127397
        var flag = ""
        
        for scalar in self.uppercased().unicodeScalars {
            if let unicode = UnicodeScalar(base + scalar.value) {
                flag.append(String(unicode))
            }
        }
        
        return flag.isEmpty ? "🏳️" : flag
    }
    
    /// Common F1 country code mappings (some use non-standard codes)
    var f1CountryFlag: String {
        switch self.uppercased() {
        // Current F1 calendar countries
        case "GB", "UK", "GBR": return "GB".countryFlag  // United Kingdom
        case "USA", "US": return "US".countryFlag        // United States
        case "UAE", "ARE": return "AE".countryFlag       // United Arab Emirates
        case "NED", "NLD": return "NL".countryFlag       // Netherlands
        case "MON", "MCO": return "MC".countryFlag       // Monaco
        case "AZE", "AZ": return "AZ".countryFlag        // Azerbaijan
        case "RSA", "ZAF": return "ZA".countryFlag       // South Africa (historical)
        case "AUS", "AU": return "AU".countryFlag        // Australia
        case "CHN", "CN": return "CN".countryFlag        // China
        case "JPN", "JP": return "JP".countryFlag        // Japan
        case "BHR", "BH": return "BH".countryFlag        // Bahrain
        case "SAU", "SA": return "SA".countryFlag        // Saudi Arabia
        case "ITA", "IT": return "IT".countryFlag        // Italy
        case "ESP", "ES": return "ES".countryFlag        // Spain
        case "CAN", "CA": return "CA".countryFlag        // Canada
        case "AUT", "AT": return "AT".countryFlag        // Austria
        case "HUN", "HU": return "HU".countryFlag        // Hungary
        case "BEL", "BE": return "BE".countryFlag        // Belgium
        case "SGP", "SG": return "SG".countryFlag        // Singapore
        case "MEX", "MX": return "MX".countryFlag        // Mexico
        case "BRA", "BR": return "BR".countryFlag        // Brazil
        case "QAT", "QA": return "QA".countryFlag        // Qatar
        
        // Historical and potential future venues
        case "DEU", "DE", "GER": return "DE".countryFlag // Germany
        case "FRA", "FR": return "FR".countryFlag        // France
        case "TUR", "TR": return "TR".countryFlag        // Turkey
        case "KOR", "KR": return "KR".countryFlag        // South Korea
        case "IND", "IN": return "IN".countryFlag        // India
        case "PRT", "PT", "POR": return "PT".countryFlag // Portugal
        case "RUS", "RU": return "RU".countryFlag        // Russia
        case "ARG", "AR": return "AR".countryFlag        // Argentina
        case "MYS", "MY", "MAL": return "MY".countryFlag // Malaysia
        case "VNM", "VN": return "VN".countryFlag        // Vietnam
        
        default: return self.countryFlag
        }
    }
}