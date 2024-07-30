//
//  CalendarView.swift
//  SwiftCal
//
//  Created by Juan Hernandez Pazos on 21/07/24.
//

import SwiftUI
import CoreData
import WidgetKit

struct CalendarView: View {
    // MARK: Properties
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Day.date, ascending: true)],
        predicate: NSPredicate(format: "(date >= %@) AND (date <= %@)",
                                Date().startOfCalendarWithPrefixDays as CVarArg,
                                Date().endOfMonth as CVarArg)
    )
    private var days: FetchedResults<Day>
    
    @State private var showNoInFutureMessage = false
    
    // MARK: - View
    var body: some View {
        NavigationView {
            VStack {
                CalendarHeaderView()
                    .padding(.bottom)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                    ForEach(days) { day in
                        if day.date!.monthInt != Date().monthInt {
                            Text("")
                        } else {
                            Text(day.date!.formatted(.dateTime.day()))
                                .bold()
                                .foregroundStyle(day.didStudy ? .green : .secondary)
                                .frame(maxWidth: .infinity, minHeight: 40)
                                .background(
                                    Circle()
                                        .foregroundStyle(.green.opacity(day.didStudy ? 0.3 : 0.0))
                                )
                                .onTapGesture {
                                    if day.date!.dayInt <= Date().dayInt {
                                        day.didStudy.toggle()
                                        
                                        do {
                                            try viewContext.save()
                                            WidgetCenter.shared.reloadTimelines(ofKind: "SwiftCalWidget")
                                            #if DEBUG
                                            print("👆🏻 \(day.date!.dayInt) marcado como estudiado")
                                            #endif
                                        } catch {
                                            #if DEBUG
                                                print("😈 Error al guardar context")
                                            #endif
                                        }
                                    } else {
                                        showNoInFutureMessage.toggle()
                                    }
                                }
                        }
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
            let newDay = Day(context: viewContext)
            newDay.date = Calendar.current.date(byAdding: .day, value: dayOffset, to: date.startOfMonth)
            newDay.didStudy = false
        }
        
        do {
            try viewContext.save()
            #if DEBUG
            print("✅ Días creados para \(date.monthFullName)")
            #endif
        } catch {
            #if DEBUG
                print("😈 Error al guardar context")
            #endif
        }
    }
}

// MARK: Preview
#Preview {
    CalendarView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
