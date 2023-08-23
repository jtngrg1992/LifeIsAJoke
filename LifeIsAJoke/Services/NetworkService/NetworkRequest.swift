//
//  NetworkRequest.swift
//  LifeIsAJoke
//
//  Created by Jatin Garg on 23/08/23.
//

import Foundation

enum NetworkRequestType: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

protocol NetworkRequesting {
    var requestType: NetworkRequestType { get }
    var requestURL: String { get }
    var queryParams: [String: String]? { get set }
    var httpBody: Encodable? { get set }
}

extension NetworkRequesting {
    var urlRequest: URLRequest? {
        guard var urlComponents = URLComponents(string: self.requestURL) else {
            return nil
        }
        
        if let queryParams = queryParams {
            urlComponents.queryItems = []
            
            for (key, value) in queryParams {
                urlComponents.queryItems?.append(URLQueryItem(name: key, value: value.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)))
            }
        }
        
        guard let finalURL = urlComponents.url else {
            return nil
        }
        
        var urlRequest = URLRequest(url: finalURL)
        urlRequest.httpMethod = requestType.rawValue
        
        if let body = httpBody {
            let encoder = JSONEncoder()
            if
                let encodedJSON = try? encoder.encode(body),
                let jsonData = try? JSONSerialization.data(withJSONObject: encodedJSON)
            {
                urlRequest.httpBody = jsonData
            }
        }
        
        return urlRequest
    }
}


struct GetNetWorkRequest: NetworkRequesting {
    var requestType: NetworkRequestType
    var httpBody: Encodable?
    var requestURL: String
    var queryParams: [String : String]?
    
    init(requestURL: String, queryParams: [String: String]?) {
        self.requestURL = requestURL
        self.queryParams = queryParams
        self.httpBody = nil
        self.requestType = .get
    }
}
