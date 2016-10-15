# firebase-swift


## Example
```swift
let firebase = Firebase(baseURI: "https://myapp.firebaseio.com", auth: "mytoken")
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
