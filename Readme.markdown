# DRTPFObjectDynamicProperties

[Parse](https://parse.com) framework provides `PFObject` as the base class for their BaSS solution. Unfortunately they don’t provide ready to use solution for subclassing their object, declaring some `@dynamic` properties and using the setters and getters instead of their *pseudo*-NSDictionary interface, as Core Data does under the hood. This leads to code that’s not easily read and in many cases to ugly SOP (String Oriented Programming).

This project aims to provide several facilities to make your live easier:

- Subclasses of PFObject can use `initWithAutoClassName` to use the class name as the `PFObject` `className`.
- Every property declared as `@dynamic` in your subclass implementation will be provided a standard getter and setter that uses the `PFObject` interface for you.
- Your subclasses will automatically get type checking by the compiler, auto-completion by the editor and a more readable syntax.

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

Create your subclass of `PFObject` and declare its properties as you will normally do. Custom setters and getters are respected. Also `readonly` properties.

``` objective-c
#import <Parse/Parse.h>

@interface MYDocument : PFObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong, readonly) NSNumber *countOfPages;
@property (nonatomic, strong, getter = isLandscape) NSNumber *landscape;

@end

```

In your implementation simply declare those properties as `@dynamic` and import `DRTPFObject+DynamicProperties.h`. If you want to use your own class name as the `PFObject` `className`, invoke `initWithAutoClassName` in your initializers.

``` objective-c
#import "MYDocument.h"
#import "DRTPFObject+DynamicProperties.h"

@implementation MYDocument

@dynamic title;
@dynamic countOfPages;
@dynamic landscape;

- (id)init
{
    return [self initWithAutoClassName];
}

@end
```

And finally use your object as you will normally do. You can mix `PFObject` and properties as you will.

``` objective-c
MYDocument *document = [MYDocument init];
document.title = @"My awesome document";
[document setObject:@42 forKey:@"countOfPages"];
document.landscape = @YES;
[document save];

NSLog("The document is titled %@, has %@ pages and landscape is %@", document.title, document.countOfPages, document.isLandscape);
```

You can also assign `nil` freely to those dynamic properties. It will get converted into `NSNull` and back for you without doing something else.

``` objective-c
MYDocument *document = [MYDocument init];
document.title = nil; // Stores NSNull into "title" key.
[document save];

NSLog("The document is titled %@", document.title);
// -> The document is titled (null)

NSLog("The document is really titled %@", [document objectForKey:@"title"]);
// -> The document is really titled <null>
```

## Requirements

DRTPFObjectDynamicProperties should work in any iOS version where Parse framework works, but have only been tested in iOS 5.0 and higher.

DRTPFObjectDynamicProperties uses ARC, so if you use it in a non-ARC project, and you are not using CocoaPods, you will need to use `-fobjc-arc` compiler flag on every DRTPFObjectDynamicProperties source file.

To set a compiler flag in Xcode, go to your desidered target and select the “Build Phases” tab. Select all DRTPFObjectDynamicProperties source files, press Enter, add `-fobjc-arc` and then “Done” to enable ARC for DRTPFObjectDynamicProperties.

## TODO

- Deal with subclasses of the consumer properly.
- Maybe try to make autoboxing/unboxing easier for the consumer.
- Avoid crashing with methods that are already there.

## Credits & Contact

DRTPFObjectDynamicProperties was created by [Daniel Rodríguez Troitiño](http://github.com/drodriguez). You can follow me on Twitter [@yonosoytu](http://twitter.com/yonosoytu).

## License

DRTPFObjectDynamicProperties is available under the MIT license. See LICENSE file for more info.
