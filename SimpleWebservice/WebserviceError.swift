//
//  WebserviceError.swift
//  SimpleWebservice
//
//  Created by cleanmac-ada on 18/12/22.
//

import Foundation

public protocol WebserviceErrorPayload: Decodable {}

public enum WebserviceError: Error {
    case invalidUrl
    case httpError(code: Int, payload: WebserviceErrorPayload?)
    case noConnection
    case other(message: String)
}

