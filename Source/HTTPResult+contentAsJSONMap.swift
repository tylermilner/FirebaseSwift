//
//  HTTPResult+contentAsJSONMap.swift
//  FirebaseSwift
//
//  Created by Graham Chance on 10/20/16.
//
//

import Foundation
import SwiftyJSON
import Just

extension HTTPResult {

    /// Converts an HTTPResult to json
    ///
    /// - Returns: A json object
    func contentAsJSONMap() -> Any? {
        if let data = content {
            return JSON(data: data).object
        }
        return nil
    }

}
