# firebase-swift
[![Build Status](https://api.travis-ci.org/gtchance/firebase-swift.svg?branch=master)](https://travis-ci.org/gtchance/firebase-swift) [![Language](https://img.shields.io/badge/language-Swift%203.1-orange.svg)](https://swift.org) ![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)

firebase-swift is intended for server-side Swift and acts as a wrapper around the Firebase REST api. Options for both synchronous and asynchronous calls.


* [firebase-swift Documentation](https://gtchance.github.io/firebase-swift/Classes/Firebase.html)

* [Firebase REST API Documentation](https://firebase.google.com/docs/reference/rest/database/)

## Swift Package Manager
```swift
.Package(url: "https://github.com/gtchance/firebase-swift.git", majorVersion: 1, minor: 6)
```


## Example
```swift
let firebase = Firebase(
baseURL: "https://myapp.firebaseio.com/",
accessToken: "<MY_GOOGLE_OAUTH2_ACCESS_TOKEN>")
```

##### AUTH
See instructions [here](https://firebase.google.com/docs/database/rest/auth) on creating an access token.

If you want to use the deprecated Firebase Database Secret, use the auth property: 

```swift
// Deprecated by Firebase. Use access token in the main example instead.
let firebase = Firebase(baseURL: "https://myapp.firebaseio.com/")
firebase.auth = "<MY_DATABASE_SECRET>"

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

##### POST
```swift
let newUser = [
  "name": "John",
  "email": "john@example.com"
]
// sync
let result = firebase.post(path: "user", value: newUser)
print(result) // ["name": "john_id"]

// async
firebase.post(path: "user", value: newUser) { result in
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
firebase.put(path: "user/john_id", value: updatedUser) { result in
  // ...
}
```

##### DELETE
```swift
// sync
firebase.delete("user/john_id")

// async
firebase.delete("user/john_id") {
  // ...
}
```

##### PATCH
```swift
// sync
let result = firebase.patch(path: "user/john_id", value: ["middleInitial": "T"])

// async
firebase.patch(path: "user/john_id", value: ["middleInitial": "T"]) { result in
  // ...
}
```


##### I AM  NOT AFFILIATED WITH GOOGLE OR FIREBASE IN ANY WAY


If you experience any bugs, please create an issue or submit a pull request.
