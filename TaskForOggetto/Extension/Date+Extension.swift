//
//  Date+Extension.swift
//  TaskForOggetto
//
//  Created by Armen Alikhanyan on 12/9/20.
//

import Foundation

extension Date {

    func correctedStringFromDate(format: String? = nil) -> String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(self) {
            return "Cегодня"
        }
        
        if Calendar.current.isDateInYesterday(self) {
           return "Вчера"
        }
        
        formatter.dateFormat = format ?? "dd/MM/yyyy"
        
        return formatter.string(from: self)
    }
}
