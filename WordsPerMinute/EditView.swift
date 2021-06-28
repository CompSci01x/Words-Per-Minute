//
//  EditView.swift
//  WordsPerMinute
//
//  Created by CompSci01x on 6/27/21.
//

import SwiftUI

struct EditView: View {
    
    @Binding var timerLengthInSec: Double
    @Binding var timerRingColor: Color
    @Binding var timerRingCardColor: Color
    
    @Binding var transcriptCardColor: Color

    var body: some View {
        
        List {
            Section(header: Text("Timer Length")) {
                HStack {
                    Slider(value: $timerLengthInSec, in: 1...60, step: 1.0)
                    Spacer()
                    Text("\(Int(timerLengthInSec)) sec")
                }
            }
            
            Section(header: Text("Timer Color")) {
                ColorPicker("Timer Ring Color", selection: $timerRingColor)
                ColorPicker("Timer Card Color", selection: $timerRingCardColor)
            }
            
            Section(header: Text("Transcript Card Color")) {
                ColorPicker("Transcript Card Color", selection: $transcriptCardColor)
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView(timerLengthInSec: .constant(60.0),
                 timerRingColor: .constant(.blue),
                 timerRingCardColor: .constant(.green),
                 transcriptCardColor: .constant(.blue))
    }
}
