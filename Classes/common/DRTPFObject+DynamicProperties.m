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

  free(propertyAttributes);

  // readonly properties do not have strong or copy attributes, even if defined
  if (isDynamic && (isStrong || isCopy || (isReadOnly && typeEncoding[0] == @encode(id)[0])))
  {
    SEL getterSelector = NULL;
    if (getterName != NULL)
    {
      getterSelector = sel_registerName(getterName);
    }
    else
    {
      getterSelector = DRTGetterSelectorFromPropertyName(propertyName);
    }

    IMP getterIMP = DRTGetterIMPFromPropertyAttributes(isStrong, isCopy, isNonAtomic);

    [self drt_associateSelector:getterSelector withPropertyName:propertyName];
    class_addMethod([self class], getterSelector, getterIMP, @encode(id (*)(id, SEL)));

    if (!isReadOnly)
    {
      SEL setterSelector = NULL;
      if (setterName)
      {
        setterSelector = sel_registerName(setterName);
      }
      else
      {
        setterSelector = DRTSetterSelectorFromPropertyName(propertyName);
      }

      IMP setterIMP = DRTSetterIMPFromPropertyAttributes(isStrong, isCopy, isNonAtomic);
      [self drt_associateSelector:setterSelector withPropertyName:propertyName];
      class_addMethod([self class], setterSelector, setterIMP, @encode(void (*)(id, SEL, id)));
    }
  }
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
