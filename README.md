# Vmob

Vmob is CLI tool that cross compiles V written module for use in iOS/Android architectures through C layer. 
Android is still not supported, please refer to [support-android](https://github.com/nedimf/vmob/blob/main/.github/docs/android-support.md)


## About 
Vmob is used to cross-compile originally written V modules(lib) into iOS-compatible .a files. Static library can be compiled with ```enabled-bitcode```, unlike [Rust](https://github.com/rust-lang/rust/issues/35968). For full explonation how vmob works read this [document](https://github.com/nedimf/vmob/blob/main/.github/docs/how_it_works_behind_scenes.md).

Please note that ```vmob``` is in a really early stage of development.

## How does it work?
Vmob is a pretty simple CLI app that works by translating the V module to raw C code. C file is then cross-compiled with ```gcc``` to supported architectures.

Supported architectures:
- iOS
  - iPhone arm64
  - iOS Simulator (x86_64)  
- Android 
	- Android aarch64-linux-android
	- Android armv7-linux-androideabi
	- Android i686-linux-android
	- Android x86_64-linux-android

>Android is **not supported yet, we are working to support it** see [support-android](https://github.com/nedimf/vmob/blob/main/.github/docs/android-support.md) to contribute

## Install 
### Requirments
- OS: MacOS (because it relies on lipo and otool checks)
- Tools: Installed Xcode
### Download binary
The easiest way is to just download binary
- [binary](https://github.com/nedimf/vmob/blob/main/vmob?raw=true)

### Build vmob
You can build vmob from source using V.
- ``` git clone https://github.com/nedimf/vmob.git ```
- ```v vmob.v```
- Run: ```./vmob```

## How to use vmob?

<details><summary><b>Step by step guide</b></summary>
<p>

## iOS
1. Write your V module
> Be sure to use [export: ] followed by module name
```v
module vex
import math 

[export: vex_absolute_value]
pub fn vex_absolute_value(a f64) f64{
	return math.abs(a)
}

fn init(){
	println("Vex module has been called")
}

```
2. Build static library (.a file) targeting iPhone (arm64) 
   ```./vmob apple-ios-iphone -s false path/to/module```
3. Build static library (.a file) targeting iOS Simulator (x86_64)
   ```./vmob apple-ios-simulator -s false path/to/module```
4. Combine two targets into universal target
   ```./vmob combine -o modulename-ios path/to/module-arm64.a path/to/module-x86_64.a```
5. Generate header file that you will use as bridge between your library and Xcode
    ```./vmob header-gen -a arm64 -mp vex path/to/module```

### Xcode: 

6. Open Xcode 
7. Create new folder called ```your-ios-module-name```
8. Drag and drop your universal ```modulename-ios.a``` and ```.h``` file 
9. New File -> C -> Enable Bridging Header
    - add line ```#include "modulename_header.h``` file
10. Call method from your Swift code

```swift
     override func viewDidLoad() {
        super.viewDidLoad()
        println(vex_absolute_value(-1)) // 1
    }
```

Have in mind this all this be automated in Xcode build script

## Android

```Not yet supported```
<hr>
</p>
</details>
<br>
Fast version:

- locate v written module

Build static library (.a) for arm64
- ```./vmob apple-ios-iphone -s false lib/module/module```

Build static library (.a) for x86_64 simulator 
- ```./vmob apple-ios-iphone -s false lib/module/module```
  
Combine two different architectures ```arm64``` & ```x86_64```
- ```./vmob combine -o module-ios lib/module/module-arm64.a lib/module/module-x86-64.a```

#### Implementation with Xcode
Xcode part: 

Insert **.a** file into your Xcode project, and don't forget to add a bridging header. Vmob can generate it for you. 

```./vmob header-gen -a arm64 lib/module/module``` import made module into your Xcode project, configure bridge header file and call V module from your iOS app

For a full tutorial on how to use ```vmob``` look at [this](https://github.com/nedimf/vmob/blob/main/.github/docs/sample-how-to-use-it.md) sample project or click down on drop down menu.


## vmob
```
Usage: vmob [flags] [commands]
Vmob is CLI tool that cross-compiles V module for use in iOS/Android architectures through C layer.

Flags:
  -help                Prints help information.
  -version             Prints version information.

Commands:
  apple-ios-iphone     Build V module into arm64 static librvary
  apple-ios-simulator  Build V module into x86_64 static library
  combine              Combine two architectures into one by making it universal
  header-gen           Generate header.h to be inserted in Xcode project
  help                 Prints help information.
  version              Prints version information.
```

## Author
- [@nedimf](https://twitter.com/nedimcodes)
If you would like to support my work:
<br>
  <a href="https://www.buymeacoffee.com/nedimcodes" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>
