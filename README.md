# FirebaseSwift

FirebaseSwift is intended for server-side Swift and acts as a wrapper around the Firebase REST api. All calls are synchronous.

## Swift Package Manager
```swift 
.Package(url: "https://github.com/gtchance/FirebaseSwift.git", majorVersion: 1, minor: 0)
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
let response = firebase.push(path: "user/john_id", value: updatedUser)
```

##### DELETE
```swift
firebase.delete("user/john_id")
```

###### PATCH also available

Refer to https://firebase.google.com/docs/reference/rest/database/ for documentation on the Firebase REST API.

* I AM  NOT AFFILIATED WITH GOOGLE OR FIREBASE IN ANYWAY *
