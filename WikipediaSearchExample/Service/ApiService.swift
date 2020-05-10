//
//  ApiService.swift
//  WikipediaSearchExample
//
//  Created by Soso on 2020/05/09.
//  Copyright © 2020 Soso. All rights reserved.
//

import Foundation
import RxSwift

class ApiService {
    static let url = "https://en.wikipedia.org/w/api.php?action=opensearch&limit=10&namespace=0&format=json&search="
    static func fetchSearchRx(text: String) -> Observable<SearchResponse> {
        return Observable.create { emitter in
            fetchSearch(text: text) { result in
                switch result {
                case let .success(data):
                    emitter.onNext(data)
                    emitter.onCompleted()
                case let .failure(error):
                    emitter.onError(error)
                }
            }
            return Disposables.create()
        }
    }

    static func fetchSearch(text: String, onComplete: @escaping (Result<SearchResponse, Error>) -> Void) {
        guard let string = "\(url)\(text)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        guard let url = URL(string: string) else { return }
        URLSession.shared.dataTask(with: url) { data, res, err in
            if let err = err {
                onComplete(.failure(err))
                return
            }
            guard let data = data else {
                let httpResponse = res as! HTTPURLResponse
                onComplete(.failure(NSError(domain: "no data",
                                            code: httpResponse.statusCode,
                                            userInfo: nil)))
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let response = try decoder.decode(SearchResponse.self, from: data)
                onComplete(.success(response))
            } catch {
                onComplete(.failure(error))
            }
        }.resume()
    }
}

struct SearchResponse: Codable {
    let text: String
    let titles: [String]
    let descriptions: [String]
    let urls: [String]

    init(from decoder: Decoder) throws {
        var unkeyedContainer = try decoder.unkeyedContainer()
        text = try unkeyedContainer.decode(String.self)
        titles = try unkeyedContainer.decode([String].self)
        descriptions = try unkeyedContainer.decode([String].self)
        urls = try unkeyedContainer.decode([String].self)
    }
    
}
