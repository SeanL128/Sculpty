//
//  FatSecretAPI.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/1/25.
//

import Foundation

@MainActor
class FatSecretAPI: ObservableObject {
    private let baseURL = "https://api.sculpty.app"
    
    @Published var isLoading: Bool = false
    @Published var loaded: Bool = false
    
    private var activeOperations: Set<String> = []
    
    func searchFoods(_ query: String) async throws -> [FatSecretFood] {
        CloudSettings.shared.checkAndResetWeeklyUsage()
        
        guard StoreKitManager.shared.canPerformNutritionSearch, !query.isEmpty else { return [] }
        
        let operationId = "search_\(query.hashValue)"
        
        guard !activeOperations.contains(operationId) else {
            throw CancellationError()
        }
        
        activeOperations.insert(operationId)
        
        defer {
            activeOperations.remove(operationId)
        }
        
        guard let url = URL(string: "\(baseURL)/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") else { // swiftlint:disable:this line_length
            throw APIError.invalidURL
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(FatSecretSearchResponse.self, from: data)
            
            if !StoreKitManager.shared.hasPremiumAccess {
                CloudSettings.shared.weeklyNutritionSearches += 1
            }
            
            return response.foods?.food ?? []
        } catch {
            await MainActor.run {
                Toast.show("Unable to search. Please check your connection.", "wifi.slash")
            }
            
            throw error
        }
    }
    
    func getFoodDetails(_ foodId: String) async throws -> FoodDetail {
        let operationId = "details_\(foodId)"
        
        guard !activeOperations.contains(operationId) else {
            throw CancellationError()
        }
        
        activeOperations.insert(operationId)
        
        defer {
            activeOperations.remove(operationId)
        }
        
        guard let url = URL(string: "\(baseURL)/food/\(foodId)") else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(FatSecretFoodDetail.self, from: data)
            
            return response.food
        } catch {
            await MainActor.run {
                Toast.show("Unable to load food details.", "exclamationmark.triangle")
            }
            
            throw error
        }
    }
    
    func getServingOptions(for food: FatSecretFood) async throws -> [Serving] {
        let details = try await getFoodDetails(food.food_id)
        
        return details.servings?.serving ?? []
    }
    
    func lookupBarcode(_ barcode: String) async throws -> FatSecretFood {
        guard !barcode.isEmpty else {
            throw BarcodeError.invalidBarcode
        }
        
        CloudSettings.shared.checkAndResetWeeklyUsage()
        
        guard StoreKitManager.shared.canPerformBarcodeScans else {
            throw BarcodeError.limitReached
        }
        
        let operationId = "barcode_\(barcode)"
        
        guard !activeOperations.contains(operationId) else {
            throw CancellationError()
        }
        
        activeOperations.insert(operationId)
        
        defer {
            activeOperations.remove(operationId)
        }
        
        guard let url = URL(string: "\(baseURL)/barcode/\(barcode)") else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 404 {
                    throw BarcodeError.barcodeNotFound
                } else if httpResponse.statusCode != 200 {
                    throw BarcodeError.serverError("HTTP \(httpResponse.statusCode)")
                }
            }
            
            let barcodeResponse = try JSONDecoder().decode(BarcodeResponse.self, from: data)
            
            if !StoreKitManager.shared.hasPremiumAccess {
                CloudSettings.shared.weeklyBarcodeScans += 1
            }
            
            return barcodeResponse.toFatSecretFood()
        } catch {
            if !(error is BarcodeError) {
                await MainActor.run {
                    Toast.show("Network error. Please try again.", "wifi.slash")
                }
            }
            
            throw error
        }
    }
    
    func cancelAllOperations() {
        activeOperations.removeAll()
    }
    
    func resetState() {
        isLoading = false
        loaded = false
        
        cancelAllOperations()
    }
}
