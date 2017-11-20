# Convert

[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg)](https://github.com/Carthage/Carthage)
[![Swift 3.1](https://img.shields.io/badge/Swift-3.1-orange.svg)](https://developer.apple.com/swift/)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%20|%20macOS%20|%20tvOS%20|%20watchOS-lightgray.svg)](http://www.apple.com/ios/)
[![License MIT](https://img.shields.io/badge/License-MIT-lightgray.svg)](https://opensource.org/licenses/MIT)

A lightweight library for converting between units.

## Usage

``` swift
let inch = 1.inch

let converted = inch.to(.millimeter) // 25.4
```

## Installation

#### <img src="https://cloud.githubusercontent.com/assets/432536/5252404/443d64f4-7952-11e4-9d26-fc5cc664cb61.png" width="24" height="24"> [Carthage]

[Carthage]: https://github.com/Carthage/Carthage

To install it, simply add the following line to your **Cartfile**:

```ruby
github "danielbyon/Convert"
```

Then run `carthage update`.

Follow the current instructions in [Carthage's README][carthage-installation]
for up to date installation instructions.

[carthage-installation]: https://github.com/Carthage/Carthage#adding-frameworks-to-an-application

#### Manually

Download all the source files and drop them into your project.

## Requirements

* iOS 8.0+
* macOS 10.10+
* tvOS 9.0+
* watchOS 2.0+
* Xcode 8 (Swift 3.1)

## License

This project is licensed under the MIT License.
