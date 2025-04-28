//
//  ContentView.swift
//  minimalwardrobe
//
//  Created by Greenhaw, Victoria R on 4/28/25.
//
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = WardrobeViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [.blue.opacity(0.6), .purple.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack {
                    AddItemForm(viewModel: viewModel)
                    OutfitSection(viewModel: viewModel)
                    ClothingList(viewModel: viewModel)
                }
            }
            .navigationTitle("Minimal Wardrobe")
        }
    }
}

// Form to Add Clothing Items
struct AddItemForm: View {
    @ObservedObject var viewModel: WardrobeViewModel
    @State private var name: String = ""
    @State private var category: String = "Clothing"
    @State private var style: String = "Casual"
    @State private var color: String = "Red"
    @State private var texture: String = "Cotton"
    @State private var metal: String = "Silver"
    @State private var type: String = "Bracelet"
    @State private var shoeSubtype: String = "Other" // NEW: Subtype for Shoes
    @State private var showAlert: Bool = false
    
    let categories = ["Clothing", "Dresses", "Pants", "Shorts", "Jewelry", "Shoes"] // UPDATED: Added Pants, Shorts
    let styles = ["Casual", "Formal"]
    let colors = ["Red", "Blue", "Black", "White", "Gray", "Orange", "Green", "Purple", "Yellow"]
    let textures = ["Cotton", "Leather", "Wool", "Silk", "Lace", "Jean", "Waffle Knit"]
    let metals = ["Silver", "Gold"]
    let types = ["Bracelet", "Earring", "Ring"]
    let shoeSubtypes = ["Heels", "Other"] // NEW: Shoe subtypes
    
    var body: some View {
        Form {
            Section(header: Text("Add Item").foregroundColor(.white)) {
                TextField("Item Name (e.g., Red Dress)", text: $name)
                    .foregroundColor(.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(name.isEmpty ? Color.red : Color.gray, lineWidth: 1)
                    )
                Picker("Category", selection: $category) {
                    ForEach(categories, id: \.self) { cat in
                        Text(cat)
                    }
                }
                .foregroundColor(.black)
                
                if category == "Jewelry" {
                    Picker("Type", selection: $type) {
                        ForEach(types, id: \.self) { type in
                            Text(type)
                        }
                    }
                    .foregroundColor(.black)
                    Picker("Metal", selection: $metal) {
                        ForEach(metals, id: \.self) { metal in
                            Text(metal)
                        }
                    }
                    .foregroundColor(.black)
                } else if category == "Clothing" || category == "Dresses" || category == "Pants" || category == "Shorts" {
                    Picker("Style", selection: $style) {
                        ForEach(styles, id: \.self) { style in
                            Text(style)
                        }
                    }
                    .foregroundColor(.black)
                    Picker("Texture", selection: $texture) {
                        ForEach(textures, id: \.self) { texture in
                            Text(texture)
                        }
                    }
                    .foregroundColor(.black)
                    Picker("Color", selection: $color) {
                        ForEach(colors, id: \.self) { color in
                            Text(color)
                        }
                    }
                    .foregroundColor(.black)
                } else if category == "Shoes" {
                    Picker("Subtype", selection: $shoeSubtype) { // NEW: Subtype for Shoes
                        ForEach(shoeSubtypes, id: \.self) { subtype in
                            Text(subtype)
                        }
                    }
                    .foregroundColor(.black)
                    Picker("Color", selection: $color) {
                        ForEach(colors, id: \.self) { color in
                            Text(color)
                        }
                    }
                    .foregroundColor(.black)
                }
                
                Button(action: {
                    if !name.isEmpty {
                        viewModel.addItem(
                            name: name,
                            category: category,
                            style: category == "Clothing" || category == "Dresses" || category == "Pants" || category == "Shorts" ? style : nil,
                            color: category == "Jewelry" ? nil : color,
                            texture: category == "Clothing" || category == "Dresses" || category == "Pants" || category == "Shorts" ? texture : nil,
                            metal: category == "Jewelry" ? metal : nil,
                            type: category == "Jewelry" ? type : nil,
                            shoeSubtype: category == "Shoes" ? shoeSubtype : nil
                        )
                        name = ""
                        category = "Clothing"
                        style = "Casual"
                        color = "Red"
                        texture = "Cotton"
                        metal = "Silver"
                        type = "Bracelet"
                        shoeSubtype = "Other"
                    } else {
                        showAlert = true
                    }
                }) {
                    Text("Add Item")
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
        .scrollContentBackground(.hidden)
        .alert("Missing Name", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please enter a name for the item.")
        }
    }
}

// Outfit Display Section
struct OutfitSection: View {
    @ObservedObject var viewModel: WardrobeViewModel
    @State private var isFormal: Bool = false // NEW: Toggle for Formal/Casual
    
    var body: some View {
        VStack(spacing: 10) {
            Toggle("Formal Outfit", isOn: $isFormal)
                .foregroundColor(.white)
                .padding(.horizontal)
            
            Button(action: {
                viewModel.generateOutfit(isFormal: isFormal)
            }) {
                Text("Generate Outfit")
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal)
            
            if let outfit = viewModel.currentOutfit {
                VStack(spacing: 10) {
                    Text("Your Outfit")
                        .font(.headline)
                        .foregroundColor(.white)
                    ForEach(outfit) { item in
                        ClothingItemRow(item: item)
                    }
                    Button(action: {
                        viewModel.clearOutfit()
                    }) {
                        Text("Clear Outfit")
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .padding(.horizontal)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.3))
                )
                .padding(.horizontal)
            } else if let errorMessage = viewModel.outfitErrorMessage {
                Text(errorMessage)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
    }
}

// Clothing Items List
struct ClothingList: View {
    @ObservedObject var viewModel: WardrobeViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.clothingItems) { item in
                ClothingItemRow(item: item)
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.3))
                        .padding(.vertical, 2)
                    )
            }
            .onDelete { indexSet in
                indexSet.forEach { index in
                    viewModel.deleteItem(at: index)
                }
            }
        }
        .listStyle(.plain)
        .background(Color.clear)
    }
}

// Reusable Clothing Item Row
struct ClothingItemRow: View {
    let item: ClothingItem
    
    var body: some View {
        HStack {
            Image(systemName: iconForCategory(item.category))
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.headline)
                    .foregroundColor(.white)
                if item.category == "Jewelry" {
                    Text("Category: \(item.category) | Type: \(item.type ?? "N/A")")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                    Text("Metal: \(item.metal ?? "N/A")")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                } else if item.category == "Shoes" {
                    Text("Category: \(item.category) | Subtype: \(item.shoeSubtype ?? "N/A")")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                    Text("Color: \(item.color ?? "N/A")")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                } else {
                    Text("Category: \(item.category) | Style: \(item.style ?? "N/A")")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                    Text("Color: \(item.color ?? "N/A") | Texture: \(item.texture ?? "N/A")")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .padding(.vertical, 5)
    }
    
    private func iconForCategory(_ category: String) -> String {
        switch category {
        case "Clothing": return "tshirt"
        case "Dresses": return "figure.dress.line"
        case "Pants": return "trousers" // NEW: Icon for Pants
        case "Shorts": return "trousers.fill" // NEW: Icon for Shorts
        case "Jewelry": return "sparkle"
        case "Shoes": return "shoe"
        default: return "questionmark"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
