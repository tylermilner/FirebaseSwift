//
//  Firebase.swift
//  FirebaseSwift
//
//  Created by Graham Chance on 10/15/16.
//
//

import Foundation
import PerfectCURL
import cURL
import SwiftyJSON

private enum CurlMethod: String {
    case delete = "DELETE"
    case post = "POST"
    case get = "GET"
    case patch = "PATCH"
    case put = "PUT"
}

public class Firebase {

    public var auth: String?

    public let baseURL: String

    public let timeout = 30 // seconds

    public init(baseURL: String = "", auth: String? = nil) {
        self.auth = auth

        var url = baseURL
        if url.characters.last != Character("/") {
            url.append(Character("/"))
        }
        self.baseURL = url

    }


    public func post(path: String, value: Any)->[String: AnyObject]? {
        return write(value: value, path: path, method: .post)
    }

    public func put(path: String, value: Any)->[String: AnyObject]? {
        return write(value: value, path: path, method: .put)
    }

    public func patch(path: String, value: Any)->[String: AnyObject]? {
        return write(value: value, path: path, method: .patch)
    }

    public func delete(path: String) {
        let url = completeURLWithPath(path: path)
        let curl = createCurl(url: url, type: .delete)
        let response = curl.performFully()
        print(response.0)
    }


    public func get(path: String) ->AnyObject? {

        let url = completeURLWithPath(path: path)
        let curl = createCurl(url: url, type: .get)

        let response = curl.performFully()
        let data = Data(response.2)

        curl.close()

        do {
            if let jsonMap = try JSONSerialization.jsonObject(with: data, options: [JSONSerialization.ReadingOptions.allowFragments]) as AnyObject? {
                return jsonMap
            }
        } catch let e {
            print(e.localizedDescription)
        }
        return nil

    }




    private func completeURLWithPath(path: String)->String {
        var url = baseURL + path + ".json"
        if let auth = auth {
            url += "?auth=" + auth
        }
        return url
    }


    private func createCurl(url: String, type: CurlMethod)->CURL {
        let curl = CURL(url: url)
        let _ = curl.setOption(CURLOPT_CUSTOMREQUEST, s: type.rawValue)
        let _ = curl.setOption(CURLOPT_TIMEOUT, int: timeout)
        let _ = curl.setOption(CURLOPT_CONNECTTIMEOUT, int: timeout)
        let _ = curl.setOption(CURLOPT_HTTPHEADER, s: "Accept: application/json")
        return curl
    }


    private func write(value: Any, path: String, method: CurlMethod)->[String: AnyObject]? {
        do {
            let bytes = try createBytes(value: value)
            let url = completeURLWithPath(path: path)

            let curl = createCurl(url: url, type: method)
            let _ = curl.setOption(CURLOPT_POSTFIELDS, v: UnsafeMutableRawPointer(mutating: bytes))
            let _ = curl.setOption(CURLOPT_POSTFIELDSIZE, int: bytes.count)

            let response = curl.performFully()
            let data = Data(response.2)
            curl.close()

            if let jsonMap = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                return jsonMap
            } else {
                print("Firebase response not a valid UTF-8 sequence")
            }

        } catch let e {
            print(e.localizedDescription)
        }

        return nil
    }


    private func createBytes(value: Any) throws ->[UInt8] {
        let json = JSON(value)
        let data = try json.rawData()
        let array = data.withUnsafeBytes {
            [UInt8](UnsafeBufferPointer(start: $0, count: data.count))
        }
        return array
    }

}
