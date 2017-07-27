# FirebaseSwift
[![Build Status](https://api.travis-ci.org/gtchance/FirebaseSwift.svg?branch=master)](https://travis-ci.org/gtchance/FirebaseSwift) [![codebeat badge](https://codebeat.co/badges/e7704190-f407-4d32-8d96-8854b0040755)](https://codebeat.co/projects/github-com-gtchance-firebaseswift-master) [![Language](https://img.shields.io/badge/language-Swift%203.1-orange.svg)](https://swift.org) ![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)

FirebaseSwift is intended for server-side Swift and acts as a wrapper around the Firebase REST api. Options for both synchronous and asynchronous calls.

## Swift Package Manager
```swift
.Package(url: "https://github.com/gtchance/FirebaseSwift.git", majorVersion: 1, minor: 3)
```

## Example
```swift
let firebase = Firebase(baseURL: "https://myapp.firebaseio.com/", auth: "mytoken")
```


##### GET
```swift
// sync
let user = firebase.get("user")

// async
firebase.get("user") { user in
  // ...
}
```

##### PUSH
```swift
let newUser = [
  "name": "John",
  "email": "john@example.com"
]
// sync
let response = firebase.push(path: "user", value: newUser)
print(response) // ["name": "john_id"]

// async
firebase.push(path: "user", value: newUser) { response in
  // ...
}
```

##### PUT
```swift
let updatedUser = [
  "name": "John Smith",
  "email": "john_smith@example.com"
]
// can also use setValue(path: ..., value: ...)
// sync
let response = firebase.put(path: "user/john_id", value: updatedUser)

// async
firebase.put(path: "user/john_id", value: updatedUser) { response in
  // ...
}
```

##### DELETE
```swift
// sync
let deleted = firebase.delete("user/john_id")

// async
firebase.delete("user/john_id") { deleted in
  // ...
}
```

##### PATCH
```swift
// sync
let response = firebase.patch(path: "user/john_id", value: ["middleInitial: "T"])

// async
firebase.patch(path: "user/john_id", value: ["middleInitial: "T"]) { response in
  // ...
}
```

Refer to the following for documentation on the Firebase REST API: https://firebase.google.com/docs/reference/rest/database/

##### I AM  NOT AFFILIATED WITH GOOGLE OR FIREBASE IN ANY WAY


If you experience any bugs, please create an issue or submit a pull request.
