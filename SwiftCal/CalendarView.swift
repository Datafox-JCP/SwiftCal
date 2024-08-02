//
//  CalendarView.swift
//  SwiftCal
//
//  Created by Juan Hernandez Pazos on 21/07/24.
//

import SwiftUI
import SwiftData
import WidgetKit

struct CalendarView: View {
    // MARK: Properties
    @Environment(\.modelContext) private var context

    @Query(filter: #Predicate<Day> { $0.date > startDate && $0.date < endDate }, sort: \Day.date)
    var days: [Day]
    
    static var startDate: Date { .now.startOfCalendarWithPrefixDays }
    static var endDate: Date { .now.endOfMonth }
    
    @State private var showNoInFutureMessage = false
    
    // MARK: - View
    var body: some View {
        NavigationView {
            VStack {
                CalendarHeaderView()
                    .padding(.bottom)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                    ForEach(days) { day in
                        if day.date.monthInt != Date().monthInt {
                            Text("")
                        } else {
                            Text(day.date.formatted(.dateTime.day()))
                                .bold()
                                .foregroundStyle(day.didStudy ? .green : .secondary)
                                .frame(maxWidth: .infinity, minHeight: 40)
                                .background(
                                    Circle()
                                        .foregroundStyle(.green.opacity(day.didStudy ? 0.3 : 0.0))
                                )
                                .onTapGesture {
                                    if day.date.dayInt <= Date().dayInt {
                                        day.didStudy.toggle()
                                        WidgetCenter.shared.reloadTimelines(ofKind: "SwiftCalWidget")
                                    } else {
                                        showNoInFutureMessage.toggle()
                                    }
                                } // OnTap
                        } // Condition
                    } // Loop
                } // Grid
                
                Spacer()
            } // VStack
            .navigationTitle(Date().formatted(.dateTime.month(.wide)))
            .padding()
            .onAppear {
                if days.isEmpty {
                    createMonthDays(for: .now.startOfPreviousMonth)
                    createMonthDays(for: .now)
                } else if days.count < 10 { // sólo están los prefix days
                    createMonthDays(for: .now)
                }
            } // On appear
            .alert("Selección no válida", isPresented: $showNoInFutureMessage) {} message: {
                Text("👎 no puedes estudiar en el futuro")
            }
        } // Nav
    }
    
    // MARK: Functions
    
    func createMonthDays(for date: Date) {
        for dayOffset in 0..<date.numberOfDaysInMonth {
            let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: date.startOfMonth)!
            let newDay = Day(date: date, didStudy: false)
            context.insert(newDay)
        }
    }
}

// MARK: Preview
#Preview {
    CalendarView()
}
