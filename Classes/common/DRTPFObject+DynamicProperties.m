//
//  DRTPFObject+DynamicProperties.m
//  DRTPFObjectDynamicProperties
//
//  Created by Daniel Rodríguez Troitiño on 09/02/13.
//  Copyright (c) 2013 Daniel Rodríguez Troitiño. All rights reserved.
//

#import "DRTPFObject+DynamicProperties.h"

#import <objc/runtime.h>

static NSString *DRTKeyFromGetterSelector(SEL selector)
{
  return NSStringFromSelector(selector);
}

static NSString *DRTKeyFromSetterSelector(SEL selector)
{
  const char *selectorName = sel_getName(selector);
  char *duplicate = strdup(selectorName);
  duplicate[3] = tolower(duplicate[3]);
  duplicate[strlen(duplicate) - 1] = '\0'; // Remove the last colon char
  NSString *key = [[NSString alloc] initWithCString:duplicate+3 encoding:NSASCIIStringEncoding];
  free(duplicate);
  return key;
}

static SEL DRTGetterSelectorFromPropertyName(const char *name)
{
  return sel_registerName(name);
}

static SEL DRTSetterSelectorFromPropertyName(const char *name)
{
  //                    "set" + name + ":" + '\0'
  size_t selectorSize = 3 + strlen(name) + 1 + 1;
  char *selectorName = malloc(selectorSize);
  strlcpy(selectorName, "set", selectorSize);
  strlcat(selectorName, name, selectorSize);
  strlcat(selectorName, ":", selectorSize);
  selectorName[3] = toupper(selectorName[3]);
  SEL selector = sel_registerName(selectorName);
  free(selectorName);

  return selector;
}

@implementation PFObject (DRTDynamicProperties)

static id DRTAtomicStrongGetter(id self, SEL selector)
{
  @synchronized(self)
  {
    NSString *key = DRTKeyFromGetterSelector(selector);
    return [self objectForKey:key];
  }
}

static id DRTAtomicCopiedGetter(id self, SEL selector)
{
  @synchronized(self)
  {
    NSString *key = DRTKeyFromGetterSelector(selector);
    return [[self objectForKey:key] copy];
  }
}

static id DRTNonAtomicStrongGetter(id self, SEL selector)
{
  NSString *key = NSStringFromSelector(selector);
  return [self objectForKey:key];
}

static id DRTNonAtomicCopiedGetter(id self, SEL selector)
{
  NSString *key = NSStringFromSelector(selector);
  return [[self objectForKey:key] copy];
}

static void DRTAtomicStrongSetter(id self, SEL selector, id value)
{
  @synchronized(self)
  {
    NSString *key = DRTKeyFromSetterSelector(selector);
    [self setObject:value forKey:key];
  }
}

static void DRTAtomicCopiedSetter(id self, SEL selector, id value)
{
  @synchronized(self)
  {
    NSString *key = DRTKeyFromSetterSelector(selector);
    [self setObject:[value copy] forKey:key];
  }
}

static void DRTNonAtomicStrongSetter(id self, SEL selector, id value)
{
  NSString *key = DRTKeyFromSetterSelector(selector);
  [self setObject:value forKey:key];
}

static void DRTNonAtomicCopiedSetter(id self, SEL selector, id value)
{
  NSString *key = DRTKeyFromSetterSelector(selector);
  [self setObject:[value copy] forKey:key];
}

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
  @autoreleasepool {
    SEL originalSelector = @selector(initialize);
    SEL aliasSelector = @selector(drt_initialize);
    Class metaclass = object_getClass(self);
    Method originalMethod = class_getInstanceMethod(metaclass, originalSelector);
    if (originalMethod) {
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
    unsigned int propertiesCount = 0;
    objc_property_t *properties = NULL;
    properties = class_copyPropertyList([self class], &propertiesCount);

    for (unsigned int idx = 0; idx < propertiesCount; idx++) {
      objc_property_t property = properties[idx];
      const char *propertyName = property_getName(property);

      unsigned int propertyAttributesCount = 0;
      objc_property_attribute_t *propertyAttributes = nil;
      propertyAttributes = property_copyAttributeList(property, &propertyAttributesCount);

      BOOL isDynamic = NO;
      BOOL isStrong = NO;
      BOOL isCopy = NO;
      BOOL isNonAtomic = NO;
      for (unsigned int jdx = 0; jdx < propertyAttributesCount; jdx++) {
        objc_property_attribute_t attribute = propertyAttributes[jdx];
        if (attribute.name[0] == 'D') isDynamic = YES;
        if (attribute.name[0] == '&') isStrong = YES;
        if (attribute.name[0] == 'C') isCopy = YES;
        if (attribute.name[0] == 'N') isNonAtomic = YES;
        // FIXME: deal with setter and getter attributes.
      }

      free(propertyAttributes);

      if (isDynamic && (isStrong || isCopy)) {
        SEL getterSelector = DRTGetterSelectorFromPropertyName(propertyName);
        SEL setterSelector = DRTSetterSelectorFromPropertyName(propertyName);
        IMP getterIMP = DRTGetterIMPFromPropertyAttributes(isStrong, isCopy, isNonAtomic);
        IMP setterIMP = DRTSetterIMPFromPropertyAttributes(isStrong, isCopy, isNonAtomic);

        // FIXME: deal with readonly properties? PFObjects readonly properties
        // doesn't make sense.
        class_addMethod([self class], setterSelector, setterIMP, "v@:@");
        class_addMethod([self class], getterSelector, getterIMP, "@@:");
      }
    }

    free(properties);
  }
}

- (id)initWithAutoClassName
{
  return [self initWithClassName:NSStringFromClass([self class])];
}

@end
