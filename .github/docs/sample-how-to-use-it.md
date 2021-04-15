#How to use vmob

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
