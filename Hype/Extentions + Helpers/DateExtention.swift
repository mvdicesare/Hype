//
//  DateExtention.swift
//  Hype
//
//  Created by Michael Di Cesare on 10/14/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import Foundation



extension Date {
    func formatDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        return formatter.string(from: self)
    }
}
