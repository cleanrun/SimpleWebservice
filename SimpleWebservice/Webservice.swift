//
//  Webservice.swift
//  SimpleWebservice
//
//  Created by cleanmac-ada on 18/12/22.
//

import Foundation

final public class Webservice {
    
    enum HTTPMethod: String {
        case post = "POST"
        case get = "GET"
        case put = "PUT"
        case patch = "PATCH"
        case delete = "DELETE"
    }
    
    private typealias Response = (Data, URLResponse)
    public typealias Route = String
    
    /// The shared singleton service object.
    static let shared = Webservice()
    
    private init() {}
    
    /// Perform a HTTP request from a certain URL
    ///
    /// This function requires 2 generics parameter for both decoding the response value and the back-end errors.
    /// Other than that, the remaining parameters is optional and has a default value. But you could still configure it based on your needs.
    /// - Parameters:
    ///   - route: The endpoint of the URL. If it's not a valid URL, then the function will throw an Invalid URL error
    ///   - type: The type for decoding the return value. Must conform to either `Codable` or `Decodable` protocol
    ///   - errorType: The type for decoding the error payload value. Must conform to `WebserviceErrorPayload`
    ///   - method: The HTTP method type. Consist: POST, GET, PUT, PATCH, and DELETE
    ///   - headerFields: The HTTP Header fields required for this request, pass `nil` if no header is necessary to perform this request
    ///   - body: The HTTP body required for this request, pass `nil` if no body is necessary to perform this request
    /// - Returns: Returns the decoded data of the URL Request
    func request<T: Decodable, E: WebserviceErrorPayload>(
        _ route: Route,
        type: T.Type,
        errorType: E.Type,
        method: HTTPMethod = .get,
        headerFields: [HeaderField: String]? = nil,
        body: [String: Any]? = nil,
        timeoutInterval: TimeInterval = 60)
    async throws -> T {
        if let url = URL(string: route) {
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            request.timeoutInterval = timeoutInterval
            
            if let headerFields {
                for field in headerFields {
                    request.setValue(field.value, forHTTPHeaderField: field.key.rawValue)
                }
            }
            
            if let body {
                let jsonDecodedBody = try JSONSerialization.data(withJSONObject: body)
                request.httpBody = jsonDecodedBody
            }
            
            let response: Response = try await URLSession.shared.data(for: request)
            if let httpResponse = response.1 as? HTTPURLResponse {
                if (200...299).contains(httpResponse.statusCode) {
                    let returnValue = try JSONDecoder().decode(T.self, from: response.0)
                    return returnValue
                } else if (400...).contains(httpResponse.statusCode) {
                    let jsonDecodedErrorPayload = try JSONDecoder().decode(E.self, from: response.0)
                    throw WebserviceError.httpError(code: httpResponse.statusCode, payload: jsonDecodedErrorPayload)
                } else {
                    throw WebserviceError.httpError(code: httpResponse.statusCode, payload: nil)
                }
            } else {
                throw WebserviceError.other(message: "HTTP URL Response is invalid")
            }
        } else {
            throw WebserviceError.invalidUrl
        }
    }
    
    func upload() {
        
    }
    
    func download() {
        
    }
    
}

