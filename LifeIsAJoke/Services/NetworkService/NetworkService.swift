//
//  NetworkService.swift
//  LifeIsAJoke
//
//  Created by Jatin Garg on 23/08/23.
//

import Foundation

/// Some Interfaces to allow mocking network service's behaviour while writing unit tests
protocol URLSessionInterface {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

protocol JSONDecodable {
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable
}

extension JSONDecoder: JSONDecodable {
    
}

extension URLSession: URLSessionInterface {
    
}


/// A list of all possible errors that the networking service can throw
/// This has been kept very basic for the purpose of this project
/// An ideal Custom Error Enum must cases for all the possible error that a service can throw along with localized description for each case
enum NetworkingError: Error {
    case urlRequestCouldNotBeBuilt
}


protocol NetworkServicing {
    var session: URLSessionInterface { get }
    func execute<T: Decodable>(networkRequest: NetworkRequesting) async throws -> T
}

/// Inject mock URLSession and JSONDecoder objects in order to manipulate NetworkService behaviour while writing unit tests
final class NetworkService: NetworkServicing {
    let session: URLSessionInterface
    let jsonDecoder: JSONDecodable
    
    init(session: URLSessionInterface? = nil, jsonDecoder: JSONDecodable? = nil) {
        self.session = session ?? URLSession.shared
        self.jsonDecoder = jsonDecoder ?? JSONDecoder()
    }
    
    func execute<T: Decodable>(networkRequest: NetworkRequesting) async throws -> T {
        guard let urlRequest = networkRequest.urlRequest else {
            throw NetworkingError.urlRequestCouldNotBeBuilt
        }
        
        let (data, _) = try await session.data(for: urlRequest)
        let decodedData = try jsonDecoder.decode(T.self, from: data)
        return decodedData
    }
}
