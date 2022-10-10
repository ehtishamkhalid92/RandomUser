//
//  Networking.swift
//  RU
//
//  Created by Ehtisham Khalid on 10.10.22.
//

import Foundation

extension URLSession {
    
    func fetchData(at url: URL, completion: @escaping (Swift.Result<Users, Error>) -> Void) {
        self.dataTask(with: url) { data, response, error in
            if data != nil && error == nil {
                do {
                    let fetchData = try JSONDecoder().decode(Users.self, from: data!)
                    completion(.success(fetchData))
                }catch {
                    completion(.failure(error))
                }
            }
        }.resume()
        
    }
}
