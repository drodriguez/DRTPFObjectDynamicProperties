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

@end


@implementation DRTMyPFObjectSubclass

@dynamic atomicStrongDictionary;
@dynamic nonatomicStrongNumber;
@dynamic atomicCopiedString;
@dynamic nonatomicCopiedArray;

- (id)init
{
    return [self initWithAutoClassName];
}

@end