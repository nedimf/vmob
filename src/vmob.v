/*
* Tool originally written by @nedimcodes (nedimf) 04/2021 
* Vmob is CLI tool that cross-compiles V module for use in iOS/Android trough C layer
* Read documentation to understand how this tool works
* MIT license 2021
*/
module main

import os
import term
import cli { Command, Flag }

const (
	ios_sdk_path           = '/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk' // universal path to iPhoneOS sdk
	ios_simulator_sdk_path = '/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iphonesimulator' // universal part to iphonesimulator sdk
)

fn main() {
	mut app := Command{
		name: 'vmob'
		description: 'Vmob is CLI tool that cross-compiles V module for use in iOS/Android architectures trough C layer.'
		version: 'v0.1'
	}
	mut cmd_apple_ios_iphone := Command{
		name: 'apple-ios-iphone'
		description: 'Build V module into arm64 static library'
		usage: '<module>'
		required_args: 1
		execute: apple_ios_iphone
	}
	cmd_apple_ios_iphone.add_flag(Flag{
		flag: .bool
		required: false
		name: 'skip-unused'
		abbrev: 's'
		description: 'V compiles to C as huge blob of 300kb+ to avoid this you can use skip-unused flag'
	})
	cmd_apple_ios_iphone.add_flag(Flag{
		flag: .bool
		required: false
		name: 'disable-bitcode'
		abbrev: 'db'
		description: 'Enabled bitcode is highly recommended to confirm to Apples LLVM compiler rules.\nWhen we enable bitcode in an iOS project, the package we submit to the App Store is compiled only until the bitcode stage. This allows Apple to compile the app in their servers, opening the doors for applying future optimizations to our code.\nIf you choose to disable it you will have to set Xcode setting flag (Build Settings -> Enable Bitcode to No)'
	})
	mut cmd_apple_ios_simulator := Command{
		name: 'apple-ios-simulator'
		description: 'Build V module into x86_64 static library'
		usage: '<module>'
		required_args: 1
		execute: apple_ios_simulator
	}
	cmd_apple_ios_simulator.add_flag(Flag{
		flag: .bool
		required: false
		name: 'skip-unused'
		abbrev: 's'
		description: 'V compiles to C as huge blob of 300kb+ to avoid this you can use skip-unused flag'
	})
	mut cmd_apple_lipo := Command{
		name: 'combine'
		description: 'Combine two architectures into one by making it universal'
		usage: '<module-arm64.a> <module-x86_64.a>'
		required_args: 2
		execute: apple_lipo
	}
	cmd_apple_lipo.add_flag(Flag{
		flag: .string
		required: true
		name: 'output'
		abbrev: 'o'
		description: 'Universal library name'
	})
	running := os.uname().sysname
	match running {
		'Darwin' {
			app.add_command(cmd_apple_ios_iphone)
			app.add_command(cmd_apple_ios_simulator)
			app.add_command(cmd_apple_lipo)
		}
		else {
			println(term.fail_message('At the moment vmob is only supported on MacOS with Xcode tools installed. This will change once Android support is implemented'))
		}
	}
	app.setup()
	app.parse(os.args)

	if !toolset_check() {
		exit(1)
	}
}

// apple_ios_iphone creates arm64 static library
fn apple_ios_iphone(cmd Command) ? {
	skip_unused := cmd.flags.get_bool('skip-unused') ?
	bitcode := cmd.flags.get_bool('disable-bitcode') ?
	module_name := cmd.args[0]
	mut out := os.Result{
		exit_code: 0
		output: ''
	}
	if !skip_unused {
		out = os.execute('v -o $module_name-arm64.c ${module_name}.v -shared vlib')
	} else {
		out = os.execute('v -o $module_name-arm64.c ${module_name}.v -shared vlib -skip-unused')
	}
	if !bitcode {
		out = os.execute('gcc -c $module_name-arm64.c -o $module_name-arm64.a -target arm64-apple-ios -isysroot $ios_sdk_path -fembed-bitcode')
	} else {
		out = os.execute('gcc -c $module_name-arm64.c -o $module_name-arm64.a -target arm64-apple-ios -isysroot $ios_sdk_path')
	}
	otool := otool_check(module_name, true)
	if out.output == '' && out.exit_code < 1 {
		println('iOS iPhone (arm64) static library crated.')
		out = os.execute('lipo -info $module_name-arm64.a')
		if out.exit_code < 1 {
			println('Lipo check passed ✅')
			if otool {
				println('Otool check passed ✅')
			} else {
				println('Otool check failed: ❌')
			}
		} else {
			println('Lipo check failed: ❌')
			println('Lipo check: \n$out.output')
		}
	} else {
		println('Error: $out.output')
	}
}

// apple_ios_simulator creates x86_64 static library
fn apple_ios_simulator(cmd Command) ? {
	skip_unused := cmd.flags.get_bool('skip-unused') ?
	module_name := cmd.args[0]
	mut out := os.Result{
		exit_code: 0
		output: ''
	}
	out = os.execute("xcodebuild -version -sdk iphoneos | grep SDKVersion | cut -f2 -d ':' | tr -d '[[:space:]]'")
	simulator_sdk := '$ios_simulator_sdk_path${out.output}.sdk'
	if !skip_unused {
		out = os.execute('v -o $module_name-x86_64.c ${module_name}.v -shared vlib')
	} else {
		out = os.execute('v -o $module_name-x86_64.c ${module_name}.v -shared vlib -skip-unused')
	}
	out = os.execute('gcc -c $module_name-x86_64.c -o $module_name-x86_64.a -target x86_64-apple-ios-simulator -isysroot $simulator_sdk')
	otool := otool_check(module_name, false)
	if out.exit_code < 1 {
		println('iOS iPhone Simulator(x86_64) static library crated.')
		out = os.execute('lipo -info $module_name-x86_64.a')
		if out.exit_code < 1 {
			println('Lipo check passed ✅')
			if otool {
				println('Otool check passed ✅')
			} else {
				println('Otool check failed: ❌')
			}
		} else {
			println('Lipo check failed: ❌')
			println('Lipo check: \n$out.output')
		}
	}
}

// apple_lipo creates universal static library by combining both arm64 and x86_64
fn apple_lipo(cmd Command) ? {
	output := cmd.flags.get_string('output') or { panic('Output flag is required') }
	module_arm64 := cmd.args[0]
	module_x86_64 := cmd.args[1]
	mut out := os.Result{
		exit_code: 0
		output: ''
	}
	out = os.execute('lipo -create $module_arm64 $module_x86_64 -output ${output}.a')
	println(out.output)

	if out.output == '' && out.exit_code < 1 {
		println('Universal static library successfully created')
		out = os.execute('lipo -info ${output}.a')
		if out.exit_code < 1 {
			println('Lipo check passed ✅')
		} else {
			println('Lipo check failed: ❌')
			println('Lipo check: \n$out.output')
		}
	}
}

// otool_check checks created static library to see if sdk is present in generated .a library
fn otool_check(module_name string, is_iphone bool) bool {
	mut out := os.Result{
		exit_code: 0
		output: ''
	}
	if is_iphone {
		out = os.execute('otool -lv $module_name-arm64.a | grep sdk')
		if out.exit_code < 1 {
			return true
		}
	} else {
		out = os.execute('otool -lv $module_name-x86_64.a | grep sdk')
		if out.exit_code < 1 {
			return true
		}
	}
	return false
}

// toolset_check checks for presents of needed tools, such as [gcc, otool, xcodebuild, xcode-select]
fn toolset_check() bool {
	tools_to_check := ['gcc --version', 'otool --version', 'xcodebuild -version',
		'xcode-select --version',
	]
	mut out := os.Result{
		exit_code: 0
		output: ''
	}
	for tool in tools_to_check {
		out = os.execute(tool)
		if out.exit_code > 0 {
			println('\n')
			println(term.fail_message('Required tool missing'))
			println('Missing tool: $tool')
			println('Error message: $out.output')
			return false
		} else {
			return true
		}
	}
}
