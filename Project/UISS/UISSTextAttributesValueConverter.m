//
// Copyright (c) 2013 Robert Wijas. All rights reserved.
//

#import "UISSTextAttributesValueConverter.h"
#import "UISSFontValueConverter.h"
#import "UISSColorValueConverter.h"
#import "UISSOffsetValueConverter.h"
#import "UISSArgument.h"
#import "UISSFloatValueConverter.h"

NSString *const FontKey = @"font";
NSString *const TextColorKey = @"textColor";
NSString *const TextShadowColorKey = @"textShadowColor";
NSString *const TextShadowOffsetKey = @"textShadowOffset";

NSString *const BaselineOffsetKey = @"baselineOffset";

@interface UISSTextAttributesValueConverter ()

@property(nonatomic, strong) UISSFontValueConverter *fontConverter;
@property(nonatomic, strong) UISSColorValueConverter *colorConverter;
@property(nonatomic, strong) UISSOffsetValueConverter *offsetConverter;

@end

@implementation UISSTextAttributesValueConverter

- (id)init
{
    self = [super init];
    if (self) {
        _fontConverter = [UISSFontValueConverter new];
        _colorConverter = [UISSColorValueConverter new];
        _offsetConverter = [UISSOffsetValueConverter new];
    }
    return self;
}

- (BOOL)canConvertValueForArgument:(UISSArgument *)argument
{
    return [argument.type hasPrefix:@"@"] && [[argument.name lowercaseString] hasSuffix:@"textattributes"] && [argument.value isKindOfClass:[NSDictionary class]];
}

- (void)convertProperty:(NSString *)propertyName fromDictionary:(NSDictionary *)dictionary
           toDictionary:(NSMutableDictionary *)converterDictionary withKey:(NSString *)key
         usingConverter:(id<UISSArgumentValueConverter>)converter;
{
    id value = [dictionary objectForKey:propertyName];

    if (value) {
        if (converter) {
            id converted = [converter convertValue:value];

            if (converted) {
                [converterDictionary setObject:converted forKey:key];
            }
        } else {
            converterDictionary[key] = value;
        }
    }
}

- (id)convertValue:(id)value;
{
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = (NSDictionary *) value;

        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];

        [self convertProperty:FontKey
               fromDictionary:dictionary
                 toDictionary:attributes
                      withKey:UITextAttributeFont
               usingConverter:self.fontConverter];

        [self convertProperty:TextColorKey
               fromDictionary:dictionary
                 toDictionary:attributes
                      withKey:UITextAttributeTextColor
               usingConverter:self.colorConverter];

        [self convertProperty:TextShadowColorKey
               fromDictionary:dictionary
                 toDictionary:attributes
                      withKey:UITextAttributeTextShadowColor
               usingConverter:self.colorConverter];

        [self convertProperty:TextShadowOffsetKey
               fromDictionary:dictionary
                 toDictionary:attributes
                      withKey:UITextAttributeTextShadowOffset
               usingConverter:self.offsetConverter];

        [self convertProperty:BaselineOffsetKey
               fromDictionary:dictionary
                 toDictionary:attributes
                      withKey:NSBaselineOffsetAttributeName
               usingConverter:nil];

        if (attributes.count) {
            return attributes;
        }
    }

    return nil;
}

- (NSString *)generateCodeForValue:(id)value
{
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = (NSDictionary *) value;

        NSMutableString *objectAndKeys = [NSMutableString string];

        id fontValue = [dictionary objectForKey:FontKey];
        if (fontValue) {
            [objectAndKeys appendFormat:@"%@, %@,", [self.fontConverter generateCodeForValue:fontValue], @"UITextAttributeFont"];
        }

        id textColorValue = [dictionary objectForKey:TextColorKey];
        if (textColorValue) {
            [objectAndKeys appendFormat:@"%@, %@,", [self.colorConverter generateCodeForValue:textColorValue], @"UITextAttributeTextColor"];
        }

        id textShadowColor = [dictionary objectForKey:TextShadowColorKey];
        if (textShadowColor) {
            [objectAndKeys appendFormat:@"%@, %@,", [self.colorConverter generateCodeForValue:textShadowColor], @"UITextAttributeTextShadowColor"];
        }

        id textShadowOffset = [dictionary objectForKey:TextShadowOffsetKey];
        if (textShadowOffset) {
            [objectAndKeys appendFormat:@"[NSValue valueWithUIOffset:%@], %@,", [self.offsetConverter generateCodeForValue:textShadowOffset], @"UITextAttributeTextShadowOffset"];
        }

        id baselineOffset = [dictionary objectForKey:BaselineOffsetKey];
        if (baselineOffset) {
            [objectAndKeys appendFormat:@"%@, %@,", baselineOffset, @"UITextAttributeTextShadowColor"];
        }

        if (objectAndKeys.length) {
            return [NSString stringWithFormat:@"[NSDictionary dictionaryWithObjectsAndKeys:%@ nil]", objectAndKeys];
        }
    }
    
    return nil;
}

@end
