//
//  FatSecretAPI.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/1/25.
//

import Foundation

class FatSecretAPI: ObservableObject {
    private let baseURL = "https://sculpty-api.up.railway.app"
    
    @Published var isLoading: Bool = false
    @Published var loaded: Bool = false
    
    func searchFoods(_ query: String) async throws -> [FatSecretFood] {
        guard !query.isEmpty else { return [] }
        
        let url = URL(string: "\(baseURL)/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")! // swiftlint:disable:this line_length force_unwrapping
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(FatSecretSearchResponse.self, from: data)
        
        return response.foods?.food ?? []
    }
    
    func getFoodDetails(_ foodId: String) async throws -> FoodDetail {
        let url = URL(string: "\(baseURL)/food/\(foodId)")! // swiftlint:disable:this force_unwrapping
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(FatSecretFoodDetail.self, from: data)
        
        return response.food
    }
    
    func getServingOptions(for food: FatSecretFood) async throws -> [Serving] {
        let details = try await getFoodDetails(food.food_id)
        return details.servings?.serving ?? []
    }
    
    func lookupBarcode(_ barcode: String) async throws -> FatSecretFood {
        guard !barcode.isEmpty else {
            throw BarcodeError.invalidBarcode
        }
        
        let url = URL(string: "\(baseURL)/barcode/\(barcode)")! // swiftlint:disable:this force_unwrapping
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 404 {
                throw BarcodeError.barcodeNotFound
            } else if httpResponse.statusCode != 200 {
                throw BarcodeError.serverError("HTTP \(httpResponse.statusCode)")
            }
        }
        
        let barcodeResponse = try JSONDecoder().decode(BarcodeResponse.self, from: data)
        return barcodeResponse.toFatSecretFood()
    }
}
