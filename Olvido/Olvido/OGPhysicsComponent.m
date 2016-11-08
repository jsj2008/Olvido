//
//  OGPhysicsComponent.m
//  Olvido
//
//  Created by Дмитрий Антипенко on 11/6/16.
//  Copyright © 2016 Дмитрий Антипенко. All rights reserved.
//

#import "OGPhysicsComponent.h"

@interface OGPhysicsComponent ()

@property (nonatomic, strong, readwrite) SKPhysicsBody *physicsBody;

@end

@implementation OGPhysicsComponent

- (instancetype)initWithPhysicsBody:(SKPhysicsBody *)body colliderType:(struct OGColliderType)type
{
    if (body)
    {
        self = [super init];
        
        if (self)
        {
            _physicsBody = body;
            
            _physicsBody.categoryBitMask = type.categoryBitMask;
            _physicsBody.collisionBitMask = type.collisionBitMask;
            _physicsBody.contactTestBitMask = type.contactTestBitMask;
            _physicsBody.angularDamping = type.angularDamping;
            _physicsBody.linearDamping = type.linearDamping;
            _physicsBody.restitution = type.restitution;
            _physicsBody.friction = type.friction;
        }
    }
    
    return self;
}

@end