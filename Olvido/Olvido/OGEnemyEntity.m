//
//  OGEnemyEntity.m
//  Olvido
//
//  Created by Дмитрий Антипенко on 11/6/16.
//  Copyright © 2016 Дмитрий Антипенко. All rights reserved.
//

#import "OGEnemyEntity.h"
#import "OGEnemyConfiguration.h"
#import "OGRenderComponent.h"
#import "OGIntelligenceComponent.h"
#import "OGMovementComponent.h"
#import "OGAnimationComponent.h"
#import "OGPhysicsComponent.h"
#import "OGAttacking.h"
#import "OGEnemyBehavior.h"
#import "OGOrientationComponent.h"
#import "OGEnemyEntityAgentControlledState.h"

#import <objc/runtime.h>

CGFloat const kOGEnemyEntityPathfindingGraphBufferRadius = 30.0;
NSTimeInterval const kOGEnemyEntityMaxPredictionTimeForObstacleAvoidance = 1.0;

NSString *const kOGEnemyEntityAtlasNamesEnemyIdle = @"EnemyIdle";
NSString *const kOGEnemyEntityAtlasNamesEnemyWalk = @"EnemyWalk";
CGFloat const kOGEnemyEntityPatrolPathRadius = 10.0;
CGFloat const kOGEnemyEntityMaximumSpeed = 300;
CGFloat const kOGEnemyEntityMaximumAcceleration = 50;
CGFloat const kOGEnemyEntityAgentMass = 0.25;
NSTimeInterval const kOGEnemyEntityBehaviorUpdateWaitDuration = 0.25;
CGFloat const kOGEnemyEntityThresholdProximityToPatrolPathStartPoint = 50.0;

static NSDictionary<NSString *, NSDictionary *> *sOGEnemyEntityAnimations;

@interface OGEnemyEntity ()

@property (nonatomic, strong) GKBehavior *behaviorForCurrentMandate;

@property (nonatomic, assign, readonly) CGSize textureSize;
@property (nonatomic, assign, readonly) CGPoint agentOffset;

@property (nonatomic, assign) CGFloat lastPositionX;
@end

@implementation OGEnemyEntity

- (instancetype)init
{
    return [self initWithConfiguration:nil graph:nil];
}


- (instancetype)initWithConfiguration:(OGEnemyConfiguration *)configuration
                                graph:(GKGraph *)graph
{
    self = [super init];
    
    if (self)
    {
        _graph = graph;
        
        CGPoint position = CGPointMake(((GKGraphNode2D *) [graph nodes][0]).position.x, ((GKGraphNode2D *) [graph nodes][0]).position.y);
        
        _renderComponent = [[OGRenderComponent alloc] init];
        
        _renderComponent.node.position = position;
        
        [self addComponent:_renderComponent];

        _physicsComponent = [[OGPhysicsComponent alloc] initWithPhysicsBody:[SKPhysicsBody bodyWithCircleOfRadius:configuration.physicsBodyRadius]
                                                               colliderType:[OGColliderType enemy]];
        [self addComponent:_physicsComponent];
        
        _orientationComponent = [[OGOrientationComponent alloc] init];
        [self addComponent:_orientationComponent];
        
        _mandate = kOGEnemyEntityMandateFollowPath;
        
        _renderComponent.node.physicsBody = _physicsComponent.physicsBody;
        _renderComponent.node.physicsBody.allowsRotation = NO;
        
        _agent = [[GKAgent2D alloc] init];
        _agent.delegate = self;
        
        _agent.position = (vector_float2){_renderComponent.node.position.x, _renderComponent.node.position.y};
        _agent.maxSpeed = kOGEnemyEntityMaximumSpeed;
        _agent.maxAcceleration = kOGEnemyEntityMaximumAcceleration;
        _agent.mass = kOGEnemyEntityAgentMass;
        _agent.radius = configuration.physicsBodyRadius;
        _agent.behavior = [[GKBehavior alloc] init];
        [self addComponent:_agent];
        
        OGEnemyEntityAgentControlledState *controlledState = [[OGEnemyEntityAgentControlledState alloc] initWithEnemyEntity:self];

        _intelligenceComponent = [[OGIntelligenceComponent alloc] initWithStates:@[controlledState]];
        [self addComponent:_intelligenceComponent];

        _animationComponent = [[OGAnimationComponent alloc] initWithTextureSize:[self textureSize] animations:[OGEnemyEntity sOGEnemyEntityAnimations]];
        [self addComponent:_animationComponent];

        [_renderComponent.node addChild:_animationComponent.spriteNode];
        
        _lastPositionX = _renderComponent.node.position.x;
    }
    
    return self;
}

- (void)agentWillUpdate:(GKAgent *)agent
{
    [self updateAgentPositionToMatchNodePosition];
}

- (void)agentDidUpdate:(GKAgent *)agent
{
    if (self.intelligenceComponent && self.orientationComponent)
    {
        if ([self.intelligenceComponent.stateMachine.currentState isMemberOfClass:OGEnemyEntityAgentControlledState.self])
        {
            self.animationComponent.requestedAnimationState = kOGAnimationStateWalkForward;
            [self updateNodePositionToMatchAgentPosition];
        }
        else
        {
            [self updateAgentPositionToMatchNodePosition];
        }
        
        if (_renderComponent.node.position.x != self.lastPositionX)
        {
            CGFloat differenceX = self.lastPositionX - _renderComponent.node.position.x;
            self.orientationComponent.direction = [OGOrientationComponent directionWithVectorX:differenceX];
            
            self.lastPositionX = _renderComponent.node.position.x;
        }
    }
}

- (void)updateAgentPositionToMatchNodePosition
{
    OGRenderComponent *renderComponent = self.renderComponent;
    self.agent.position = (vector_float2){renderComponent.node.position.x + self.agentOffset.x, renderComponent.node.position.y + self.agentOffset.y};
}

- (void)updateNodePositionToMatchAgentPosition
{
    GKAgent2D *agent = self.agent;
    self.renderComponent.node.position = CGPointMake(agent.position.x - self.agentOffset.x, agent.position.y - self.agentOffset.y);
}

- (void)contactWithEntityDidBegin:(GKEntity *)entity
{
    
}

+ (BOOL)resourcesNeedLoading
{
    return sOGEnemyEntityAnimations == nil;
}

+ (void)loadResourcesWithCompletionHandler:(void (^)())completionHandler
{
    [OGEnemyEntity loadMiscellaneousAssets];
    
    NSArray *enemyAtlasNames = @[kOGEnemyEntityAtlasNamesEnemyIdle,
                                 kOGEnemyEntityAtlasNamesEnemyWalk];
    
    [SKTextureAtlas preloadTextureAtlasesNamed:enemyAtlasNames withCompletionHandler:^(NSError *error, NSArray<SKTextureAtlas *> *foundAtlases)
    {
        NSMutableDictionary *animations = [NSMutableDictionary dictionary];
        
        animations[kOGAnimationStateDescription[kOGAnimationStateIdle]] = [OGAnimationComponent animationsWithAtlas:foundAtlases[0]
                                                                                                    imageIdentifier:kOGEnemyEntityAtlasNamesEnemyIdle
                                                                                                     animationState:kOGAnimationStateIdle
                                                                                                     bodyActionName:nil
                                                                                              repeatTexturesForever:YES
                                                                                                      playBackwards:NO];
        
        animations[kOGAnimationStateDescription[kOGAnimationStateWalkForward]] = [OGAnimationComponent animationsWithAtlas:foundAtlases[1]
                                                                                                           imageIdentifier:kOGEnemyEntityAtlasNamesEnemyWalk
                                                                                                            animationState:kOGAnimationStateWalkForward
                                                                                                            bodyActionName:nil
                                                                                                     repeatTexturesForever:YES
                                                                                                             playBackwards:NO];
        
        sOGEnemyEntityAnimations = animations;
        
        completionHandler();
    }];
}

+ (void)purgeResources
{
    sOGEnemyEntityAnimations = nil;
}

+ (void)loadMiscellaneousAssets
{
    NSArray *collisionColliders = [NSArray arrayWithObject:[OGColliderType obstacle]];
    [[OGColliderType definedCollisions] setObject:collisionColliders forKey:[OGColliderType enemy]];

    NSArray *contactColliders = [NSArray arrayWithObject:[OGColliderType player]];
    [[OGColliderType requestedContactNotifications] setObject:contactColliders forKey:[OGColliderType enemy]];
}

+ (NSDictionary *)sOGEnemyEntityAnimations
{
    return sOGEnemyEntityAnimations;
}

- (GKBehavior *)behaviorForCurrentMandate
{
    GKBehavior *result = nil;
    
    SKScene *scene = ((OGRenderComponent *) [self componentForClass:OGRenderComponent.self]).node.scene;
    
    if (!scene)
    {
        result = [[GKBehavior alloc] init];
    }
    else{
    
        switch (self.mandate) {
            case kOGEnemyEntityMandateFollowPath:
            {
                result = [OGEnemyBehavior behaviorWithAgent:self.agent
                                                      graph:self.graph
                                                 pathRadius:kOGEnemyEntityPatrolPathRadius
                                                      scene:(OGGameScene *)scene];
                break;
            }
            case kOGEnemyEntityMandateHunt:
            {
//                result = [OGEnemyBehavior behaviorWithAgent:self.agent
//                                               huntingAgent:<#(GKAgent2D *)#>
//                                                 pathRadius:kOGEnemyEntityPatrolPathRadius
//                                                      scene:self];
                break;
            }
            case kOGEnemyEntityMandateAttack:
            {
                break;
            }
            case kOGEnemyEntityMandateReturnToPositionOnPath:
            {
                CGPoint closestPoint = [self closestPointOnPathWithGraph:self.graph];
                result = [OGEnemyBehavior behaviorWithAgent:self.agent
                                                   endPoint:closestPoint
                                                 pathRadius:kOGEnemyEntityPatrolPathRadius
                                                      scene:(OGGameScene *)scene];
                break;
            }
            default:
                break;
        }
    
    }
    
    return result;
}

- (CGPoint)closestPointOnPathWithGraph:(GKGraph *)graph
{
    CGPoint enemyPosition = CGPointMake(self.agent.position.x, self.agent.position.y);
    
    NSUInteger nodesCounter = [graph.nodes count];
    
    CGPoint result = ((SKNode *)graph.nodes[0]).position;
    
    for (NSUInteger i = 0; i < nodesCounter; i++)
    {
        if (i != nodesCounter)
        {
            CGFloat distance = [self distanceBetweenStartPoint:enemyPosition endPoint:result];
            CGFloat nextDistance = [self distanceBetweenStartPoint:enemyPosition endPoint:((SKNode *)graph.nodes[i+1]).position];
            
            result = (distance < nextDistance) ? result : ((SKNode *)graph.nodes[i+1]).position;
        }
    }
    
    return result;
}

- (CGFloat)closestDistanceToAgentWithGraph:(GKGraph *)graph
{
    CGPoint enemyPosition = CGPointMake(self.agent.position.x, self.agent.position.y);
    
    NSUInteger nodesCounter = [graph.nodes count];
    
    CGFloat result = [self distanceBetweenStartPoint:enemyPosition endPoint:((SKNode *)graph.nodes[0]).position];
    
    for (NSUInteger i = 0; i < nodesCounter; i++)
    {
        if (i != nodesCounter)
        {
            CGFloat nextDistance = [self distanceBetweenStartPoint:enemyPosition endPoint:((SKNode *)graph.nodes[i+1]).position];
            
            result = (result < nextDistance) ? result : nextDistance;
        }
    }

    return result;
}

- (CGFloat)distanceToAgentWithOtherAgent:(GKAgent2D *)otherAgent
{
    CGPoint agentPosition = CGPointMake(self.agent.position.x, self.agent.position.y);
    CGPoint otherAgentPosition = CGPointMake(otherAgent.position.x, otherAgent.position.y);
    
    return [self distanceBetweenStartPoint:agentPosition endPoint:otherAgentPosition];
}

- (CGFloat)distanceBetweenStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint
{
    CGFloat deltaX = startPoint.x - endPoint.x;
    CGFloat deltaY = startPoint.y - endPoint.y;
    
    return hypot(deltaX, deltaY);
}

- (CGSize)textureSize
{
    return CGSizeMake(80.0, 100.0);
}

- (CGPoint)agentOffset
{
    return CGPointMake(0.0, -25.0);
}

@end
