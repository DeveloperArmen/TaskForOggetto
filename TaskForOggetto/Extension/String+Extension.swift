//
//  String+Extension.swift
//  TaskForOggetto
//
//  Created by Armen Alikhanyan on 12/8/20.
//

import Foundation

extension String {
    func removeAllExtraCharacters() -> String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
    
    func dateFromString(format: String? = nil) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = format ?? "E MMM dd HH:mm:ss zzz yyyy"

        return formatter.date(from: self) ?? Date()
    }
}
