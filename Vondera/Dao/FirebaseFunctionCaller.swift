//
//  FirebaseFunctionCaller.swift
//  Vondera
//
//  Created by Shreif El Sayed on 03/10/2023.
//

import Foundation
import FirebaseFunctions

class FirebaseFunctionCaller {

    func callFunction(functionName: String, data: [String: Any]?) async throws -> HTTPSCallableResult  {
        let functions = Functions.functions()
        if data == nil {
            return try await functions.httpsCallable(functionName).call()
        } else {
            return try await functions.httpsCallable(functionName).call(data)
        }
    }
}
