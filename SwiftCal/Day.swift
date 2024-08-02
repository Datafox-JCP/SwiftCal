//
//  Day.swift
//  SwiftCal
//
//  Created by Juan Hernandez Pazos on 31/07/24.
//
//

import Foundation
import SwiftData

@Model class Day {
    var date: Date
    var didStudy: Bool
    
    init(date: Date, didStudy: Bool) {
        self.date = date
        self.didStudy = didStudy
    }
}
