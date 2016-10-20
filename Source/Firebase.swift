//
//  Firebase.swift
//  FirebaseSwift
//
//  Created by Graham Chance on 10/15/16.
//
//

import Foundation
import Just


private enum Method: String {
    case delete = "DELETE"
    case post = "POST"
    case get = "GET"
    case patch = "PATCH"
    case put = "PUT"
}

public class Firebase {

    public var auth: String?
    public let baseURL: String
    public let timeout: Double = 30.0 // seconds

    private let headers = ["Accept": "application/json"]


    public init(baseURL: String = "", auth: String? = nil) {
        self.auth = auth

        var url = baseURL
        if url.characters.last != Character("/") {
            url.append(Character("/"))
        }
        self.baseURL = url

    }


    public func setValue(path: String, value: Any)->[String: AnyObject]? {
       return put(path: path, value:  value)
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


    public func delete(path: String)->[String: AnyObject]? {
        let url = completeURLWithPath(path: path)

        let result = Just.delete(url, params: [:], data: [:], json: nil, headers: headers,
                          files: [:], auth: nil, cookies: [:], allowRedirects: false,
                          timeout: timeout, URLQuery: nil, requestBody: nil,
                          asyncProgressHandler: nil, asyncCompletionHandler: nil)

        if let error = result.error {
            print("DELETE Error: \(error.localizedDescription)")
            return nil
        }

        do {
            if let jsonMap = try result.contentAsJSONMap() as? [String: AnyObject] {
                return jsonMap
            }
        } catch let e {
            print("DELETE Error: \(e.localizedDescription)")
        }

        return nil
    }

    public func get(path: String)->Any? {

        let url = completeURLWithPath(path: path)

        let httpResult = Just.get(url, params: [:], data: [:], json: nil, headers: headers,
                          files: [:], auth: nil, allowRedirects: false, cookies: [:],
                          timeout: timeout, requestBody: nil, URLQuery: nil,
                          asyncProgressHandler: nil, asyncCompletionHandler: nil)

        if let error = httpResult.error {
            print("GET Error: \(error.localizedDescription)")
            return nil
        }

        do {
            if let jsonMap = try httpResult.contentAsJSONMap() {
                return jsonMap
            }
        } catch let e {
            print("GET Error: \(e.localizedDescription)")
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


    private func write(value: Any, path: String, method: Method)->[String: AnyObject]? {

        let url = completeURLWithPath(path: path)
        let json: Any? = JSONSerialization.isValidJSONObject(value) ? value : [".value": value]

        let result: HTTPResult!
        switch method {
        case .put:
            result = Just.put(url, params: [:], data: [:], json: json, headers: headers,
                              files: [:], auth: nil, cookies: [:], allowRedirects: false,
                              timeout: timeout, requestBody: nil, URLQuery: nil,
                              asyncProgressHandler: nil, asyncCompletionHandler: nil)
        case .post:
            result = Just.post(url, params: [:], data: [:], json: json, headers: headers,
                               files: [:], auth: nil, cookies: [:], allowRedirects: false,
                               timeout: timeout, requestBody: nil, URLQuery: nil,
                               asyncProgressHandler: nil, asyncCompletionHandler: nil)
        case .patch:
            result = Just.patch(url, params: [:], data: [:], json: json, headers: headers,
                                files: [:], auth: nil, cookies: [:], allowRedirects: false,
                                timeout: timeout, requestBody: nil, URLQuery: nil,
                                asyncProgressHandler: nil, asyncCompletionHandler: nil)
        default:
            return nil
        }

        if let error = result.error {
            print(method.rawValue + " Error: " + error.localizedDescription)
            return nil
        }

        do {
            if let jsonMap = try result.contentAsJSONMap() as? [String: AnyObject] {
                return jsonMap
            }
        } catch let e {
            print(method.rawValue + " Error: " + e.localizedDescription)
        }

        return nil
    }

}
