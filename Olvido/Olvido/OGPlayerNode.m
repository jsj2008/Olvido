//
//  OGPlayer.m
//  Olvido
//
//  Created by Александр Песоцкий on 10/6/16.
//  Copyright © 2016 Дмитрий Антипенко. All rights reserved.
//

#import "OGPlayerNode.h"
#import "SKColor+OGConstantColors.h"

CGFloat const kOGPlayerNodeBorderLineWidth = 4.0;
CGFloat const kOGPlayerNodeInvulnerabilityRepeatCount = 4.0;
CGFloat const kOGPlayerNodeInvulnerabilityBlinkingTimeDuration = 0.2;

@implementation OGPlayerNode

+ (instancetype)playerNodeWithColor:(SKColor *)color
{
    OGPlayerNode *playerNode = [[OGPlayerNode alloc] initWithColor:color];
    
    if (playerNode)
    {
        playerNode.appearance = [SKSpriteNode spriteNodeWithImageNamed:@"PlayerBall"];
        playerNode.appearance.size = CGSizeMake(playerNode.radius * 2.0, playerNode.radius * 2.0);
        playerNode.appearance.color = [SKColor blackColor];
        playerNode.appearance.colorBlendFactor = 1.0;
        [playerNode addChild:playerNode.appearance];
        
        playerNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:kOGBasicGameNodeRadius];
        playerNode.physicsBody.dynamic = YES;
        playerNode.physicsBody.linearDamping = 0.0;
        playerNode.physicsBody.angularDamping = 0.0;
        
        playerNode.physicsBody.friction = 0.0;
        playerNode.physicsBody.restitution = 1.0;
        
        playerNode.physicsBody.categoryBitMask = 0x1 << 1;
        playerNode.physicsBody.collisionBitMask = 0x1 << 0;
        playerNode.physicsBody.contactTestBitMask = 0x1 << 0;
        
        playerNode.physicsBody.usesPreciseCollisionDetection = YES;
        
        SKAction *invulnerability = [SKAction waitForDuration:kOGPlayerNodeInvulnerabilityRepeatCount * kOGPlayerNodeInvulnerabilityBlinkingTimeDuration * 2.0];
        
        [playerNode runAction:invulnerability completion:^
         {
             playerNode.physicsBody.contactTestBitMask = playerNode.physicsBody.contactTestBitMask | 0x1 << 2;
         }];
    }
    
    return  [playerNode autorelease];
}

- (void)setColor:(SKColor *)color
{
    self.appearance.color = color;
}


@end
