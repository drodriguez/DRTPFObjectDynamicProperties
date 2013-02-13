//
//  DRTPFObject+DynamicProperties.m
//  DRTPFObjectDynamicProperties
//
//  Created by Daniel Rodríguez Troitiño on 09/02/13.
//  Copyright (c) 2013 Daniel Rodríguez Troitiño. All rights reserved.
//

#import "DRTPFObject+DynamicProperties.h"

#import <objc/runtime.h>

#define DRTNil2Null(x) ((x) ?: [NSNull null])
#define DRTNull2Nil(x) ({ __typeof__(x) __x = (x); (NSNull *)__x == [NSNull null] ? nil : __x; })

static const char *DRTSelectorAssociationsKey = "DRTSelectorAssociationsKey";

static SEL DRTGetterSelectorFromPropertyName(const char *name, const char *getterName)
{
  return sel_registerName(getterName ?: name);
}

static SEL DRTSetterSelectorFromPropertyName(const char *name, const char *setterName)
{
  SEL setterSelector = NULL;
  if (setterName)
  {
    setterSelector = sel_registerName(setterName);
  }
  else
  {
    //                    "set" + name + ":" + '\0'
    size_t selectorSize = 3 + strlen(name) + 1 + 1;
    char *selectorName = malloc(selectorSize);
    strlcpy(selectorName, "set", selectorSize);
    strlcat(selectorName, name, selectorSize);
    strlcat(selectorName, ":", selectorSize);
    selectorName[3] = toupper(selectorName[3]);
    setterSelector = sel_registerName(selectorName);
    free(selectorName);
  }

  return setterSelector;
}

@implementation PFObject (DRTDynamicProperties)

static id DRTAtomicStrongGetter(id self, SEL selector)
{
  @synchronized(self)
  {
    NSMutableDictionary *selectorAssociations = objc_getAssociatedObject([self class], &DRTSelectorAssociationsKey);
    NSString *key = [selectorAssociations objectForKey:NSStringFromSelector(selector)];
    return DRTNull2Nil([self objectForKey:key]);
  }
}

static id DRTAtomicCopiedGetter(id self, SEL selector)
{
  @synchronized(self)
  {
    NSMutableDictionary *selectorAssociations = objc_getAssociatedObject([self class], &DRTSelectorAssociationsKey);
    NSString *key = [selectorAssociations objectForKey:NSStringFromSelector(selector)];
    return [DRTNull2Nil([self objectForKey:key]) copy];
  }
}

static id DRTNonAtomicStrongGetter(id self, SEL selector)
{
  NSMutableDictionary *selectorAssociations = objc_getAssociatedObject([self class], &DRTSelectorAssociationsKey);
  NSString *key = [selectorAssociations objectForKey:NSStringFromSelector(selector)];
  return DRTNull2Nil([self objectForKey:key]);
}

static id DRTNonAtomicCopiedGetter(id self, SEL selector)
{
  NSMutableDictionary *selectorAssociations = objc_getAssociatedObject([self class], &DRTSelectorAssociationsKey);
  NSString *key = [selectorAssociations objectForKey:NSStringFromSelector(selector)];
  return [DRTNull2Nil([self objectForKey:key]) copy];
}

static void DRTAtomicStrongSetter(id self, SEL selector, id value)
{
  @synchronized(self)
  {
    NSMutableDictionary *selectorAssociations = objc_getAssociatedObject([self class], &DRTSelectorAssociationsKey);
    NSString *key = [selectorAssociations objectForKey:NSStringFromSelector(selector)];
    [self setObject:DRTNil2Null(value) forKey:key];
  }
}

static void DRTAtomicCopiedSetter(id self, SEL selector, id value)
{
  @synchronized(self)
  {
    NSMutableDictionary *selectorAssociations = objc_getAssociatedObject([self class], &DRTSelectorAssociationsKey);
    NSString *key = [selectorAssociations objectForKey:NSStringFromSelector(selector)];
    [self setObject:DRTNil2Null([value copy]) forKey:key];
  }
}

static void DRTNonAtomicStrongSetter(id self, SEL selector, id value)
{
  NSMutableDictionary *selectorAssociations = objc_getAssociatedObject([self class], &DRTSelectorAssociationsKey);
  NSString *key = [selectorAssociations objectForKey:NSStringFromSelector(selector)];
  [self setObject:DRTNil2Null(value) forKey:key];
}

static void DRTNonAtomicCopiedSetter(id self, SEL selector, id value)
{
  NSMutableDictionary *selectorAssociations = objc_getAssociatedObject([self class], &DRTSelectorAssociationsKey);
  NSString *key = [selectorAssociations objectForKey:NSStringFromSelector(selector)];
  [self setObject:DRTNil2Null([value copy]) forKey:key];
}

#define DRTAtomicAssignGetterName(selectorPart) DRTAtomicAssignGetter ## selectorPart
#define DRTNonAtomicAssignGetterName(selectorPart) DRTNonAtomicAssignGetter ## selectorPart

#define DRTAtomicAssignSetterName(selectorPart) DRTAtomicAssignSetter ## selectorPart
#define DRTNonAtomicAssignSetterName(selectorPart) DRTNonAtomicAssignSetter ## selectorPart

#define DRTAtomicAssignGetter(type, selectorPart) \
static type DRTAtomicAssignGetterName(selectorPart)(id self, SEL selector) \
{ \
  @synchronized(self) \
  { \
    NSMutableDictionary *selectorAssociations = objc_getAssociatedObject([self class], &DRTSelectorAssociationsKey); \
    NSString *key = [selectorAssociations objectForKey:NSStringFromSelector(selector)]; \
    return [[self objectForKey:key] selectorPart ## Value]; \
  } \
}

#define DRTNonAtomicAssignGetter(type, selectorPart) \
static type DRTNonAtomicAssignGetterName(selectorPart)(id self, SEL selector) \
{ \
  NSMutableDictionary *selectorAssociations = objc_getAssociatedObject([self class], &DRTSelectorAssociationsKey); \
  NSString *key = [selectorAssociations objectForKey:NSStringFromSelector(selector)]; \
  return [[self objectForKey:key] selectorPart ## Value]; \
}

#define DRTAtomicAssignSetter(type, selectorPart) \
static void DRTAtomicAssignSetterName(selectorPart)(id self, SEL selector, type value) \
{ \
  @synchronized(self) \
  { \
    NSMutableDictionary *selectorAssociations = objc_getAssociatedObject([self class], &DRTSelectorAssociationsKey); \
    NSString *key = [selectorAssociations objectForKey:NSStringFromSelector(selector)]; \
    [self setObject:[NSNumber numberWith ## selectorPart:value] forKey:key]; \
  } \
}

#define DRTNonAtomicAssignSetter(type, selectorPart) \
static void DRTNonAtomicAssignSetterName(selectorPart)(id self, SEL selector, type value) \
{ \
  NSMutableDictionary *selectorAssociations = objc_getAssociatedObject([self class], &DRTSelectorAssociationsKey); \
  NSString *key = [selectorAssociations objectForKey:NSStringFromSelector(selector)]; \
  [self setObject:[NSNumber numberWith ## selectorPart:value] forKey:key]; \
}

DRTAtomicAssignGetter(char, char);
DRTAtomicAssignGetter(unsigned char, unsignedChar);
DRTAtomicAssignGetter(short, short);
DRTAtomicAssignGetter(unsigned short, unsignedShort);
DRTAtomicAssignGetter(int, int);
DRTAtomicAssignGetter(unsigned int, unsignedInt);
DRTAtomicAssignGetter(long, long);
DRTAtomicAssignGetter(unsigned long, unsignedLong);
DRTAtomicAssignGetter(long long, longLong);
DRTAtomicAssignGetter(unsigned long long, unsignedLongLong);
DRTAtomicAssignGetter(float, float);
DRTAtomicAssignGetter(double, double);

DRTNonAtomicAssignGetter(char, char);
DRTNonAtomicAssignGetter(unsigned char, unsignedChar);
DRTNonAtomicAssignGetter(short, short);
DRTNonAtomicAssignGetter(unsigned short, unsignedShort);
DRTNonAtomicAssignGetter(int, int);
DRTNonAtomicAssignGetter(unsigned int, unsignedInt);
DRTNonAtomicAssignGetter(long, long);
DRTNonAtomicAssignGetter(unsigned long, unsignedLong);
DRTNonAtomicAssignGetter(long long, longLong);
DRTNonAtomicAssignGetter(unsigned long long, unsignedLongLong);
DRTNonAtomicAssignGetter(float, float);
DRTNonAtomicAssignGetter(double, double);

DRTAtomicAssignSetter(char, Char);
DRTAtomicAssignSetter(unsigned char, UnsignedChar);
DRTAtomicAssignSetter(short, Short);
DRTAtomicAssignSetter(unsigned short, UnsignedShort);
DRTAtomicAssignSetter(int, Int);
DRTAtomicAssignSetter(unsigned int, UnsignedInt);
DRTAtomicAssignSetter(long, Long);
DRTAtomicAssignSetter(unsigned long, UnsignedLong);
DRTAtomicAssignSetter(long long, LongLong);
DRTAtomicAssignSetter(unsigned long long, UnsignedLongLong);
DRTAtomicAssignSetter(float, Float);
DRTAtomicAssignSetter(double, Double);

DRTNonAtomicAssignSetter(char, Char);
DRTNonAtomicAssignSetter(unsigned char, UnsignedChar);
DRTNonAtomicAssignSetter(short, Short);
DRTNonAtomicAssignSetter(unsigned short, UnsignedShort);
DRTNonAtomicAssignSetter(int, Int);
DRTNonAtomicAssignSetter(unsigned int, UnsignedInt);
DRTNonAtomicAssignSetter(long, Long);
DRTNonAtomicAssignSetter(unsigned long, UnsignedLong);
DRTNonAtomicAssignSetter(long long, LongLong);
DRTNonAtomicAssignSetter(unsigned long long, UnsignedLongLong);
DRTNonAtomicAssignSetter(float, Float);
DRTNonAtomicAssignSetter(double, Double);

static IMP DRTGetterIMPFromPropertyAttributes(BOOL isStrong, BOOL isCopy, BOOL isNonAtomic)
{
  if (isStrong && isNonAtomic)
  {
    return (IMP)DRTNonAtomicStrongGetter;
  }
  else if (isCopy && isNonAtomic)
  {
    return (IMP)DRTNonAtomicCopiedGetter;
  }
  else if (isStrong)
  {
    return (IMP)DRTAtomicStrongGetter;
  }
  else
  {
    return (IMP)DRTAtomicCopiedGetter;
  }
}

static IMP DRTGetterIMPFromEncoding(const char *encoding, BOOL isNonAtomic)
{
  if      (encoding[0] == @encode(char)[0])               return isNonAtomic ? (IMP)DRTNonAtomicAssignGetterName(char)             : (IMP)DRTAtomicAssignGetterName(char);
  else if (encoding[0] == @encode(unsigned char)[0])      return isNonAtomic ? (IMP)DRTNonAtomicAssignGetterName(unsignedChar)     : (IMP)DRTAtomicAssignGetterName(unsignedChar) ;
  else if (encoding[0] == @encode(short)[0])              return isNonAtomic ? (IMP)DRTNonAtomicAssignGetterName(short)            : (IMP)DRTAtomicAssignGetterName(short);
  else if (encoding[0] == @encode(unsigned short)[0])     return isNonAtomic ? (IMP)DRTNonAtomicAssignGetterName(unsignedShort)    : (IMP)DRTAtomicAssignGetterName(unsignedShort);
  else if (encoding[0] == @encode(int)[0])                return isNonAtomic ? (IMP)DRTNonAtomicAssignGetterName(int)              : (IMP)DRTAtomicAssignGetterName(int);
  else if (encoding[0] == @encode(unsigned int)[0])       return isNonAtomic ? (IMP)DRTNonAtomicAssignGetterName(unsignedInt)      : (IMP)DRTAtomicAssignGetterName(unsignedInt);
  else if (encoding[0] == @encode(long)[0])               return isNonAtomic ? (IMP)DRTNonAtomicAssignGetterName(long)             : (IMP)DRTAtomicAssignGetterName(long);
  else if (encoding[0] == @encode(unsigned long)[0])      return isNonAtomic ? (IMP)DRTNonAtomicAssignGetterName(unsignedLong)     : (IMP)DRTAtomicAssignGetterName(unsignedLong);
  else if (encoding[0] == @encode(long long)[0])          return isNonAtomic ? (IMP)DRTNonAtomicAssignGetterName(longLong)         : (IMP)DRTAtomicAssignGetterName(longLong);
  else if (encoding[0] == @encode(unsigned long long)[0]) return isNonAtomic ? (IMP)DRTNonAtomicAssignGetterName(unsignedLongLong) : (IMP)DRTAtomicAssignGetterName(unsignedLongLong);
  else if (encoding[0] == @encode(float)[0])              return isNonAtomic ? (IMP)DRTNonAtomicAssignGetterName(float)            : (IMP)DRTAtomicAssignGetterName(float);
  else if (encoding[0] == @encode(double)[0])             return isNonAtomic ? (IMP)DRTNonAtomicAssignGetterName(double)           : (IMP)DRTAtomicAssignGetterName(double);
  else NSCAssert(NO, @"invalid encoding %s", encoding); return NULL;
}

static IMP DRTSetterIMPFromEncoding(const char *encoding, BOOL isNonAtomic)
{
  if      (encoding[0] == @encode(char)[0])               return isNonAtomic ? (IMP)DRTNonAtomicAssignSetterName(Char)             : (IMP)DRTAtomicAssignSetterName(Char);
  else if (encoding[0] == @encode(unsigned char)[0])      return isNonAtomic ? (IMP)DRTNonAtomicAssignSetterName(UnsignedChar)     : (IMP)DRTAtomicAssignSetterName(UnsignedChar) ;
  else if (encoding[0] == @encode(short)[0])              return isNonAtomic ? (IMP)DRTNonAtomicAssignSetterName(Short)            : (IMP)DRTAtomicAssignSetterName(Short);
  else if (encoding[0] == @encode(unsigned short)[0])     return isNonAtomic ? (IMP)DRTNonAtomicAssignSetterName(UnsignedShort)    : (IMP)DRTAtomicAssignSetterName(UnsignedShort);
  else if (encoding[0] == @encode(int)[0])                return isNonAtomic ? (IMP)DRTNonAtomicAssignSetterName(Int)              : (IMP)DRTAtomicAssignSetterName(Int);
  else if (encoding[0] == @encode(unsigned int)[0])       return isNonAtomic ? (IMP)DRTNonAtomicAssignSetterName(UnsignedInt)      : (IMP)DRTAtomicAssignSetterName(UnsignedInt);
  else if (encoding[0] == @encode(long)[0])               return isNonAtomic ? (IMP)DRTNonAtomicAssignSetterName(Long)             : (IMP)DRTAtomicAssignSetterName(Long);
  else if (encoding[0] == @encode(unsigned long)[0])      return isNonAtomic ? (IMP)DRTNonAtomicAssignSetterName(UnsignedLong)     : (IMP)DRTAtomicAssignSetterName(UnsignedLong);
  else if (encoding[0] == @encode(long long)[0])          return isNonAtomic ? (IMP)DRTNonAtomicAssignSetterName(LongLong)         : (IMP)DRTAtomicAssignSetterName(LongLong);
  else if (encoding[0] == @encode(unsigned long long)[0]) return isNonAtomic ? (IMP)DRTNonAtomicAssignSetterName(UnsignedLongLong) : (IMP)DRTAtomicAssignSetterName(UnsignedLongLong);
  else if (encoding[0] == @encode(float)[0])              return isNonAtomic ? (IMP)DRTNonAtomicAssignSetterName(Float)            : (IMP)DRTAtomicAssignSetterName(Float);
  else if (encoding[0] == @encode(double)[0])             return isNonAtomic ? (IMP)DRTNonAtomicAssignSetterName(Double)           : (IMP)DRTAtomicAssignSetterName(Double);
  else NSCAssert(NO, @"invalid encoding %s", encoding); return NULL;
}

static IMP DRTSetterIMPFromPropertyAttributes(BOOL isStrong, BOOL isCopy, BOOL isNonAtomic)
{
  if (isStrong && isNonAtomic)
  {
    return (IMP)DRTNonAtomicStrongSetter;
  }
  else if (isCopy && isNonAtomic)
  {
    return (IMP)DRTNonAtomicCopiedSetter;
  }
  else if (isStrong)
  {
    return (IMP)DRTAtomicStrongSetter;
  }
  else
  {
    return (IMP)DRTAtomicCopiedSetter;
  }
}

+ (void)load
{
  @autoreleasepool
  {
    SEL originalSelector = @selector(initialize);
    SEL aliasSelector = @selector(drt_initialize);
    Class metaclass = object_getClass(self);
    Method originalMethod = class_getInstanceMethod(metaclass, originalSelector);
    if (originalMethod)
    {
      Method aliasMethod = class_getInstanceMethod(metaclass, aliasSelector);
      class_addMethod(metaclass, originalSelector, class_getMethodImplementation(metaclass, originalSelector), method_getTypeEncoding(originalMethod));
      class_addMethod(metaclass, aliasSelector, class_getMethodImplementation(metaclass, aliasSelector), method_getTypeEncoding(aliasMethod));
      method_exchangeImplementations(class_getInstanceMethod(metaclass, originalSelector), class_getInstanceMethod(metaclass, aliasSelector));
    }
  }
}

+ (void)drt_initialize {
  [self drt_initialize]; // this is actually the unswizzle original method.
  if ([PFObject class] != [self class])
  {
    // We are in a subclass of PFObject. Since the property list doesn't give
    // the superclasses properties, we are free here to override overriden
    // properties freely.
    [self drt_initializeSelectorAssociations];
    [self drt_initializeDynamicProperties];
  }
}

- (id)initWithAutoClassName
{
  return [self initWithClassName:NSStringFromClass([self class])];
}

#pragma mark - Private methods

+ (void)drt_initializeDynamicProperties
{
  unsigned int propertiesCount = 0;
  objc_property_t *properties = NULL;
  properties = class_copyPropertyList([self class], &propertiesCount);

  for (unsigned int idx = 0; idx < propertiesCount; idx++)
  {
    objc_property_t property = properties[idx];
    [self drt_initializeDynamicProperty:property];
  }

  free(properties);
}

+ (void)drt_initializeDynamicProperty:(objc_property_t)property
{
  const char *propertyName = property_getName(property);

  unsigned int propertyAttributesCount = 0;
  objc_property_attribute_t *propertyAttributes = nil;
  propertyAttributes = property_copyAttributeList(property, &propertyAttributesCount);

  BOOL isDynamic = NO;
  BOOL isStrong = NO;
  BOOL isCopy = NO;
  BOOL isWeak = NO;
  BOOL isNonAtomic = NO;
  BOOL isReadOnly = NO;
  const char *getterName = NULL;
  const char *setterName = NULL;
  const char *typeEncoding = NULL;
  for (unsigned int jdx = 0; jdx < propertyAttributesCount; jdx++)
  {
    objc_property_attribute_t attribute = propertyAttributes[jdx];
    switch (attribute.name[0])
    {
      case 'D': isDynamic = YES; break;
      case '&': isStrong = YES; break;
      case 'C': isCopy = YES; break;
      case 'W': isWeak = YES; break;
      case 'N': isNonAtomic = YES; break;
      case 'R': isReadOnly = YES; break;
      case 'G': getterName = attribute.value; break;
      case 'S': setterName = attribute.value; break;
      case 'T': typeEncoding = attribute.value; break;
    }
  }

  if (isDynamic && !isWeak)
  {
    SEL getterSelector = DRTGetterSelectorFromPropertyName(propertyName, getterName);
    [self drt_addGetter:getterSelector propertyName:propertyName isStrong:isStrong isCopy:isCopy isNonAtomic:isNonAtomic encoding:typeEncoding];

    if (!isReadOnly)
    {
      SEL setterSelector = DRTSetterSelectorFromPropertyName(propertyName, setterName);
      [self drt_addSetter:setterSelector propertyName:propertyName isStrong:isStrong isCopy:isCopy isNonAtomic:isNonAtomic encoding:typeEncoding];
    }
  }

  free(propertyAttributes);
}

+ (void)drt_addGetter:(SEL)selector propertyName:(const char *)propertyName isStrong:(BOOL)isStrong isCopy:(BOOL)isCopy isNonAtomic:(BOOL)isNonAtomic encoding:(const char *)encoding
{
  // NSObject readonly properties do not specify strong or copy as attribute
  if (!isStrong && !isCopy && encoding[0] == @encode(id)[0])
  {
    isStrong = YES;
  }

  IMP getterIMP = NULL;
  if (isStrong || isCopy)
  {
    getterIMP = DRTGetterIMPFromPropertyAttributes(isStrong, isCopy, isNonAtomic);
  }
  else
  {
    getterIMP = DRTGetterIMPFromEncoding(encoding, isNonAtomic);
  }

  [self drt_associateSelector:selector withPropertyName:propertyName];
  NSString *getterEncoding = [NSString stringWithFormat:@"%s%s%s", encoding, @encode(id), @encode(SEL)];
  class_addMethod([self class], selector, getterIMP, [getterEncoding UTF8String]);
}

+ (void)drt_addSetter:(SEL)selector propertyName:(const char *)propertyName isStrong:(BOOL)isStrong isCopy:(BOOL)isCopy isNonAtomic:(BOOL)isNonAtomic encoding:(const char *)encoding
{
  IMP setterIMP = NULL;
  if (isStrong || isCopy)
  {
    setterIMP = DRTSetterIMPFromPropertyAttributes(isStrong, isCopy, isNonAtomic);
  }
  else
  {
    setterIMP = DRTSetterIMPFromEncoding(encoding, isNonAtomic);
  }

  [self drt_associateSelector:selector withPropertyName:propertyName];
  NSString *setterEncoding = [NSString stringWithFormat:@"%s%s%s%s", @encode(void), @encode(id), @encode(SEL), encoding];
  class_addMethod([self class], selector, setterIMP, [setterEncoding UTF8String]);
}

+ (void)drt_associateSelector:(SEL)selector withPropertyName:(const char *)propertyName
{
  NSMutableDictionary *selectorAssociations = objc_getAssociatedObject(self, &DRTSelectorAssociationsKey);
  [selectorAssociations setObject:[[NSString alloc] initWithBytes:propertyName length:strlen(propertyName) encoding:NSASCIIStringEncoding]
                           forKey:NSStringFromSelector(selector)];
}

+ (void)drt_initializeSelectorAssociations
{
  objc_setAssociatedObject(self, &DRTSelectorAssociationsKey, [NSMutableDictionary dictionary], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
