//
//  OGPlayerEntity.m
//  Olvido
//
//  Created by Дмитрий Антипенко on 11/4/16.
//  Copyright © 2016 Дмитрий Антипенко. All rights reserved.
//

#import "OGPlayerEntity.h"
#import "OGRenderComponent.h"
#import "OGHealthComponent.h"
#import "OGIntelligenceComponent.h"
#import "OGInputComponent.h"
#import "OGMovementComponent.h"
#import "OGAnimationComponent.h"
#import "OGPhysicsComponent.h"

#import "OGPlayerEntityConfiguration.h"

@interface OGPlayerEntity ()

@property (nonatomic, strong) OGPlayerEntityConfiguration *playerConfiguration;

@end

@implementation OGPlayerEntity

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        _playerConfiguration = [[OGPlayerEntityConfiguration alloc] init];
        
        _render = [[OGRenderComponent alloc] init];
        [self addComponent:_render];
        
        _physics = [[OGPhysicsComponent alloc] initWithPhysicsBody:[SKPhysicsBody bodyWithCircleOfRadius:_playerConfiguration.physicsBodyRadius]
                                                      colliderType:_playerConfiguration.colliderType];
        [self addComponent:_physics];
        
        _render.node.physicsBody = _physics.physicsBody;
        
        _health = [[OGHealthComponent alloc] init];
        _health.maxHealth = _playerConfiguration.maxHealth;
        _health.currentHealth = _playerConfiguration.currentHealth;
        [self addComponent:_health];
        
        _movement = [[OGMovementComponent alloc] init];
        [self addComponent:_movement];
        
        _input = [[OGInputComponent alloc] init];
        _input.enabled = YES;
        [self addComponent:_input];
        
        _intelligence = [[OGIntelligenceComponent alloc] initWithStates:nil];
        //[self addComponent:_intelligence];
        
        _animation = [[OGAnimationComponent alloc] init];
        [self addComponent:_animation];
    }
    
    return self;
}

@end
