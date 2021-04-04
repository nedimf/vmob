# Vmob
Vmob is CLI tool that cross compiles V written module for use in iOS/Android architectures through C layer. <small>Android is still not supported, please refer to [support-android](https://github.com/nedimf/vmob/docs/support-android.md)</small>


## About 
Vmob is used to cross-compile originally written V modules(lib) into iOS-compatible .a files. Static library can be compiled with ```enabled-bitcode```, unlike Rust.

Please note that ```vmob``` is in a really early stage of development.

## How does it work?
Vmob is a pretty simple CLI app that works by translating the V module to raw C code. C file is then cross-compiled with ```gcc``` to supported architectures.

Supported architectures:
- iOS
  - iPhone arm64
  - iOS Simulator (x86_64)
- Android is **not supported yet, we are working to support it** see [support-android](https://github.com/nedimf/vmob/docs/support-android.md) to contribute
	- Android aarch64-linux-android
	- Android armv7-linux-androideabi
	- Android i686-linux-android
	- Android x86_64-linux-android

## Install 
### Requirments
- OS: MacOS (because it relies on lipo and otool checks)
- Tools: Installed Xcode
### Download binary
The easiest way is to just download binary
- ```curl ```

### Build vmob
You can build vmob from source using V.
- ``` git clone https://github.com/nedimf/vmob.git ```
- ```v vmob.v```
- Run: ```./vmob```

## How to use vmob?
- locate v written module

Build static library (.a) for arm64
- ```./vmob apple-ios-iphone -s true lib/module/module```

Build static library (.a) for x86_64 simulator 
- ```./vmob apple-ios-iphone -s true lib/module/module```
  
Combine two different architectures arm64 & x86_64
- ```./vmob combine -o module-ios lib/module/module-arm64.a lib/module/module-x86-64.a```

Xcode part: 

Insert **.a** file into your Xcode project, and don't forget to add a bridging header. Vmob can generate it for you. 

```./vmob hgen lib/module/module``` import made module into your Xcode project, configure bridge header file and call V module from your iOS app

For a full tutorial on how to use ```vmob``` look at [this]() sample project

## vmob
```
Usage: vmob [flags] [commands]
Vmob is CLI tool that cross-compiles V module for use in iOS/Android architectures through C layer.

Flags:
  -help                Prints help information.
  -version             Prints version information.

Commands:
  apple-ios-iphone     Build V module into arm64 static library
  apple-ios-simulator  Build V module into x86_64 static library
  combine              Combine two architectures into one by making it universal
  help                 Prints help information.
  version              Prints version information.
```


