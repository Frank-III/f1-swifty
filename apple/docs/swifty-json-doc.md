***

```markdown
[<img src="https://github.com/SwiftyJSON/SwiftyJSON/raw/master/logo.png" alt="SwiftyJSON" width="512"/>](https://github.com/SwiftyJSON/SwiftyJSON)

<p align="center">
    <a href="https://github.com/SwiftyJSON/SwiftyJSON/actions">
        <img src="https://github.com/SwiftyJSON/SwiftyJSON/workflows/CI/badge.svg" alt="CI Status">
    </a>
    <a href="https://swift.org/package-manager/">
        <img src="https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg" alt="SwiftPM compatible">
    </a>
    <a href="https://cocoapods.org/pods/SwiftyJSON">
        <img src="https://img.shields.io/cocoapods/v/SwiftyJSON.svg" alt="CocoaPods compatible">
    </a>
    <a href="https://github.com/Carthage/Carthage">
        <img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat" alt="Carthage compatible">
    </a>
    <a href="https://codebeat.co/projects/github-com-swiftyjson-swiftyjson">
        <img alt="codebeat badge" src="https://codebeat.co/badges/a9a2d3cb-8356-4992-8a90-2c7f46049a40" />
    </a>
    <a href="https://github.com/SwiftyJSON/SwiftyJSON/blob/master/LICENSE">
      <img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License">
    </a>
</p>

The better way to deal with JSON data in Swift.

## Contents

* [Requirements](#requirements)
* [Installation](#installation)
  * [Swift Package Manager](#swift-package-manager)
  * [CocoaPods](#cocoapods)
  * [Carthage](#carthage)
  * [Manually](#manually)
* [Usage](#usage)
  * [Initialization](#initialization)
  * [Subscript](#subscript)
  * [Optional/Non-Optional Getters](#optionalnon-optional-getters)
  * [Setters](#setters)
  * [Raw object](#raw-object)
  * [Existence](#existence)
  * [Loop](#loop)
  * [Error](#error)
  * [Literal Convertibles](#literal-convertibles)
  * [Printable](#printable)
  * [Merging](#merging)
* [Integration with other libraries](#integration-with-other-libraries)
  * [Alamofire](#alamofire)
* [License](#license)

## Requirements
* iOS 9.0+ / macOS 10.10+ / tvOS 9.0+ / watchOS 2.0+
* Xcode 11+
* Swift 5.1+

## Installation
### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Once you have your Swift package set up, adding SwiftyJSON as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "4.0.0")
]
```
### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate SwiftyJSON into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

pod 'SwiftyJSON'
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks. To integrate SwiftyJSON into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "SwiftyJSON/SwiftyJSON"
```

### Manually

If you prefer not to use any of the aforementioned dependency managers, you can integrate SwiftyJSON into your project manually.

#### Embedded Framework

* Open up Terminal, `cd` into your top-level project directory, and run the following command "if" your project is not initialized as a git repository:
  ```bash
  $ git init
  ```
* Add SwiftyJSON as a git [submodule](https://git-scm.com/docs/git-submodule) by running the following command:
  ```bash
  $ git submodule add https://github.com/SwiftyJSON/SwiftyJSON.git
  ```
* Open the new `SwiftyJSON` folder, and drag the `SwiftyJSON.xcodeproj` into the Project Navigator of your application's Xcode project.
  > It should appear nested underneath your application's blue project icon. Whether it is above or below all the other Xcode groups does not matter.
* Select the `SwiftyJSON.xcodeproj` in the Project Navigator and verify the deployment target matches that of your application target.
* Next, select your application project in the Project Navigator (blue project icon) to navigate to the target configuration window and select the application target under the "TARGETS" heading in the sidebar.
* In the tab bar at the top of that window, open the "General" panel.
* Click on the `+` button under the "Embedded Binaries" section.
* You will see the `SwiftyJSON.framework` under the "Choose frameworks and libraries to add:" dialog.
  > The `SwiftyJSON.framework` is residing inside a folder named `Products`.
* Select the `SwiftyJSON.framework` and click the `Add` button.
* And that's it!

> The `SwiftyJSON.framework` is automagically added as a target dependency, linked framework and embedded framework in a copy files build phase which is all you need to build on the simulator and a device.

## Usage

### Initialization
```swift
import SwiftyJSON

let json = JSON(data: dataFromNetworking)
```

```swift
// SwiftyJSON 5.0
// Init with a Data object
if let dataFromString = jsonString.data(using: .utf8, allowLossyConversion: false) {
    let json = try JSON(data: dataFromString)
}

// Init with a string
let json = JSON(parseJSON: jsonString)

// Init with an object
let json: JSON = ["name": "Jack", "age": 25]
```

### Subscript

Subscript is the most important part of SwiftyJSON. It's really powerful and easy to use.

```swift
// Getting a double from a JSON Array
let name = json[0].doubleValue

// Getting a string from a JSON Dictionary
let name = json["name"].stringValue

// Getting a string using a path to the element
let name = json["list"][0]["name"].stringValue
```
The subscript returns a new `JSON` object, so you can chain your calls.

```swift
if let name = json["user"]["name"].string {
  // Do something with `name`
} else {
  // `name` is nil, you can subscript `json["user"]["name"]` with `null`
}
```

### Optional/Non-Optional Getters
`JSON` object has lots of getters for optional/non-optional types.

```swift
// Optional
if let name = json["name"].string {
  // Do something you want
} else {
  //print the error
  print(json["name"].error!)
}

// Non-optional
// If json["name"] is not a string or nil, you will get an empty string ""
let name = json["name"].stringValue
let id = json["id"].intValue
let number = json["number"].doubleValue
let flag = json["flag"].boolValue
let array = json["array"].arrayValue
let dictionary = json["dictionary"].dictionaryValue
```
For more getters check out the [source code](https://github.com/SwiftyJSON/SwiftyJSON/blob/master/Source/SwiftyJSON.swift).

### Setters
Sometimes you might need to change the `JSON`'s value, and you can do that with a setter.
```swift
var json: JSON = ["name": "Jack", "age": 25]
json["age"] = 26
json["name"] = "Mike"
```

### Raw object
SwiftyJSON can also give you a raw object.
```swift
if let string = json.rawString() {
  // Do something with string
}

if let data = json.rawData() {
  // Do something with data
}

var dic = json.dictionaryObject
var array = json.arrayObject
```

### Existence
You can check for the existence of a value.
```swift
if json["user"]["name"].exists() {
  // It exists
}
```

### Loop
You can loop through a `JSON` array or a dictionary.

```swift
// If json is .Array
for (index,subJson):(String, JSON) in json {
    //Do something you want
}

// If json is .Dictionary
for (key,subJson):(String, JSON) in json {
    //Do something you want
}
```

### Error
If you try to get a value where it doesn't exist, SwiftyJSON will return an `Error` object.
```swift
let json = JSON(["name":"Jack", "age": 25])
if let name = json["address"]["street"].string {
    // It will not be executed
} else {
    print(json["address"]["street"].error!) // "Dictionary["address"] does not exist"
}
```

### Literal Convertibles
```swift
var json: JSON = "I'm a json"
json = 12345
json = 123.45
json = true
json = [1,2,3]
json = ["1":1, "2":2, "3":3]
json = nil
```
> Note: `JSON` conforms to `ExpressibleBy*Literal` protocols, which means you can use literals to create a `JSON` object.

### Printable
```swift
let json: JSON =  ["name": "Jack", "age": 25]
print(json)

/*
 {
  "name" : "Jack",
  "age" : 25
 }
*/
```

### Merging
You can merge two `JSON` objects with `merge(with:)`.
```swift
var a: JSON = ["a": 1]
let b: JSON = ["b": 2]
try a.merge(with: b)
// a is now ["a": 1, "b": 2]
```

If a value in the given `JSON` object already exists in the current `JSON` object, it will be overwritten. You can prevent this with `merge(with:uniquingKeysWith:)`:
```swift
var a: JSON = ["a": 1, "c": 2]
let b: JSON = ["b": 3, "c": 4]
try a.merge(with: b, uniquingKeysWith: { $1 })
// a is now ["a": 1, "b": 3, "c": 4]
```

## Integration with other libraries
### Alamofire
```swift
import Alamofire
import SwiftyJSON

AF.request(url, method:.get).validate().responseJSON { response in
    switch response.result {
    case .success(let value):
        let json = JSON(value)
        print("JSON: \(json)")
    case .failure(let error):
        print(error)
    }
}
```

## License

SwiftyJSON is available under the MIT license. See the [LICENSE](https://github.com/SwiftyJSON/SwiftyJSON/blob/master/LICENSE) file for more info.
```
