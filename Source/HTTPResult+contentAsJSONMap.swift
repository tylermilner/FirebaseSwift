//
//  HTTPResult+contentAsJSONMap.swift
//  FirebaseSwift
//
//  Created by Graham Chance on 10/20/16.
//
//

import Foundation
import Just

extension HTTPResult {

    /// Converts an HTTPResult to json
    ///
    /// - Returns: A json object
    /// - Throws: JSONSerialization error
    func contentAsJSONMap() throws ->Any? {
        if let data = content {
            if let jsonMap = try JSONSerialization
                                .jsonObject(
                                    with: data,
                                    options: [JSONSerialization.ReadingOptions.allowFragments])
                                as Any? {

                return jsonMap
            }
        }
        return nil
    }

}
