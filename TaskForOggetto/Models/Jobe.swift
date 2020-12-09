//
//  Jobe.swift
//  TaskForOggetto
//
//  Created by Armen Alikhanyan on 12/7/20.
//
import Foundation

// MARK: - Jobs

enum ServerResponseType: String {
    case NotData = "Не удалось найти вакансии"
    case ParsingError = "Произошла ошибка при обработке данных"
    case ServerError = "При подключении к серверу произошла ошибка. Повторите попытку позже."
}

// MARK: - JobData

struct JobData: Decodable {
    let title, company, howToApply, createdAt, description: String
    let realDate: Date

    enum CodingKeys: String, CodingKey {
        case title = "title"
        case company = "company"
        case howToApply = "how_to_apply"
        case createdAt = "created_at"
        case description = "description"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        company = try container.decode(String.self, forKey: .company)
        howToApply = try container.decode(String.self, forKey: .howToApply).removeAllExtraCharacters()
        
        let dateString = try container.decode(String.self, forKey: .createdAt)
        createdAt = dateString.dateFromString().correctedStringFromDate()
        description = try container.decode(String.self, forKey: .description).removeAllExtraCharacters()
        realDate = dateString.dateFromString()
    }
}
