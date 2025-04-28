//
//  models.swift
//  minimalwardrobe
//
//  Created by Greenhaw, Victoria R on 4/28/25.
//
import Foundation
import SwiftUI

// Clothing Item Model
struct ClothingItem: Identifiable, Codable {
    let id: UUID
    let name: String
    let category: String
    let style: String?
    let color: String?
    let texture: String?
    let metal: String?
    let type: String?
    let shoeSubtype: String? // NEW: Subtype for Shoes
    
    init(id: UUID = UUID(), name: String, category: String, style: String?, color: String?, texture: String?, metal: String?, type: String?, shoeSubtype: String?) {
        self.id = id
        self.name = name
        self.category = category
        self.style = style
        self.color = color
        self.texture = texture
        self.metal = metal
        self.type = type
        self.shoeSubtype = shoeSubtype
    }
}

// ViewModel
class WardrobeViewModel: ObservableObject {
    @Published var clothingItems: [ClothingItem] = []
    @Published var currentOutfit: [ClothingItem]?
    @Published var outfitErrorMessage: String?
    @AppStorage("clothingItems") private var clothingItemsData: Data = Data()
    
    private let colorGroups: [String: String] = [
        "Red": "Warm",
        "Orange": "Warm",
        "Yellow": "Warm",
        "Blue": "Cool",
        "Green": "Cool",
        "Purple": "Cool",
        "Black": "Neutral",
        "White": "Neutral",
        "Gray": "Neutral"
    ]
    
    init() {
        loadItems()
    }
    
    func addItem(name: String, category: String, style: String?, color: String?, texture: String?, metal: String?, type: String?, shoeSubtype: String?) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let item = ClothingItem(
            name: trimmedName.isEmpty ? "Unnamed Item" : trimmedName,
            category: category,
            style: style,
            color: color,
            texture: texture,
            metal: metal,
            type: type,
            shoeSubtype: shoeSubtype
        )
        clothingItems.append(item)
        saveItems()
    }
    
    func deleteItem(at index: Int) {
        clothingItems.remove(at: index)
        saveItems()
    }
    
    func generateOutfit(isFormal: Bool) { // UPDATED: Added isFormal parameter
        let hasClothingOrDresses = clothingItems.contains { $0.category == "Clothing" || $0.category == "Dresses" || $0.category == "Pants" || $0.category == "Shorts" }
        let hasDresses = clothingItems.contains { $0.category == "Dresses" }
        let hasJewelry = clothingItems.contains { $0.category == "Jewelry" }
        let hasShoes = clothingItems.contains { $0.category == "Shoes" }
        let hasHeels = clothingItems.contains { $0.category == "Shoes" && $0.shoeSubtype == "Heels" }
        
        if isFormal && hasDresses && hasJewelry && hasHeels {
            if let coordinatedOutfit = findCoordinatedOutfit(isFormal: true) {
                currentOutfit = coordinatedOutfit
                outfitErrorMessage = nil
            } else {
                // Fallback: Complete formal outfit without coordination
                let dress = clothingItems
                    .filter { $0.category == "Dresses" }
                    .shuffled()
                    .first!
                let jewelry = clothingItems
                    .filter { $0.category == "Jewelry" }
                    .shuffled()
                    .first!
                let heels = clothingItems
                    .filter { $0.category == "Shoes" && $0.shoeSubtype == "Heels" }
                    .shuffled()
                    .first!
                
                currentOutfit = [dress, jewelry, heels]
                outfitErrorMessage = "No color-coordinated formal outfit found. Showing a complete formal outfit."
            }
        } else if !isFormal && hasClothingOrDresses && hasJewelry && hasShoes {
            if let coordinatedOutfit = findCoordinatedOutfit(isFormal: false) {
                currentOutfit = coordinatedOutfit
                outfitErrorMessage = nil
            } else {
                // Fallback: Complete casual outfit without coordination
                let topItem = clothingItems
                    .filter { $0.category == "Clothing" || $0.category == "Dresses" || $0.category == "Pants" || $0.category == "Shorts" }
                    .shuffled()
                    .first!
                let jewelry = clothingItems
                    .filter { $0.category == "Jewelry" }
                    .shuffled()
                    .first!
                let shoes = clothingItems
                    .filter { $0.category == "Shoes" }
                    .shuffled()
                    .first!
                
                currentOutfit = [topItem, jewelry, shoes]
                outfitErrorMessage = "No color-coordinated casual outfit found. Showing a complete casual outfit."
            }
        } else {
            currentOutfit = nil
            outfitErrorMessage = isFormal
                ? "Please add at least one Dress, one Jewelry, and one Shoes item with subtype Heels to generate a formal outfit."
                : "Please add at least one Clothing, Dress, Pants, or Shorts, one Jewelry, and one Shoes item to generate a casual outfit."
        }
    }
    
    private func findCoordinatedOutfit(isFormal: Bool) -> [ClothingItem]? {
        let topItems = isFormal
            ? clothingItems.filter { $0.category == "Dresses" }
            : clothingItems.filter { $0.category == "Clothing" || $0.category == "Dresses" || $0.category == "Pants" || $0.category == "Shorts" }
        let jewelryItems = clothingItems.filter { $0.category == "Jewelry" }
        let shoeItems = isFormal
            ? clothingItems.filter { $0.category == "Shoes" && $0.shoeSubtype == "Heels" }
            : clothingItems.filter { $0.category == "Shoes" }
        
        for top in topItems {
            let topGroup = top.color != nil ? colorGroups[top.color!] ?? "Neutral" : "Neutral"
            let compatibleJewelry = jewelryItems // Jewelry has no color, treat as neutral
            let compatibleShoes = shoeItems.filter { item in
                let itemGroup = item.color != nil ? colorGroups[item.color!] ?? "Neutral" : "Neutral"
                return itemGroup == topGroup || itemGroup == "Neutral" || topGroup == "Neutral"
            }
            
            if let jewelry = compatibleJewelry.shuffled().first,
               let shoes = compatibleShoes.shuffled().first {
                return [top, jewelry, shoes]
            }
        }
        return nil
    }
    
    func clearOutfit() {
        currentOutfit = nil
        outfitErrorMessage = nil
    }
    
    private func saveItems() {
        if let data = try? JSONEncoder().encode(clothingItems) {
            clothingItemsData = data
        }
    }
    
    private func loadItems() {
        if let items = try? JSONDecoder().decode([ClothingItem].self, from: clothingItemsData) {
            clothingItems = items
        }
    }
}
