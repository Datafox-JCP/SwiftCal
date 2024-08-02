//
//  CalendarHeaderView.swift
//  SwiftCal
//
//  Created by Juan Hernandez Pazos on 28/07/24.
//

import SwiftUI

struct CalendarHeaderView: View {
    
    let daysOfWeek = ["L", "M", "M", "J", "V", "S", "D"]
    var font: Font = .body
    
    var body: some View {
        HStack {
            ForEach(daysOfWeek, id: \.self) { dayOfWeek in
                Text(dayOfWeek)
                    .font(font)
                    .fontWeight(.black)
                    .foregroundStyle(.green)
                    .frame(maxWidth: .infinity)
            } // Loop
        } // HStack
    }
}

#Preview {
    CalendarHeaderView()
}
