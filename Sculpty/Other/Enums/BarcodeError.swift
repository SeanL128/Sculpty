//
//  BarcodeError.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/14/25.
//

import Foundation

enum BarcodeError: LocalizedError {
    case invalidBarcode
    case barcodeNotFound
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidBarcode:
            return "Invalid barcode format"
        case .barcodeNotFound:
            return "Barcode not found in database"
        case .serverError(let message):
            return "Server error: \(message)"
        }
    }
}
