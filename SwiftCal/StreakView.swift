//
//  StreakView.swift
//  SwiftCal
//
//  Created by Juan Hernandez Pazos on 23/07/24.
//

import SwiftUI
import SwiftData

struct StreakView: View {
    // MARK: Properties
    @Query(filter: #Predicate<Day> { $0.date > startDate && $0.date < endDate }, sort: \Day.date)
    var days: [Day]
    
    static var startDate: Date { .now.startOfCalendarWithPrefixDays }
    static var endDate: Date { .now.endOfMonth }
    
    @State private var streakValue = 0
    
    // MARK: - View
    var body: some View {
        VStack {
            Text("\(streakValue)")
                .font(.system(size: 200, weight: .semibold, design: .rounded))
                .foregroundStyle(streakValue > 0 ? .green : .pink)
            
            Text("Racha actual")
                .font(.title2)
                .bold()
                .foregroundStyle(.secondary)
        }
        .offset(y: -50)
        .onAppear { streakValue = calculateStreakValue() }
    }
    
    func calculateStreakValue() -> Int {
        guard !days.isEmpty else { return 0 }
        
        let nonFutureDays = days.filter { $0.date.dayInt <= Date().dayInt }
        
        var streakCount = 0
        
        for day in nonFutureDays.reversed() {
            if day.didStudy {
                streakCount += 1
            } else {
                if day.date.dayInt != Date().dayInt {
                    break
                }
            }
        }
        
        return streakCount
    }
}

// MARK: - Preview
#Preview {
    StreakView()
}
