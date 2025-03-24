//
//  ContentView.swift
//  WeSplit
//
//  Created by Lynjai Jimenez on 3/23/25.
//

import SwiftUI
import UIKit

// Extension remains the same
extension UIWindow {
    var firstResponder: UIResponder? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return nil
        }
        return _firstResponder(from: window)
    }
    
    private func _firstResponder(from view: UIView) -> UIResponder? {
        if view.isFirstResponder {
            return view
        }
        
        for subview in view.subviews {
            if let responder = _firstResponder(from: subview) {
                return responder
            }
        }
        
        return nil
    }
}

struct ContentView: View {
    // Use a string for the text field
    @State private var checkAmountString = ""
    @State private var numberOfPeople = 2
    @State private var tipPercentage = 20
    @FocusState private var amountIsFocused: Bool
    @State private var isEditing = false

    private let gradientColors = [
        Color(red: 0.1, green: 0.2, blue: 0.45),
        Color(red: 0.3, green: 0.4, blue: 0.9),
    ]
    
    // Convert string to double for calculations
    private var checkAmount: Double {
        if checkAmountString.isEmpty {
            return 0.0
        }
        
        // Remove currency symbol and other formatting before parsing
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.number(from: checkAmountString)?.doubleValue ?? 0.0
    }
    
    // Format string as currency when the user finishes editing
    private func formatAsCurrency(_ value: String) -> String {
        // If empty, return empty string
        if value.isEmpty {
            return ""
        }
        
        // Extract numeric value
        let numericString = value.filter { "0123456789.,".contains($0) }
        guard let doubleValue = Double(numericString.replacingOccurrences(of: ",", with: ".")) else {
            return value
        }
        
        // Format with currency symbol
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: doubleValue)) ?? value
    }
    
    // Reset all values to their defaults
    private func resetToDefaults() {
        // Reset all state values to default
        checkAmountString = ""
        numberOfPeople = 2
        tipPercentage = 20
        amountIsFocused = false
        isEditing = false
        
        // Add a subtle haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    // Breaking down the calculation into smaller parts
    var tipValue: Double {
        checkAmount / 100 * Double(tipPercentage)
    }
    
    var grandTotal: Double {
        checkAmount + tipValue
    }
    
    var totalPerPerson: Double {
        let peopleCount = Double(numberOfPeople + 2)
        return grandTotal / peopleCount
    }
    
    // Currency formatter for display
    private var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack {
                    Image("wesplitlogo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                        .cornerRadius(15)
                        .padding(.top, 50)
                        .shadow(radius: 10)

                    Form {
                        // Bill amount section
                        Section {
                            HStack {
                                // Currency field with prefix
                                if !checkAmountString.isEmpty && !isEditing {
                                    Text(formatAsCurrency(checkAmountString))
                                        .onTapGesture {
                                            isEditing = true
                                            amountIsFocused = true
                                        }
                                } else {
                                    HStack(spacing: 2) {
                                        // Show currency symbol if the field is focused but empty
                                        if isEditing && checkAmountString.isEmpty {
                                            Text(Locale.current.currencySymbol ?? "$")
                                                .foregroundColor(.gray)
                                        }
                                        
                                        TextField(
                                            "Amount",
                                            text: $checkAmountString
                                        )
                                        .keyboardType(.decimalPad)
                                        .focused($amountIsFocused)
                                    }
                                }
                                
                                // Clear button - always visible when field is focused
                                if amountIsFocused {
                                    Button(action: {
                                        checkAmountString = ""
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 20))
                                    }
                                    .transition(.opacity)
                                    .animation(.easeInOut, value: amountIsFocused)
                                }
                            }
                            .padding(.vertical, 8)
                            
                            Picker("Number of people", selection: $numberOfPeople) {
                                ForEach(2..<100) { number in
                                    Text("\(number) \(number == 1 ? "person" : "people")")
                                }
                            }
                            .pickerStyle(.navigationLink)
                        }
                        .listRowBackground(Color.white.opacity(0.8))

                        // Tip selection section
                        Section(header: Text("How much tip?").foregroundColor(.white)) {
                            NavigationLink(
                                destination: TipSelectionView(
                                    tipPercentage: $tipPercentage)
                            ) {
                                Text("Tip percentage: \(tipPercentage)%")
                            }
                        }
                        .listRowBackground(Color.white.opacity(0.8))

                        // Amount per person section
                        Section(header: Text("Amount per person").foregroundColor(.white)) {
                            Text(
                                totalPerPerson,
                                format: .currency(
                                    code: Locale.current.currency?.identifier ?? "USD")
                            )
                            .font(.headline)
                        }
                        .listRowBackground(Color.white.opacity(0.8))

                        // Total amount section
                        Section(header: Text("Total amount").foregroundColor(.white)) {
                            Text(
                                grandTotal,
                                format: .currency(
                                    code: Locale.current.currency?.identifier ?? "USD")
                            )
                            .font(.headline)
                        }
                        .listRowBackground(Color.white.opacity(0.8))
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Clear button in top right
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: resetToDefaults) {
                        Image(systemName: "arrow.clockwise.circle")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                    }
                }
                
                // Done button on keyboard
                if amountIsFocused {
                    ToolbarItem(placement: .keyboard) {
                        Button("Done") {
                            // Format the current input as currency when done
                            if !checkAmountString.isEmpty {
                                checkAmountString = formatAsCurrency(checkAmountString)
                            }
                            amountIsFocused = false
                            isEditing = false
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .shadow(radius: 2)
                    }
                }
            }
            .onChange(of: amountIsFocused) { oldValue, newValue in
                // When focus changes, update the isEditing state
                if newValue {
                    isEditing = true
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
