# FirebaseSwift
[![Build Status](https://api.travis-ci.org/vapor/vapor.svg?branch=master)](https://travis-ci.org/vapor/vapor) [![Language](https://img.shields.io/badge/language-Swift%203.0-orange.svg)](https://swift.org) ![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)

FirebaseSwift is intended for server-side Swift and acts as a wrapper around the Firebase REST api. All calls are synchronous.

## Swift Package Manager
```swift
.Package(url: "https://github.com/gtchance/FirebaseSwift.git", majorVersion: 1, minor: 1)
```

## Example
```swift
let firebase = Firebase(baseURL: "https://myapp.firebaseio.com/", auth: "mytoken")
```


##### GET
```swift
let users = firebase.get("user")
```

##### PUSH
```swift
let newUser = [
  "name": "John",
  "email": "john@example.com"
]
let response = firebase.push(path: "user", value: newUser)
print(response) // ["name": "john_id"]
```

##### PUT
```swift
let updatedUser = [
  "name": "John Smith",
  "email": "john_smith@example.com"
]
// can also use setValue(path: ..., value: ...)
let response = firebase.put(path: "user/john_id", value: updatedUser) 
```

##### DELETE
```swift
firebase.delete("user/john_id")
```

##### PATCH
```swift
let response = firebase.patch(path: "user/john_id", value: ["middleInitial: "T"])
```

Refer to the following for documentation on the Firebase REST API: https://firebase.google.com/docs/reference/rest/database/

##### I AM  NOT AFFILIATED WITH GOOGLE OR FIREBASE IN ANY WAY


If you experience any bugs, please create an issue or submit a pull request.
