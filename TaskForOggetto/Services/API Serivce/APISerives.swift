//
//  APISerives.swift
//  TaskForOggetto
//
//  Created by Armen Alikhanyan on 12/7/20.
//

import Foundation

class APIService {
    
    private let sourcesURLstring = "https://jobs.github.com/positions.json?page="
    
    func getJobs(forPgae pageNumber: Int,
                 failure : @escaping (ServerResponseType) -> (),
                 success : @escaping ([JobData]) -> ()) {
        let url = URL(string: sourcesURLstring + String(pageNumber))!
        URLSession.shared.dataTask(with: url) {data, urlResponse, error in
            if let data = data {
                let jsonDecoder = JSONDecoder()
                
                do {
                    let jobs = try jsonDecoder.decode([JobData].self, from: data)
                    if jobs.count > 0 {
                        success(jobs)
                    } else {
                        failure(.NotData)
                    }
                    
                } catch {
                    failure(.ParsingError)
                }
            } else {
                if error == nil {
                    failure(.NotData)
                } else {
                    failure(.ServerError)
                }
            }
        }.resume()
    }
    
}
