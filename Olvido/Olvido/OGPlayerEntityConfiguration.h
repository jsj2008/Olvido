//
//  OGPlayerEntityConfiguration.h
//  Olvido
//
//  Created by Дмитрий Антипенко on 11/4/16.
//  Copyright © 2016 Дмитрий Антипенко. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "OGColliderType.h"

@interface OGPlayerEntityConfiguration : NSObject 

@property (nonatomic, assign, readonly) NSUInteger maxHealth;
@property (nonatomic, assign, readonly) NSUInteger currentHealth;
@property (nonatomic, assign, readonly) struct OGColliderType colliderType;
@property (nonatomic, assign, readonly) CGFloat physicsBodyRadius;

@end

