//
//  OGMovement.m
//  Olvido
//
//  Created by Александр Песоцкий on 10/16/16.
//  Copyright © 2016 Дмитрий Антипенко. All rights reserved.
//

#import "OGMovementComponent.h"
#import "OGRenderComponent.h"
#import "OGAnimationComponent.h"
#import "OGOrientationComponent.h"

#import "OGConstants.h"

#import "OGAnimation.h"

CGFloat const kOGMovementComponentDefaultSpeedFactor = 1.0;
CGFloat const kOGMovementComponentDefaultSpeed = 5.0;

@interface OGMovementComponent ()

@property (nonatomic, strong) OGRenderComponent *renderComponent;
@property (nonatomic, strong) OGAnimationComponent *animationComponent;
@property (nonatomic, strong) OGOrientationComponent *orientationComponent;

@end

@implementation OGMovementComponent

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        _speedFactor = kOGMovementComponentDefaultSpeedFactor;
    }
    
    return self;
}

- (void)updateWithDeltaTime:(NSTimeInterval)seconds
{
    [super updateWithDeltaTime:seconds];
    
    if ([self animationStateCanBeOverwrittenWithAnimationState:self.animationComponent.currentAnimation.animationState])
    {
        if (self.displacementVector.dx != 0)
        {
            OGDirection direction = [OGOrientationComponent directionWithVectorX:self.displacementVector.dx];
            if (self.orientationComponent.direction != direction
                || self.animationComponent.currentAnimation.animationState != kOGAnimationStateWalkForward)
            {
                self.orientationComponent.direction = direction;
        
                self.animationComponent.requestedAnimationState = kOGAnimationStateWalkForward;
            }
        }
        else if (self.displacementVector.dx == 0 && self.displacementVector.dy == 0)
        {
            self.animationComponent.requestedAnimationState = kOGAnimationStateIdle;
        }
    }
    
    CGPoint oldPosition = self.renderComponent.node.position;
    CGPoint newPosition = CGPointMake(oldPosition.x + self.displacementVector.dx * self.speedFactor * kOGMovementComponentDefaultSpeed,
                                      oldPosition.y + self.displacementVector.dy * self.speedFactor * kOGMovementComponentDefaultSpeed);
    
    self.renderComponent.node.position = newPosition;
}

- (BOOL)animationStateCanBeOverwrittenWithAnimationState:(OGAnimationState)animationState
{
    BOOL result = NO;
    
    if (animationState == kOGAnimationStateNone || animationState == kOGAnimationStateIdle
        || animationState == kOGAnimationStateAttack || animationState == kOGAnimationStateWalkForward)
    {
        result = YES;
    }
    
    return result;
}

- (OGRenderComponent *)renderComponent
{
    if (!_renderComponent)
    {
        _renderComponent = (OGRenderComponent *) [self.entity componentForClass:[OGRenderComponent class]];
    }
    
    return _renderComponent;
}

- (OGAnimationComponent *)animationComponent
{
    if (!_animationComponent)
    {
        _animationComponent = (OGAnimationComponent *) [self.entity componentForClass:[OGAnimationComponent class]];
    }
    
    return _animationComponent;
}

- (OGOrientationComponent *)orientationComponent
{
    if (!_orientationComponent)
    {
        _orientationComponent = (OGOrientationComponent *) [self.entity componentForClass:[OGOrientationComponent class]];
    }
    
    return _orientationComponent;
}

@end
