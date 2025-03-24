//
//  TipSelectionView.swift
//  WeSplit
//
//  Created by Lynjai Jimenez on 3/24/25.
//

import SwiftUI

struct TipSelectionView: View {
    @Binding var tipPercentage: Int

    var body: some View {
        Form {
            Picker("Tip percentage", selection: $tipPercentage) {
                ForEach(0..<101) {
                    Text("\($0)%")
                }
            }
            .pickerStyle(.wheel)
        }
        .navigationTitle("Select Tip Percentage")
    }
}
