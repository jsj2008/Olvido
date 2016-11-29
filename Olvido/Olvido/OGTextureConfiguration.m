//
//  OGTextureConfiguration.m
//  Olvido
//
//  Created by Александр Песоцкий on 11/25/16.
//  Copyright © 2016 Дмитрий Антипенко. All rights reserved.
//

#import "OGTextureConfiguration.h"

NSString *const kOGTextureConfigurationPairTextureNameKey = @"Pair";
NSString *const kOGTextureConfigurationTextureNameKey = @"Name";
NSString *const kOGTextureConfigurationRepeatForeverKey = @"Repeat";
NSString *const kOGTextureConfigurationBackwardKey = @"Backward";
NSString *const kOGTextureConfigurationTimePerFrameKey = @"TimePerFrame";

BOOL const kOGTextureConfigurationDefaultRepeatForever = YES;
BOOL const kOGTextureConfigurationDefaultBackward = NO;
CGFloat const kOGTextureConfigurationDefaultTimePerFrame = 0.1;

@interface OGTextureConfiguration ()

@property (nonatomic, strong) NSString *pairTextureName;
@property (nonatomic, strong) NSString *textureName;
@property (nonatomic, assign) CGFloat timePerFrame;
@property (nonatomic, assign) BOOL repeatForever;
@property (nonatomic, assign) BOOL backward;
@end

@implementation OGTextureConfiguration

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    
    if (self)
    {
        _repeatForever = kOGTextureConfigurationDefaultRepeatForever;
        _timePerFrame = kOGTextureConfigurationDefaultTimePerFrame;
        _backward = kOGTextureConfigurationDefaultBackward;
        
        NSString *pairTextureName = dictionary[kOGTextureConfigurationPairTextureNameKey];
        
        if (pairTextureName)
        {
            _pairTextureName = pairTextureName;
        }
        
        NSString *textureName = dictionary[kOGTextureConfigurationTextureNameKey];
        
        if (textureName)
        {
            _textureName = textureName;
        }
        
        if (dictionary[kOGTextureConfigurationRepeatForeverKey])
        {
            _repeatForever = [dictionary[kOGTextureConfigurationRepeatForeverKey] boolValue];
        }
        
        if (dictionary[kOGTextureConfigurationBackwardKey])
        {
            _backward = [dictionary[kOGTextureConfigurationBackwardKey] boolValue];
        }

        if (dictionary[kOGTextureConfigurationTimePerFrameKey])
        {
            _timePerFrame = [dictionary[kOGTextureConfigurationTimePerFrameKey] floatValue];
        }
    }

    return self;
}

@end
