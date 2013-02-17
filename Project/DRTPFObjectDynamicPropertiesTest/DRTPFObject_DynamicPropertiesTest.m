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


@interface DRTMyPFObjectSubclassWithCustomGetter : PFObject

@property (nonatomic, strong) NSString *stringWithDefault;

- (id)init;

@end


@interface DRTMyPFObjectParent : PFObject

@property (nonatomic, strong) NSString *stringInParent;

- (id)init;

@end


@interface DRTMyPFObjectChild : DRTMyPFObjectParent

@property (nonatomic, strong) NSString *stringInChild;

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

    GHAssertEquals(_myObject.atomicStrongDictionary, expectedDictionary, nil);
}

- (void)testAtomicStrongDictionaryStoresItsValueIntoPFObject
{
  NSDictionary *expectedDictionary = @{@"key1": @"value1", @"key2": @"value2"};
  _myObject.atomicStrongDictionary = expectedDictionary;

  GHAssertEquals([_myObject objectForKey:@"atomicStrongDictionary"], expectedDictionary, nil);
}

- (void)testAtomicStrongDictionaryRetrievesItsValueFromPFObject
{
  NSDictionary *expectedDictionary = @{@"key1": @"value1", @"key2": @"value2"};
  [_myObject setObject:expectedDictionary forKey:@"atomicStrongDictionary"];

  GHAssertEquals(_myObject.atomicStrongDictionary, expectedDictionary, nil);
}

- (void)testAtomicStrongDictionaryStoresNSNullInsteadOfNil
{
  _myObject.atomicStrongDictionary = nil;

  GHAssertEquals([_myObject objectForKey:@"atomicStrongDictionary"], [NSNull null], nil);
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

  GHAssertEquals(_myObject.nonatomicStrongNumber, expectedNumber, nil);
}

- (void)testNonAtomicStrongNumberStoresItsValueIntoPFObject
{
  NSNumber *expectedNumber = @123.456;
  _myObject.nonatomicStrongNumber = expectedNumber;

  GHAssertEquals([_myObject objectForKey:@"nonatomicStrongNumber"], expectedNumber, nil);
}

- (void)testNonAtomicStrongNumberRetrievesItsValueFromPFObject
{
  NSNumber *expectedNumber = @123.456;
  [_myObject setObject:expectedNumber forKey:@"nonatomicStrongNumber"];

  GHAssertEquals(_myObject.nonatomicStrongNumber, expectedNumber, nil);
}

- (void)testNonAtomicStrongNumberStoresNSNullInsteadOfNil
{
  _myObject.nonatomicStrongNumber = nil;

  GHAssertEquals([_myObject objectForKey:@"nonatomicStrongNumber"], [NSNull null], nil);
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

  GHAssertNotEquals(_myObject.atomicCopiedString, theString, nil);
  GHAssertEqualStrings(_myObject.atomicCopiedString, theString, nil);
}

- (void)testAtomicCopiedStringStoresItsValueIntoPFObject
{
  NSMutableString *theString = [NSMutableString stringWithString:@"the string"];
  _myObject.atomicCopiedString = theString;

  GHAssertEqualStrings([_myObject objectForKey:@"atomicCopiedString"], theString, nil);
}

- (void)testAtomicCopiedStringRetrievesItsValueFromPFObject
{
  NSMutableString *theString = [NSMutableString stringWithString:@"the string"];
  [_myObject setObject:theString forKey:@"atomicCopiedString"];

  GHAssertEqualStrings(_myObject.atomicCopiedString, theString, nil);
}

- (void)testAtomicCopiedStringStoresNSNullInsteadOfNil
{
  _myObject.atomicCopiedString = nil;

  GHAssertEquals([_myObject objectForKey:@"atomicCopiedString"], [NSNull null], nil);
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

  GHAssertNotEquals(_myObject.nonatomicCopiedArray, theArray, nil);
  GHAssertEqualObjects(_myObject.nonatomicCopiedArray, theArray, nil);
}

- (void)testNonAtomicCopiedArrayStoresItsValueIntoPFObject
{
  NSMutableArray *theArray = [NSMutableArray arrayWithArray:@[@"elem1", @"elem2"]];
  _myObject.nonatomicCopiedArray = theArray;

  GHAssertEqualObjects([_myObject objectForKey:@"nonatomicCopiedArray"], theArray, nil);
}

- (void)testNonAtomicCopiedArrayRetrievesItsValueFromPFObject
{
  NSMutableArray *theArray = [NSMutableArray arrayWithArray:@[@"elem1", @"elem2"]];
  [_myObject setObject:theArray forKey:@"nonatomicCopiedArray"];

  GHAssertEqualObjects(_myObject.nonatomicCopiedArray, theArray, nil);
}

- (void)testNonAtomicCopiedArrayStoresNSNullInsteadOfNil
{
  _myObject.nonatomicCopiedArray = nil;

  GHAssertEquals([_myObject objectForKey:@"nonatomicCopiedArray"], [NSNull null], nil);
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

  GHAssertEqualObjects([_myObject objectForKey:@"onlySetterNumber"], number, nil);
}

- (void)testOnlySetterNumberShouldProvideStandardGetter
{
  NSNumber *number = @123;
  [_myObject setSetter:number];

  GHAssertEqualObjects([_myObject objectForKey:@"onlySetterNumber"], number, nil);
}

- (void)testOnlyGetterNumberShouldBeAccessFromCustomSetter
{
  NSNumber *number = @123;
  [_myObject setObject:number forKey:@"onlyGetterNumber"];

  GHAssertEqualObjects(_myObject.isGetter, number, nil);
}

- (void)testOnlyGetterNumberShouldProvideStandardSetter
{
  NSNumber *number = @123;
  _myObject.onlyGetterNumber = number;

  GHAssertEqualObjects([_myObject objectForKey:@"onlyGetterNumber"], number, nil);
}

- (void)testBothGetterAndSetterNumberShouldBeAccessFromCustomSetter
{
  NSNumber *number = @123;
  [_myObject setObject:number forKey:@"bothGetterAndSetterNumber"];

  GHAssertEqualObjects(_myObject.isGetterBoth, number, nil);
}

- (void)testBothGetterAndSetterNumberShouldBeSetFromCustomSetter
{
  NSNumber *number = @123;
  [_myObject setSetterBoth:number];

  GHAssertEqualObjects([_myObject objectForKey:@"bothGetterAndSetterNumber"], number, nil);
}

- (void)testReadOnlyStringAllowsUsingItsGetter
{
  NSString *theString = @"the string";
  [_myObject setObject:theString forKey:@"readOnlyString"];

  GHAssertEqualStrings(_myObject.readOnlyString, theString, nil);
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

  GHAssertEquals(_myObject.transientAssignUInteger, 0u, nil);
}

- (void)testCharPropertyInitsToZero
{
  GHAssertEquals(_myObject.charProperty, (char)'\0', nil);
}

- (void)testCharPropertyShouldStoreItsValueIntoPFObject
{
  _myObject.charProperty = (char)'D';

  GHAssertEqualObjects([_myObject objectForKey:@"charProperty"], @'D', nil);
}

- (void)testCharPropertyShouldRetrieveItsValueFromPFObject
{
  [_myObject setObject:@'D' forKey:@"charProperty"];

  GHAssertEquals(_myObject.charProperty, (char)'D', nil);
}

- (void)testUnsignedCharPropertyInitsToZero
{
  GHAssertEquals(_myObject.unsignedCharProperty, (unsigned char)'\0', nil);
}

- (void)testUnsignedCharPropertyShouldStoreItsValueIntoPFObject
{
  _myObject.unsignedCharProperty = (unsigned char)192;

  GHAssertEqualObjects([_myObject objectForKey:@"unsignedCharProperty"], [NSNumber numberWithUnsignedChar:192], nil);
}

- (void)testUnsignedCharPropertyShouldRetrieveItsValueFromPFObject
{
  [_myObject setObject:[NSNumber numberWithUnsignedChar:192] forKey:@"unsignedCharProperty"];

  GHAssertEquals(_myObject.unsignedCharProperty, (unsigned char)192, nil);
}

- (void)testShortPropertyInitsToZero
{
  GHAssertEquals(_myObject.shortProperty, (short)0, nil);
}

- (void)testShortPropertyShouldStoreItsValueIntoPFObject
{
  _myObject.shortProperty = (short)512;

  GHAssertEqualObjects([_myObject objectForKey:@"shortProperty"], [NSNumber numberWithShort:512], nil);
}

- (void)testShortPropertyShouldRetrieveItsValueFromPFObject
{
  [_myObject setObject:[NSNumber numberWithShort:512] forKey:@"shortProperty"];

  GHAssertEquals(_myObject.shortProperty, (short)512, nil);
}

- (void)testUnsignedShortPropertyInitsToZero
{
  GHAssertEquals(_myObject.unsignedShortProperty, (unsigned short)0, nil);
}

- (void)testUnsignedShortPropertyShouldStoreItsValueIntoPFObject
{
  _myObject.unsignedShortProperty = (unsigned short)40000;

  GHAssertEqualObjects([_myObject objectForKey:@"unsignedShortProperty"], [NSNumber numberWithUnsignedShort:40000], nil);
}

- (void)testUnsignedShortPropertyShouldRetrieveItsValueFromPFObject
{
  [_myObject setObject:[NSNumber numberWithUnsignedShort:40000] forKey:@"unsignedShortProperty"];

  GHAssertEquals(_myObject.unsignedShortProperty, (unsigned short)40000, nil);
}

- (void)testIntPropertyInitsToZero
{
  GHAssertEquals(_myObject.intProperty, 0, nil);
}

- (void)testIntPropertyShouldStoreItsValueIntoPFObject
{
  _myObject.intProperty = 70000;

  GHAssertEqualObjects([_myObject objectForKey:@"intProperty"], @70000, nil);
}

- (void)testIntPropertyShouldRetrieveItsValueFromPFObject
{
  [_myObject setObject:@70000 forKey:@"intProperty"];

  GHAssertEquals(_myObject.intProperty, 70000, nil);
}

- (void)testUnsignedIntPropertyInitsToZero
{
  GHAssertEquals(_myObject.unsignedIntProperty, 0u, nil);
}

- (void)testUnsignedIntPropertyShouldStoreItsValueIntoPFObject
{
  _myObject.unsignedIntProperty = INT_MAX + 1u;

  GHAssertEqualObjects([_myObject objectForKey:@"unsignedIntProperty"], @(INT_MAX + 1u), nil);
}

- (void)testUnsignedIntPropertyShouldRetrieveItsValueFromPFObject
{
  [_myObject setObject:@(INT_MAX + 1u) forKey:@"unsignedIntProperty"];

  GHAssertEquals(_myObject.unsignedIntProperty, INT_MAX + 1u, nil);
}

- (void)testLongPropertyInitsToZero
{
  GHAssertEquals(_myObject.longProperty, 0l, nil);
}

- (void)testLongPropertyShouldStoreItsValueIntoPFObject
{
  _myObject.longProperty = 70000l;

  GHAssertEqualObjects([_myObject objectForKey:@"longProperty"], @70000l, nil);
}

- (void)testLongPropertyShouldRetrieveItsValueFromPFObject
{
  [_myObject setObject:@70000l forKey:@"longProperty"];

  GHAssertEquals(_myObject.longProperty, 70000l, nil);
}

- (void)testUnsignedLongPropertyInitsToZero
{
  GHAssertEquals(_myObject.unsignedLongProperty, 0ul, nil);
}

- (void)testUnsignedLongPropertyShouldStoreItsValueIntoPFObject
{
  _myObject.unsignedLongProperty = LONG_MAX + 1u;

  GHAssertEqualObjects([_myObject objectForKey:@"unsignedLongProperty"], @(LONG_MAX + 1lu), nil);
}

- (void)testUnsignedLongPropertyShouldRetrieveItsValueFromPFObject
{
  [_myObject setObject:@(LONG_MAX + 1lu) forKey:@"unsignedLongProperty"];

  GHAssertEquals(_myObject.unsignedLongProperty, LONG_MAX + 1lu, nil);
}

- (void)testLongLongPropertyInitsToZero
{
  GHAssertEquals(_myObject.longLongProperty, 0ll, nil);
}

- (void)testLongLongPropertyShouldStoreItsValueIntoPFObject
{
  _myObject.longLongProperty = 70000ll;

  GHAssertEqualObjects([_myObject objectForKey:@"longLongProperty"], @70000ll, nil);
}

- (void)testLongLongPropertyShouldRetrieveItsValueFromPFObject
{
  [_myObject setObject:@70000ll forKey:@"longLongProperty"];

  GHAssertEquals(_myObject.longLongProperty, 70000ll, nil);
}

- (void)testUnsignedLongLongPropertyInitsToZero
{
  GHAssertEquals(_myObject.unsignedLongLongProperty, 0ull, nil);
}

- (void)testUnsignedLongLongPropertyShouldStoreItsValueIntoPFObject
{
  _myObject.unsignedLongLongProperty = LONG_LONG_MAX + 1ull;

  GHAssertEqualObjects([_myObject objectForKey:@"unsignedLongLongProperty"], @(LONG_LONG_MAX + 1llu), nil);
}

- (void)testUnsignedLongLongPropertyShouldRetrieveItsValueFromPFObject
{
  [_myObject setObject:@(LONG_LONG_MAX + 1llu) forKey:@"unsignedLongLongProperty"];

  GHAssertEquals(_myObject.unsignedLongLongProperty, LONG_LONG_MAX + 1llu, nil);
}

- (void)testFloatPropertyInitsToZero
{
  GHAssertEquals(_myObject.floatProperty, 0.0f, nil);
}

- (void)testFloatPropertyShouldStoreItsValueIntoPFObject
{
  _myObject.floatProperty = 123.456f;

  GHAssertEqualObjects([_myObject objectForKey:@"floatProperty"], @123.456f, nil);
}

- (void)testFloatPropertyShouldRetrieveItsValueFromPFObject
{
  [_myObject setObject:@123.456f forKey:@"floatProperty"];

  GHAssertEqualsWithAccuracy(_myObject.floatProperty, 123.456f, 0.1f, nil);
}

- (void)testDoublePropertyInitsToZero
{
  GHAssertEquals(_myObject.doubleProperty, 0.0, nil);
}

- (void)testDoublePropertyShouldStoreItsValueIntoPFObject
{
  _myObject.doubleProperty = 123.456;

  GHAssertEqualObjects([_myObject objectForKey:@"doubleProperty"], @123.456, nil);
}

- (void)testDoublePropertyShouldRetrieveItsValueFromPFObject
{
  [_myObject setObject:@123.456 forKey:@"doubleProperty"];

  GHAssertEqualsWithAccuracy(_myObject.doubleProperty, 123.456, 0.1, nil);
}

- (void)testCustomGetterShouldReturnDefault
{
  DRTMyPFObjectSubclassWithCustomGetter *object = [[DRTMyPFObjectSubclassWithCustomGetter alloc] init];

  GHAssertEqualStrings(object.stringWithDefault, @"default", nil);
}

- (void)testCustomGetterShouldReturnStoredValue
{
  DRTMyPFObjectSubclassWithCustomGetter *object = [[DRTMyPFObjectSubclassWithCustomGetter alloc] init];
  [object setObject:@"not default" forKey:@"stringWithDefault"];

  GHAssertEqualStrings(object.stringWithDefault, @"not default", nil);
}

- (void)testChildClassNameShouldBeItsClass
{
  DRTMyPFObjectChild *child = [[DRTMyPFObjectChild alloc] init];

  GHAssertEqualStrings(child.className, @"DRTMyPFObjectChild", nil);
}

- (void)testChildShouldStoreParentProperty
{
  DRTMyPFObjectChild *child = [[DRTMyPFObjectChild alloc] init];
  child.stringInParent = @"string in parent";

  GHAssertEqualStrings([child objectForKey:@"stringInParent"], @"string in parent", nil);
}

- (void)testChildShouldRetrieveParentProperty
{
  DRTMyPFObjectChild *child = [[DRTMyPFObjectChild alloc] init];
  [child setObject:@"string in parent" forKey:@"stringInParent"];

  GHAssertEqualStrings(child.stringInParent, @"string in parent", nil);
}

- (void)testPFObjectInitWithClassNameCreatesRightClass
{
  PFObject *object = [[PFObject alloc] initWithClassName:@"DRTMyPFObjectSubclass"];

  GHAssertEqualObjects([object class], [DRTMyPFObjectSubclass class], nil);
}

- (void)testPFObjectObjectWithClassNameCreatesRightClass
{
  PFObject *object = [PFObject objectWithClassName:@"DRTMyPFObjectSubclass"];

  GHAssertEqualObjects([object class], [DRTMyPFObjectSubclass class], nil);
}

- (void)testPFObjectObjectWithoutDataWithClassNameObjectIdCreatesRightClass
{
  PFObject *object = [PFObject objectWithoutDataWithClassName:@"DRTMyPFObjectSubclass" objectId:@"fake object id"];

  GHAssertEqualObjects([object class], [DRTMyPFObjectSubclass class], nil);
}

- (void)testPFObjectObjectWithClassNameDictionaryCreatesRightClass
{
  PFObject *object = [PFObject objectWithClassName:@"DRTMyPFObjectSubclass" dictionary:@{}];

  GHAssertEqualObjects([object class], [DRTMyPFObjectSubclass class], nil);
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


@implementation DRTMyPFObjectSubclassWithCustomGetter

@dynamic stringWithDefault;

- (id)init
{
  return [self initWithAutoClassName];
}

- (NSString *)stringWithDefault
{
  NSString *stringWithDefault = [self objectForKey:@"stringWithDefault"];
  return stringWithDefault ?: @"default";
}

@end


@implementation DRTMyPFObjectParent

@dynamic stringInParent;

- (id)init
{
  return [self initWithAutoClassName];
}

@end


@implementation DRTMyPFObjectChild

@dynamic stringInChild;

@end
