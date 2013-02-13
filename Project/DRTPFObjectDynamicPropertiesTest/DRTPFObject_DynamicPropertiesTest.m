//
//  DRTPFObject_DynamicPropertiesTest.m
//  DRTPFObjectDynamicPropertiesTest
//
//  Created by Daniel Rodríguez Troitiño on 09/02/13.
//  Copyright (c) 2013 Daniel Rodr√≠guez Troiti√±o. All rights reserved.
//

#import "GHTestCase.h"

#import <Parse/Parse.h>
#import "DRTPFObject+DynamicProperties.h"

@interface DRTMyPFObjectSubclass : PFObject

@property (atomic, strong) NSDictionary *atomicStrongDictionary;
@property (nonatomic, strong) NSNumber *nonatomicStrongNumber;
@property (atomic, copy) NSString *atomicCopiedString;
@property (nonatomic, copy) NSArray *nonatomicCopiedArray;

@property (nonatomic, strong, setter = setSetter:) NSNumber *onlySetterNumber;
@property (nonatomic, strong, getter = isGetter) NSNumber *onlyGetterNumber;
@property (nonatomic, strong, getter = isGetterBoth, setter = setSetterBoth:) NSNumber *bothGetterAndSetterNumber;

@property (nonatomic, strong, readonly) NSString *readOnlyString;

@property (nonatomic, assign) char charProperty;
@property (nonatomic, assign) unsigned char unsignedCharProperty;
@property (nonatomic, assign) short shortProperty;
@property (nonatomic, assign) unsigned short unsignedShortProperty;
@property (nonatomic, assign) int intProperty;
@property (nonatomic, assign) unsigned int unsignedIntProperty;
@property (nonatomic, assign) long longProperty;
@property (nonatomic, assign) unsigned long unsignedLongProperty;
@property (nonatomic, assign) long long longLongProperty;
@property (nonatomic, assign) unsigned long long unsignedLongLongProperty;
@property (nonatomic, assign) float floatProperty;
@property (nonatomic, assign) double doubleProperty;

@property (nonatomic, strong) NSString *transientStrongString;
@property (nonatomic, assign) NSUInteger transientAssignUInteger;

- (id)init;

@end


@interface DRTPFObject_DynamicPropertiesTest : GHTestCase

@end

@implementation DRTPFObject_DynamicPropertiesTest
{
    DRTMyPFObjectSubclass *_myObject;
}

- (void)setUp
{
    _myObject = [[DRTMyPFObjectSubclass alloc] init];
}

- (void)testAtomicStrongDictionaryIsSameObject
{
    NSDictionary *expectedDictionary = @{@"key1": @"value1", @"key2": @"value2"};
    _myObject.atomicStrongDictionary = expectedDictionary;

    GHAssertEquals(expectedDictionary, _myObject.atomicStrongDictionary, nil);
}

- (void)testAtomicStrongDictionaryStoresItsValueIntoPFObject
{
  NSDictionary *expectedDictionary = @{@"key1": @"value1", @"key2": @"value2"};
  _myObject.atomicStrongDictionary = expectedDictionary;

  GHAssertEquals(expectedDictionary, [_myObject objectForKey:@"atomicStrongDictionary"], nil);
}

- (void)testAtomicStrongDictionaryRetrievesItsValueFromPFObject
{
  NSDictionary *expectedDictionary = @{@"key1": @"value1", @"key2": @"value2"};
  [_myObject setObject:expectedDictionary forKey:@"atomicStrongDictionary"];

  GHAssertEquals(expectedDictionary, _myObject.atomicStrongDictionary, nil);
}

- (void)testAtomicStrongDictionaryStoresNSNullInsteadOfNil
{
  _myObject.atomicStrongDictionary = nil;

  GHAssertEquals([NSNull null], [_myObject objectForKey:@"atomicStrongDictionary"], nil);
}

- (void)testAtomicStrongDictionaryRetrievesNilInsteadOfNSNull
{
  [_myObject setObject:[NSNull null] forKey:@"atomicStrongDictionary"];

  GHAssertNil(_myObject.atomicStrongDictionary, nil);
}

- (void)testNonAtomicStrongNumberIsSameObject
{
  NSNumber *expectedNumber = @123.456;
  _myObject.nonatomicStrongNumber = expectedNumber;

  GHAssertEquals(expectedNumber, _myObject.nonatomicStrongNumber, nil);
}

- (void)testNonAtomicStrongNumberStoresItsValueIntoPFObject
{
  NSNumber *expectedNumber = @123.456;
  _myObject.nonatomicStrongNumber = expectedNumber;

  GHAssertEquals(expectedNumber, [_myObject objectForKey:@"nonatomicStrongNumber"], nil);
}

- (void)testNonAtomicStrongNumberRetrievesItsValueFromPFObject
{
  NSNumber *expectedNumber = @123.456;
  [_myObject setObject:expectedNumber forKey:@"nonatomicStrongNumber"];

  GHAssertEquals(expectedNumber, _myObject.nonatomicStrongNumber, nil);
}

- (void)testNonAtomicStrongNumberStoresNSNullInsteadOfNil
{
  _myObject.nonatomicStrongNumber = nil;

  GHAssertEquals([NSNull null], [_myObject objectForKey:@"nonatomicStrongNumber"], nil);
}

- (void)testNonAtomicStrongNumberRetrievesNilInsteadOfNSNull
{
  [_myObject setObject:[NSNull null] forKey:@"nonatomicStrongNumber"];

  GHAssertNil(_myObject.nonatomicStrongNumber, nil);
}

- (void)testAtomicCopiedStringIsNotSameObject
{
  NSMutableString *theString = [NSMutableString stringWithString:@"the string"];
  _myObject.atomicCopiedString = theString;

  GHAssertNotEquals(theString, _myObject.atomicCopiedString, nil);
  GHAssertEqualStrings(theString, _myObject.atomicCopiedString, nil);
}

- (void)testAtomicCopiedStringStoresItsValueIntoPFObject
{
  NSMutableString *theString = [NSMutableString stringWithString:@"the string"];
  _myObject.atomicCopiedString = theString;

  GHAssertEqualStrings(theString, [_myObject objectForKey:@"atomicCopiedString"], nil);
}

- (void)testAtomicCopiedStringRetrievesItsValueFromPFObject
{
  NSMutableString *theString = [NSMutableString stringWithString:@"the string"];
  [_myObject setObject:theString forKey:@"atomicCopiedString"];

  GHAssertEqualStrings(theString, _myObject.atomicCopiedString, nil);
}

- (void)testAtomicCopiedStringStoresNSNullInsteadOfNil
{
  _myObject.atomicCopiedString = nil;

  GHAssertEquals([NSNull null], [_myObject objectForKey:@"atomicCopiedString"], nil);
}

- (void)testAtomicCopiedStringRetrievesNilInsteadOfNSNull
{
  [_myObject setObject:[NSNull null] forKey:@"atomicCopiedString"];

  GHAssertNil(_myObject.atomicCopiedString, nil);
}

- (void)testNonAtomicCopiedArrayIsNotSameObject
{
  NSMutableArray *theArray = [NSMutableArray arrayWithArray:@[@"elem1", @"elem2"]];
  _myObject.nonatomicCopiedArray = theArray;

  GHAssertNotEquals(theArray, _myObject.nonatomicCopiedArray, nil);
  GHAssertEqualObjects(theArray, _myObject.nonatomicCopiedArray, nil);
}

- (void)testNonAtomicCopiedArrayStoresItsValueIntoPFObject
{
  NSMutableArray *theArray = [NSMutableArray arrayWithArray:@[@"elem1", @"elem2"]];
  _myObject.nonatomicCopiedArray = theArray;

  GHAssertEqualObjects(theArray, [_myObject objectForKey:@"nonatomicCopiedArray"], nil);
}

- (void)testNonAtomicCopiedArrayRetrievesItsValueFromPFObject
{
  NSMutableArray *theArray = [NSMutableArray arrayWithArray:@[@"elem1", @"elem2"]];
  [_myObject setObject:theArray forKey:@"nonatomicCopiedArray"];

  GHAssertEqualObjects(theArray, _myObject.nonatomicCopiedArray, nil);
}

- (void)testNonAtomicCopiedArrayStoresNSNullInsteadOfNil
{
  _myObject.nonatomicCopiedArray = nil;

  GHAssertEquals([NSNull null], [_myObject objectForKey:@"nonatomicCopiedArray"], nil);
}

- (void)testNonAtomicCopiedArrayRetrievesNilInsteadOfNSNull
{
  [_myObject setObject:[NSNull null] forKey:@"nonatomicCopiedArray"];

  GHAssertNil(_myObject.nonatomicCopiedArray, nil);
}

- (void)testOnlySetterNumberShouldBeSetFromCustomSetter
{
  NSNumber *number = @123;
  [_myObject setSetter:number];

  GHAssertEqualObjects(number, [_myObject objectForKey:@"onlySetterNumber"], nil);
}

- (void)testOnlySetterNumberShouldProvideStandardGetter
{
  NSNumber *number = @123;
  [_myObject setSetter:number];

  GHAssertEqualObjects(number, [_myObject objectForKey:@"onlySetterNumber"], nil);
}

- (void)testOnlyGetterNumberShouldBeAccessFromCustomSetter
{
  NSNumber *number = @123;
  [_myObject setObject:number forKey:@"onlyGetterNumber"];

  GHAssertEqualObjects(number, _myObject.isGetter, nil);
}

- (void)testOnlyGetterNumberShouldProvideStandardSetter
{
  NSNumber *number = @123;
  _myObject.onlyGetterNumber = number;

  GHAssertEqualObjects(number, [_myObject objectForKey:@"onlyGetterNumber"], nil);
}

- (void)testBothGetterAndSetterNumberShouldBeAccessFromCustomSetter
{
  NSNumber *number = @123;
  [_myObject setObject:number forKey:@"bothGetterAndSetterNumber"];

  GHAssertEqualObjects(number, _myObject.isGetterBoth, nil);
}

- (void)testBothGetterAndSetterNumberShouldBeSetFromCustomSetter
{
  NSNumber *number = @123;
  [_myObject setSetterBoth:number];

  GHAssertEqualObjects(number, [_myObject objectForKey:@"bothGetterAndSetterNumber"], nil);
}

- (void)testReadOnlyStringAllowsUsingItsGetter
{
  NSString *theString = @"the string";
  [_myObject setObject:theString forKey:@"readOnlyString"];

  GHAssertEqualStrings(theString, _myObject.readOnlyString, nil);
}

- (void)testReadOnlyStringDisallowsUsingItsSetter
{
  GHAssertFalse([_myObject respondsToSelector:@selector(setReadOnlyString:)], nil);
}

- (void)testTransientStrongStringDoesNotStoreItsValueIntoPFObject
{
  NSString *theString = @"the string";
  _myObject.transientStrongString = theString;

  GHAssertNil([_myObject objectForKey:@"transientStrongString"], nil);
}

- (void)testTransientStrongStringDoesNotretrieveItsValueFromPFObject
{
  NSString *theString = @"the string";
  [_myObject setObject:theString forKey:@"transientStrongString"];

  GHAssertNil(_myObject.transientStrongString, nil);
}

- (void)testTransientAssignUIntegerDoesNotStoreItsValueIntoPFObject
{
  NSUInteger theInteger = 123u;
  _myObject.transientAssignUInteger = theInteger;

  GHAssertNil([_myObject objectForKey:@"transientAssignUInteger"], nil);
}

- (void)testTransientAssignUIntegerDoesNotretrieveItsValueFromPFObject
{
  NSUInteger theInteger = 123u;
  // Since PFObject only support objects, we have to box our number
  [_myObject setObject:@(theInteger) forKey:@"transientAssignUInteger"];

  GHAssertEquals(0u, _myObject.transientAssignUInteger, nil);
}

- (void)testCharPropertyInitsToZero
{
  GHAssertEquals((char)'\0', _myObject.charProperty, nil);
}

- (void)testCharPropertyShouldStoreItsValueIntoPFObject
{
  _myObject.charProperty = (char)'D';

  GHAssertEqualObjects(@'D', [_myObject objectForKey:@"charProperty"], nil);
}

- (void)testCharPropertyShouldRetrieveItsValueFromPFObject
{
  [_myObject setObject:@'D' forKey:@"charProperty"];

  GHAssertEquals((char)'D', _myObject.charProperty, nil);
}

- (void)testUnsignedCharPropertyInitsToZero
{
  GHAssertEquals((unsigned char)'\0', _myObject.unsignedCharProperty, nil);
}

- (void)testUnsignedCharPropertyShouldStoreItsValueIntoPFObject
{
  _myObject.unsignedCharProperty = (unsigned char)192;

  GHAssertEqualObjects([NSNumber numberWithUnsignedChar:192], [_myObject objectForKey:@"unsignedCharProperty"], nil);
}

- (void)testUnsignedCharPropertyShouldRetrieveItsValueFromPFObject
{
  [_myObject setObject:[NSNumber numberWithUnsignedChar:192] forKey:@"unsignedCharProperty"];

  GHAssertEquals((unsigned char)192, _myObject.unsignedCharProperty, nil);
}

- (void)testShortPropertyInitsToZero
{
  GHAssertEquals((short)0, _myObject.shortProperty, nil);
}

- (void)testShortPropertyShouldStoreItsValueIntoPFObject
{
  _myObject.shortProperty = (short)512;

  GHAssertEqualObjects([NSNumber numberWithShort:512], [_myObject objectForKey:@"shortProperty"], nil);
}

- (void)testShortPropertyShouldRetrieveItsValueFromPFObject
{
  [_myObject setObject:[NSNumber numberWithShort:512] forKey:@"shortProperty"];

  GHAssertEquals((short)512, _myObject.shortProperty, nil);
}

- (void)testUnsignedShortPropertyInitsToZero
{
  GHAssertEquals((unsigned short)0, _myObject.unsignedShortProperty, nil);
}

- (void)testUnsignedShortPropertyShouldStoreItsValueIntoPFObject
{
  _myObject.unsignedShortProperty = (unsigned short)40000;

  GHAssertEqualObjects([NSNumber numberWithUnsignedShort:40000], [_myObject objectForKey:@"unsignedShortProperty"], nil);
}

- (void)testUnsignedShortPropertyShouldRetrieveItsValueFromPFObject
{
  [_myObject setObject:[NSNumber numberWithUnsignedShort:40000] forKey:@"unsignedShortProperty"];

  GHAssertEquals((unsigned short)40000, _myObject.unsignedShortProperty, nil);
}

- (void)testIntPropertyInitsToZero
{
  GHAssertEquals(0, _myObject.intProperty, nil);
}

- (void)testIntPropertyShouldStoreItsValueIntoPFObject
{
  _myObject.intProperty = 70000;

  GHAssertEqualObjects(@70000, [_myObject objectForKey:@"intProperty"], nil);
}

- (void)testIntPropertyShouldRetrieveItsValueFromPFObject
{
  [_myObject setObject:@70000 forKey:@"intProperty"];

  GHAssertEquals(70000, _myObject.intProperty, nil);
}

- (void)testUnsignedIntPropertyInitsToZero
{
  GHAssertEquals(0u, _myObject.unsignedIntProperty, nil);
}

- (void)testUnsignedIntPropertyShouldStoreItsValueIntoPFObject
{
  _myObject.unsignedIntProperty = INT_MAX + 1u;

  GHAssertEqualObjects(@(INT_MAX + 1u), [_myObject objectForKey:@"unsignedIntProperty"], nil);
}

- (void)testUnsignedIntPropertyShouldRetrieveItsValueFromPFObject
{
  [_myObject setObject:@(INT_MAX + 1u) forKey:@"unsignedIntProperty"];

  GHAssertEquals(INT_MAX + 1u, _myObject.unsignedIntProperty, nil);
}

- (void)testLongPropertyInitsToZero
{
  GHAssertEquals(0l, _myObject.longProperty, nil);
}

- (void)testLongPropertyShouldStoreItsValueIntoPFObject
{
  _myObject.longProperty = 70000l;

  GHAssertEqualObjects(@70000l, [_myObject objectForKey:@"longProperty"], nil);
}

- (void)testLongPropertyShouldRetrieveItsValueFromPFObject
{
  [_myObject setObject:@70000l forKey:@"longProperty"];

  GHAssertEquals(70000l, _myObject.longProperty, nil);
}

- (void)testUnsignedLongPropertyInitsToZero
{
  GHAssertEquals(0ul, _myObject.unsignedLongProperty, nil);
}

- (void)testUnsignedLongPropertyShouldStoreItsValueIntoPFObject
{
  _myObject.unsignedLongProperty = LONG_MAX + 1u;

  GHAssertEqualObjects(@(LONG_MAX + 1lu), [_myObject objectForKey:@"unsignedLongProperty"], nil);
}

- (void)testUnsignedLongPropertyShouldRetrieveItsValueFromPFObject
{
  [_myObject setObject:@(LONG_MAX + 1lu) forKey:@"unsignedLongProperty"];

  GHAssertEquals(LONG_MAX + 1lu, _myObject.unsignedLongProperty, nil);
}

- (void)testLongLongPropertyInitsToZero
{
  GHAssertEquals(0ll, _myObject.longLongProperty, nil);
}

- (void)testLongLongPropertyShouldStoreItsValueIntoPFObject
{
  _myObject.longLongProperty = 70000ll;

  GHAssertEqualObjects(@70000ll, [_myObject objectForKey:@"longLongProperty"], nil);
}

- (void)testLongLongPropertyShouldRetrieveItsValueFromPFObject
{
  [_myObject setObject:@70000ll forKey:@"longLongProperty"];

  GHAssertEquals(70000ll, _myObject.longLongProperty, nil);
}

- (void)testUnsignedLongLongPropertyInitsToZero
{
  GHAssertEquals(0ull, _myObject.unsignedLongLongProperty, nil);
}

- (void)testUnsignedLongLongPropertyShouldStoreItsValueIntoPFObject
{
  _myObject.unsignedLongLongProperty = LONG_LONG_MAX + 1ull;

  GHAssertEqualObjects(@(LONG_LONG_MAX + 1llu), [_myObject objectForKey:@"unsignedLongLongProperty"], nil);
}

- (void)testUnsignedLongLongPropertyShouldRetrieveItsValueFromPFObject
{
  [_myObject setObject:@(LONG_LONG_MAX + 1llu) forKey:@"unsignedLongLongProperty"];

  GHAssertEquals(LONG_LONG_MAX + 1llu, _myObject.unsignedLongLongProperty, nil);
}

- (void)testFloatPropertyInitsToZero
{
  GHAssertEquals(0.0f, _myObject.floatProperty, nil);
}

- (void)testFloatPropertyShouldStoreItsValueIntoPFObject
{
  _myObject.floatProperty = 123.456f;

  GHAssertEqualObjects(@123.456f, [_myObject objectForKey:@"floatProperty"], nil);
}

- (void)testFloatPropertyShouldRetrieveItsValueFromPFObject
{
  [_myObject setObject:@123.456f forKey:@"floatProperty"];

  GHAssertEqualsWithAccuracy(123.456f, _myObject.floatProperty, 0.1f, nil);
}

- (void)testDoublePropertyInitsToZero
{
  GHAssertEquals(0.0, _myObject.doubleProperty, nil);
}

- (void)testDoublePropertyShouldStoreItsValueIntoPFObject
{
  _myObject.doubleProperty = 123.456;

  GHAssertEqualObjects(@123.456, [_myObject objectForKey:@"doubleProperty"], nil);
}

- (void)testDoublePropertyShouldRetrieveItsValueFromPFObject
{
  [_myObject setObject:@123.456 forKey:@"doubleProperty"];

  GHAssertEqualsWithAccuracy(123.456, _myObject.doubleProperty, 0.1, nil);
}

@end


@implementation DRTMyPFObjectSubclass

@dynamic atomicStrongDictionary;
@dynamic nonatomicStrongNumber;
@dynamic atomicCopiedString;
@dynamic nonatomicCopiedArray;
@dynamic onlyGetterNumber;
@dynamic onlySetterNumber;
@dynamic bothGetterAndSetterNumber;
@dynamic readOnlyString;
@dynamic charProperty;
@dynamic unsignedCharProperty;
@dynamic shortProperty;
@dynamic unsignedShortProperty;
@dynamic intProperty;
@dynamic unsignedIntProperty;
@dynamic longProperty;
@dynamic unsignedLongProperty;
@dynamic longLongProperty;
@dynamic unsignedLongLongProperty;
@dynamic floatProperty;
@dynamic doubleProperty;

- (id)init
{
    return [self initWithAutoClassName];
}

@end