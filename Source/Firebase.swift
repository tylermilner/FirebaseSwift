//
//  Firebase.swift
//  FirebaseSwift
//
//  Created by Graham Chance on 10/15/16.
//
//

import Foundation
import SwiftyJSON
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

    public init(baseURL: String = "", auth: String? = nil) {
        self.auth = auth

        var url = baseURL
        if url.characters.last != Character("/") {
            url.append(Character("/"))
        }
        self.baseURL = url

    }


    public func setValue(path: String, value: Any)->[String: Any]? {
       return put(path: path, value:  value)
    }


    public func post(path: String, value: Any)->[String: Any]? {
        return write(value: value, path: path, method: .post)
    }


    public func put(path: String, value: Any)->[String: Any]? {
        return write(value: value, path: path, method: .put)
    }

    public func patch(path: String, value: Any)->[String: Any]? {
        return write(value: value, path: path, method: .patch)
    }


    public func delete(path: String) {
        let url = completeURLWithPath(path: path)
        let result = Just.delete(url)
        if let error = result.error {
            print("DELETE Error: " + error.localizedDescription)
        }
    }


    public func get(path: String) ->Any? {

        let url = completeURLWithPath(path: path)
        let httpResult = Just.get(url)

        if let data = httpResult.content, httpResult.error == nil {
            do {
                if let jsonMap = try JSONSerialization
                                    .jsonObject(
                                        with: data,
                                        options: [JSONSerialization.ReadingOptions.allowFragments])
                                    as Any? {

                    return jsonMap
                }
            } catch let e {
                print("GET Error:" + e.localizedDescription)
            }
        } else {
            print("GET request failed.")
            if let error = httpResult.error {
                print(error)
            }
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


    private func write(value: Any, path: String, method: Method)->[String: Any]? {

        let url = completeURLWithPath(path: path)
        let params = [String: Any]()
        let data = [String: Any]()
        let json: Any? = JSONSerialization.isValidJSONObject(value) ? value : [".value": value]
        let headers = ["Accept": "application/json"]
        let files = [String: HTTPFile]()
        let auth: (String, String)? = nil
        let cookies = [String: String]()
        let allowRedirects = false
        let requestBody: Data? = nil
        let urlQuery: String? = nil
        let completion: ((HTTPResult)->())? = nil
        let progress: (TaskProgressHandler)? = nil

        let result: HTTPResult?
        switch method {
        case .put:
            result = Just.put(url, params: params, data: data, json: json, headers: headers,
                              files: files, auth: auth, cookies: cookies, allowRedirects: allowRedirects,
                              timeout: timeout, requestBody: requestBody, URLQuery: urlQuery,
                              asyncProgressHandler: progress, asyncCompletionHandler: completion)
        case .post:
            result = Just.post(url, params: params, data: data, json: json, headers: headers,
                               files: files, auth: auth, cookies: cookies, allowRedirects: allowRedirects,
                               timeout: timeout, requestBody: requestBody, URLQuery: urlQuery,
                               asyncProgressHandler: progress, asyncCompletionHandler: completion)
        case .patch:
            result = Just.patch(url, params: params, data: data, json: json, headers: headers,
                                files: files, auth: auth, cookies: cookies, allowRedirects: allowRedirects,
                                timeout: timeout, requestBody: requestBody, URLQuery: urlQuery,
                                asyncProgressHandler: progress, asyncCompletionHandler: completion)
        default:
            result = nil
        }

        do {
            if let data = result?.content,
                let jsonMap = try JSONSerialization
                                  .jsonObject(
                                      with: data,
                                      options: [JSONSerialization.ReadingOptions.allowFragments]) 
                                  as? [String: Any] {

                return jsonMap
            }
        } catch let e {
            print(method.rawValue + " Error: " + e.localizedDescription)
        }

        return nil
    }

}
