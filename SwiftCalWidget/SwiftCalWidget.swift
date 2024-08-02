//
//  SwiftCalWidget.swift
//  SwiftCalWidget
//
//  Created by Juan Hernandez Pazos on 24/07/24.
//

import WidgetKit
import SwiftUI
import SwiftData

struct Provider: TimelineProvider {
    
    func placeholder(in context: Context) -> CalendarEntry {
        CalendarEntry(date: Date(), emoji: "😀", days: [])
    }
    
    @MainActor func getSnapshot(in context: Context, completion: @escaping (CalendarEntry) -> ()) {
        do {
            let entry = CalendarEntry(date: Date(), emoji: "😺", days: fetchDays())
            completion(entry)
        }
    }
    
    @MainActor func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        do {
            let entry = CalendarEntry(date: Date(), emoji: "😺", days: fetchDays())
            let timeline = Timeline(entries: [entry], policy: .after(.now.endOfDay))
            completion(timeline)
        }
    }
    
    @MainActor func fetchDays() -> [Day] {
        var sharedStoreURL: URL {
            let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.mx.datafox.SwiftCal")!
            return container.appendingPathComponent("SwiftCal.sqlite")
        }
        
        let container: ModelContainer = {
            let config = ModelConfiguration(url: sharedStoreURL)
            return try! ModelContainer(for: Day.self, configurations: config)
        }()
        
        var startDate: Date { .now.startOfCalendarWithPrefixDays }
        var endDate: Date { .now.endOfMonth }
        
        let predicate =  #Predicate<Day> { $0.date > startDate && $0.date < endDate }
        let descriptor = FetchDescriptor<Day>(predicate: predicate, sortBy: [.init(\.date)])
        
        return try! container.mainContext.fetch(descriptor)
    }
}

struct CalendarEntry: TimelineEntry {
    let date: Date
    let emoji: String
    let days: [Day]
}

struct SwiftCalWidgetEntryView : View {
    var entry: CalendarEntry
    
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        HStack {
            Link(destination: URL(string: "streak")!) {
                VStack {
                    Text("\(calculateStreakValue())")
                        .font(.system(size: 70, design: .rounded))
                        .bold()
                        .foregroundStyle(.green)
                    
                    Text("Racha (días)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } // VStack
//                .widgetURL(URL?) para small widgets (no puede hbaer varios)
            } // Link
            
            VStack {
                Link(destination: URL(string: "calendar")!) {
                    CalendarHeaderView(font: .caption)
                    
                    LazyVGrid(columns: columns, spacing: 7) {
                        ForEach(entry.days) { day in
                            if day.date.monthInt != Date().monthInt {
                                Text(" ")
                            } else {
                                Text(day.date.formatted(.dateTime.day()))
                                    .font(.caption2)
                                    .bold()
                                    .frame(maxWidth: .infinity)
                                    .foregroundStyle(day.didStudy ? .green : .secondary)
                                    .background(
                                        Circle()
                                            .foregroundStyle(.green.opacity(day.didStudy ?  0.3: 0.0))
                                            .scaleEffect(1.5)
                                    )
                            }
                        } // Loop
                    } // LazyVGrid
                } // VStack
            } // Link
            .padding(.leading, 6)
        }
        .padding()
    }
    
    func calculateStreakValue() -> Int {
        guard !entry.days.isEmpty else { return 0 }
        
        let nonFutureDays = entry.days.filter { $0.date.dayInt <= Date().dayInt }
        
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

struct SwiftCalWidget: Widget {
    let kind: String = "SwiftCalWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                SwiftCalWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                SwiftCalWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Swift Styduy Calendar")
        .description("Track days you study Swift.")
        .supportedFamilies([.systemMedium])
    }
}

#Preview(as: .systemMedium) {
    SwiftCalWidget()
} timeline: {
    CalendarEntry(date: .now, emoji: "😀", days: [])
    CalendarEntry(date: .now, emoji: "🤩", days: [])
}
