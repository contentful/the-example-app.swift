//
//  Copyright © 2020 Contentful. All rights reserved.
//

import Foundation

extension Date {

    func isEqualTo(_ date: Date) -> Bool {
        // Strip units smaller than seconds from the date
        let comparableComponenets: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second, .timeZone]
        guard let newSelf = Calendar.current.date(from: Calendar.current.dateComponents(comparableComponenets, from: self)) else {
            fatalError("Failed to strip milliseconds from Date object")
        }
        guard let newComparisonDate = Calendar.current.date(from: Calendar.current.dateComponents(comparableComponenets, from: date)) else {
            fatalError("Failed to strip milliseconds from Date object")
        }

        return newSelf == newComparisonDate
    }
}
