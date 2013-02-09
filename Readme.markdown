# DRTPFObjectDynamicProperties

TODO

## How to use

### Installing

#### Using CocoaPods

1. Include the following line in your `Podfile`:
   ```
   pod 'DRTPFObjectDynamicProperties', :git => 'https://github.com/drodriguez/DRTPFObjectDynamicProperties'
   ```
2. Run `pod install`

#### Manually

1. Clone, add as a submodule or [download](https://github.com/drodriguez/DRTPFObjectDynamicProperties/zipball/master) DRTPFObjectDynamicProperties.
2. Add all the files under `Classes/common` to your project.
3. Look at the Requirements section if you are not using ARC.

### Using

TODO

## Requirements

DRTPFObjectDynamicProperties should work in any iOS version where Parse framework works, but have only been tested in iOS 5.0 and higher.

DRTPFObjectDynamicProperties uses ARC, so if you use it in a non-ARC project, and you are not using CocoaPods, you will need to use `-fobjc-arc` compiler flag on every DRTPFObjectDynamicProperties source file.

To set a compiler flag in Xcode, go to your desidered target and select the “Build Phases” tab. Select all DRTPFObjectDynamicProperties source files, press Enter, add `-fobjc-arc` and then “Done” to enable ARC for DRTPFObjectDynamicProperties.

## TODO

- Generate the getter and the setter names according to the property attributes (the name mangling will become much more complicated).
- Don't generate the setter if the property is read only (but who wants a PFObject property which is read only?).
- Deal with subclasses of the consumer properly.
- Maybe try to make autoboxing/unboxing easier for the consumer.

## Credits & Contact

DRTPFObjectDynamicProperties was created by [Daniel Rodríguez Troitiño](http://github.com/drodriguez). You can follow me on Twitter [@yonosoytu](http://twitter.com/yonosoytu).

## License

DRTPFObjectDynamicProperties is available under the MIT license. See LICENSE file for more info.
