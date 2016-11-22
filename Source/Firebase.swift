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

    public func setValueAsync(path: String, value: Any, complete: @escaping ([String: AnyObject]?)->()) {
        putAsync(path: path, value:  value, complete: complete)
    }

    public func post(path: String, value: Any)->[String: AnyObject]? {
        return write(value: value, path: path, method: .post, complete: nil)
    }

    public func postAsync(path: String, value: Any, complete: @escaping ([String: AnyObject]?)->()) {
        let _ = write(value: value, path: path, method: .post, complete: complete)
    }

    public func put(path: String, value: Any)->[String: AnyObject]? {
        return write(value: value, path: path, method: .put, complete: nil)
    }

    public func putAsync(path: String, value: Any, complete: @escaping ([String: AnyObject]?)->()) {
        let _ = write(value: value, path: path, method: .put, complete: complete)
    }

    public func patch(path: String, value: Any)->[String: AnyObject]? {
        return write(value: value, path: path, method: .patch, complete: nil)
    }

    public func patchAsync(path: String, value: Any, complete: @escaping ([String: AnyObject]?)->()) {
        let _ = write(value: value, path: path, method: .patch, complete: complete)
    }

    public func delete(path: String)->[String: AnyObject]? {
        return delete(path: path, complete: nil)
    }

    public func deleteAsync(path: String, complete: @escaping ([String: AnyObject]?)->()) {
        let _ = delete(path: path, complete: complete)
    }

    public func get(path: String)->Any? {
        return get(path: path, complete: nil)
    }

    public func getAsync(path: String, complete: @escaping (Any?)->()) {
        let _ = get(path: path, complete: complete)
    }


    private func delete(path: String, complete: (([String: AnyObject]?)->())?)->[String: AnyObject]? {

        let url = completeURLWithPath(path: path)

        var completionHandler: ((HTTPResult)->())? = nil
        if let complete = complete {
            completionHandler = { result in
                complete(self.process(httpResult: result, method: .delete))
            }
        }

        let result = Just.delete(url, params: [:], data: [:], json: nil, headers: headers,
                                 files: [:], auth: nil, cookies: [:], allowRedirects: false,
                                 timeout: timeout, URLQuery: nil, requestBody: nil,
                                 asyncProgressHandler: nil, asyncCompletionHandler: completionHandler)

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

        guard complete == nil else { return nil }
        return process(httpResult: result, method: .delete)
    }


    private func get(path: String, complete: ((Any?)->())?)->Any? {

        let url = completeURLWithPath(path: path)

        var completionHandler: ((HTTPResult)->())? = nil
        if let complete = complete {
            completionHandler = { result in
                complete(self.process(httpResult: result, method: .get))
            }
        }

        let httpResult = Just.get(url, params: [:], data: [:], json: nil, headers: headers,
                                  files: [:], auth: nil, allowRedirects: false, cookies: [:],
                                  timeout: timeout, requestBody: nil, URLQuery: nil,
                                  asyncProgressHandler: nil, asyncCompletionHandler: completionHandler)

        guard complete == nil else { return nil }
        return process(httpResult: httpResult, method: .get)
    }


    private func write(value: Any, path: String, method: Method, complete: (([String: AnyObject]?)->())?)->[String: AnyObject]? {

        let url = completeURLWithPath(path: path)
        let json: Any? = JSONSerialization.isValidJSONObject(value) ? value : [".value": value]

        var completionHandler: ((HTTPResult)->())? = nil
        if let complete = complete {
            completionHandler = { result in
                complete(self.process(httpResult: result, method: method))
            }
        }

        let result: HTTPResult!
        switch method {
        case .put:
            result = Just.put(url, params: [:], data: [:], json: json, headers: headers,
                              files: [:], auth: nil, cookies: [:], allowRedirects: false,
                              timeout: timeout, requestBody: nil, URLQuery: nil,
                              asyncProgressHandler: nil, asyncCompletionHandler: completionHandler)
        case .post:
            result = Just.post(url, params: [:], data: [:], json: json, headers: headers,
                               files: [:], auth: nil, cookies: [:], allowRedirects: false,
                               timeout: timeout, requestBody: nil, URLQuery: nil,
                               asyncProgressHandler: nil, asyncCompletionHandler: completionHandler)
        case .patch:
            result = Just.patch(url, params: [:], data: [:], json: json, headers: headers,
                                files: [:], auth: nil, cookies: [:], allowRedirects: false,
                                timeout: timeout, requestBody: nil, URLQuery: nil,
                                asyncProgressHandler: nil, asyncCompletionHandler: completionHandler)
        default:
            return nil
        }

        guard complete == nil else { return nil }
        return process(httpResult: result, method: method)
    }


    private func completeURLWithPath(path: String)->String {
        var url = baseURL + path + ".json"
        if let auth = auth {
            url += "?auth=" + auth
        }
        return url
    }

    private func process(httpResult: HTTPResult, method: Method)->[String: AnyObject]? {
        if let error = httpResult.error {
            print(method.rawValue + " Error: " + error.localizedDescription)
            return nil
        }

        do {
            if let jsonMap = try httpResult.contentAsJSONMap() as? [String: AnyObject] {
                return jsonMap
            }
        } catch let e {
            print(method.rawValue + " Error: " + e.localizedDescription)
        }
        return nil
    }

}
