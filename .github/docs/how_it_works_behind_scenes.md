# Vmob

Vmob was born from the idea of using an already written V module in the iOS app. Preferably you would write your module/library once and you could utilize its functions on both iOS and Android simultaneously.

## Core

Vmob core is fairly simple. It uses V written module, translates it to C code, then that C code is cross compiled to needed architecture.

### iOS
For iOS vmob can build static library that can be later used in iOS project trough provided header file (which can also be generated from vmob).

1. Translating V written module to C
2. Vmob uses **gcc** to build static library with given architecure (arm64/x86_64).
3. Vmob performs tests to ensure creation of static library was sucessful
Those tests include: ```lipo``` and ```otool``` checks. Tests are there to ensure integrity of generated build

When you are creating static libraries for iOS, one library for single architecture sometimes isn't enough. If you need to run your app on iOS Simulator you'll need to build for that target/architecture as well.

To combine both builds into one, vmob provides ```combine``` method. 
```combine``` wraps around already Apple built lipo tool and combines to libraries together.

### Graphic representation
![graphic-diagram](https://github.com/nedimf/vmob/blob/main/.github/docs/img/graphic-how-it-works.png)

### Android

```Vmob doesn't support android at the moment. ```


