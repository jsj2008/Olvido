//
//  OGGameScene.m
//  Olvido
//
//  Created by Дмитрий Антипенко on 10/26/16.
//  Copyright © 2016 Дмитрий Антипенко. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

//MARK: Miscelaneous

#import "OGAudioManager.h"
#import "OGGameScene.h"
#import "OGCollisionBitMask.h"
#import "OGTouchControlInputNode.h"
#import "OGConstants.h"
#import "OGZPositionEnum.m"
#import "OGGameSceneConfiguration.h"
#import "OGEnemyConfiguration.h"
#import "OGCameraController.h"
#import "OGContactNotifiableType.h"
#import "OGLevelManager.h"
#import "OGZPositionEnum.m"
#import "OGLevelStateSnapshot.h"
#import "OGEntitySnapshot.h"

//MARK: Components

#import "OGInputComponent.h"
#import "OGRenderComponent.h"
#import "OGLockComponent.h"
#import "OGPhysicsComponent.h"
#import "OGMovementComponent.h"
#import "OGIntelligenceComponent.h"
#import "OGAnimationComponent.h"
#import "OGMessageComponent.h"
#import "OGTransitionComponent.h"
#import "OGWeaponComponent.h"
#import "OGInventoryComponent.h"
#import "OGTrailComponent.h"
#import "OGRulesComponent.h"
#import "OGShadowComponent.h"

//MARK: Entities

#import "OGPlayerEntity.h"
#import "OGZombie.h"
#import "OGEnemyEntity.h"
#import "OGDoorEntity.h"
#import "OGWeaponEntity.h"
#import "OGSpriteZoneEntity.h"
#import "OGHiddenZoneEntity.h"
#import "OGParticlesZoneEntity.h"
#import "OGShootingWeapon.h"
#import "OGKey.h"

//MARK: Nodes

#import "OGInventoryBarNode.h"
#import "OGWeaponStatisticsNode.h"
#import "OGButtonNode.h"
#import "OGHUDNode.h"

//MARK: States

#import "OGBeforeStartLevelState.h"
#import "OGStoryConclusionLevelState.h"
#import "OGGameLevelState.h"
#import "OGPauseLevelState.h"
#import "OGCompleteLevelState.h"
#import "OGDeathLevelState.h"

//MARK: Constants

NSString *const OGGameSceneDoorsNodeName = @"doors";
NSString *const OGGameSceneItemsNodeName = @"items";
NSString *const OGGameSceneWeaponNodeName = @"weapon";
NSString *const OGGameSceneKeysNodeName = @"keys";
NSString *const OGGameSceneSourceNodeName = @"source";
NSString *const OGGameSceneDestinationNodeName = @"destination";
NSString *const OGGameSceneUserDataGraphs = @"Graphs";
NSString *const OGGameSceneUserDataGraph = @"Graph_";
NSString *const OGGameSceneDoorLockedKey = @"locked";
NSString *const OGGameSceneAttackSpeedKey = @"attackSpeed";
NSString *const OGGameSceneReloadSpeedKey = @"reloadSpeed";
NSString *const OGGameSceneChargeKey = @"charge";

NSString *const OGGameScenePlayerInitialPointNodeName = @"player_initial_point";

NSString *const OGGameSceneDoorKeyPrefix = @"key";

NSString *const OGGameScenePauseScreenNodeName = @"OGPauseScreen.sks";
NSString *const OGGameSceneGameOverScreenNodeName = @"OGGameOverScreen.sks";

NSString *const OGGameScenePlayerInitialPoint = @"player_initial_point";
NSString *const OGGameSceneEnemyInitialsPoints = @"enemy_initial_point";
NSString *const OGGameSceneObstacleName = @"obstacle";

NSString *const OGGameSceneResumeButtonName = @"ResumeButton";
NSString *const OGGameSceneRestartButtonName = @"RestartButton";
NSString *const OGGameSceneMenuButtonName = @"MenuButton";
NSString *const OGGameScenePauseButtonName = @"PauseButton";

CGFloat const OGGameScenePauseSpeed = 0.0;
CGFloat const OGGameScenePlaySpeed = 1.0;

CGFloat const OGGameSceneDoorOpenDistance = 50.0;

NSUInteger const OGGameSceneZSpacePerCharacter = 30;

@interface OGGameScene () <AVAudioPlayerDelegate>

@property (nonatomic, strong) NSMutableArray<GKEntity *> *entitiesSortableByZ;
@property (nonatomic, strong) SKNode *currentRoom;
@property (nonatomic, strong) OGCameraController *cameraController;
@property (nonatomic, weak) OGPlayerEntity *player;
@property (nonatomic, strong) OGGameSceneConfiguration *sceneConfiguration;

@property (nonatomic, strong) SKReferenceNode *pauseScreenNode;
@property (nonatomic, strong) SKReferenceNode *gameOverScreenNode;

@property (nonatomic, strong) OGHUDNode *hudNode;
@property (nonatomic, strong) OGInventoryBarNode *inventoryBarNode;
@property (nonatomic, strong) OGWeaponStatisticsNode *weaponStatisticsNode;
@property (nonatomic, strong) OGTouchControlInputNode *controllInputNode;

@property (nonatomic, assign) CGFloat lastUpdateTimeInterval;
@property (nonatomic, assign) NSTimeInterval pausedTimeInterval;

@property (nonatomic, strong) NSMutableOrderedSet<GKEntity *> *mutableEntities;

@property (nonatomic, strong) NSMutableArray<GKComponentSystem *> *componentSystems;

@property (nonatomic, strong) OGLevelStateSnapshot *levelSnapshot;

@end

@implementation OGGameScene

@synthesize name = _name;

#pragma mark - Initializer

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        _entitiesSortableByZ = [[NSMutableArray alloc] init];
        
        _sceneConfiguration = [OGGameSceneConfiguration gameSceneConfigurationWithFileName:_name];
        
        _cameraController = [[OGCameraController alloc] init];
        
        _stateMachine = [[GKStateMachine alloc] initWithStates:@[
                                                                 [OGStoryConclusionLevelState stateWithLevelScene:self],
                                                                 [OGBeforeStartLevelState stateWithLevelScene:self],
                                                                 [OGGameLevelState stateWithLevelScene:self],
                                                                 [OGPauseLevelState stateWithLevelScene:self],
                                                                 [OGCompleteLevelState stateWithLevelScene:self],
                                                                 [OGDeathLevelState stateWithLevelScene:self]
                                                                 ]];
        
        _mutableEntities = [[NSMutableOrderedSet alloc] init];
        
        _componentSystems = [[NSMutableArray alloc] initWithObjects:
                             [[GKComponentSystem alloc] initWithComponentClass:[GKAgent2D class]],
                             [[GKComponentSystem alloc] initWithComponentClass:[OGAnimationComponent class]],
                             [[GKComponentSystem alloc] initWithComponentClass:[OGMovementComponent class]],
                             [[GKComponentSystem alloc] initWithComponentClass:[OGIntelligenceComponent class]],
                             [[GKComponentSystem alloc] initWithComponentClass:[OGLockComponent class]],
                             [[GKComponentSystem alloc] initWithComponentClass:[OGMessageComponent class]],
                             [[GKComponentSystem alloc] initWithComponentClass:[OGWeaponComponent class]],
                             [[GKComponentSystem alloc] initWithComponentClass:[OGTrailComponent class]],
                             [[GKComponentSystem alloc] initWithComponentClass:[OGRulesComponent class]],
                             nil];
        
        _pauseScreenNode = [[SKReferenceNode alloc] initWithFileNamed:OGGameScenePauseScreenNodeName];
        _pauseScreenNode.zPosition = OGZPositionCategoryTouchControl;
        
        _gameOverScreenNode = [[SKReferenceNode alloc] initWithFileNamed:OGGameSceneGameOverScreenNodeName];
        _gameOverScreenNode.zPosition = OGZPositionCategoryTouchControl;
    }
    
    return self;
}

#pragma mark - Scene contents

- (void)didMoveToView:(SKView *)view
{
    [super didMoveToView:view];
    
    self.physicsWorld.contactDelegate = self;
    
    [self.obstaclesGraph addObstacles:self.polygonObstacles];
    
    self.currentRoom = [self childNodeWithName:self.sceneConfiguration.startRoom];
    [self createSceneContents];
    
    [self createCameraNode];
    [self createTouchControlInputNode];
    
    [self.stateMachine enterState:[OGGameLevelState class]];
    
    [self.audioManager playMusic:self.sceneConfiguration.backgroundMusic];
    self.audioManager.musicPlayerDelegate = self;
    
    [self.cameraController moveCameraToNode:self.currentRoom];
    
    [self createHUD];
}

#pragma mark - Scene Contents Creation

- (void)createSceneContents
{
    [self createPlayer];
    [self createEnemies];
    [self createDoors];
    [self createSceneItems];
//    [self createZones];
}

- (void)createZones
{
   
    
/*
 *__________________ZONE CREATION EXAMPLE________________
 * !!!!!This example needs SKSPriteNode with name "Zone_0" on scene!!!!!
 */
    
    
//    SKSpriteNode *zoneNode = nil;
//    
//    NSString *zoneName = @"Zone_0";
//    zoneNode = (SKSpriteNode *)[self childNodeWithName:zoneName];
//    
//    SKEmitterNode *emitter = [SKEmitterNode nodeWithFileNamed:@"SlimeZoneParticleSystem"];
//    
//    OGHiddenZoneEntity *zoneEntity = [[OGParticlesZoneEntity alloc] initWithSpriteNode:zoneNode
//                                                                     affectedColliders:@[]
//                                                                 interactionBeginBlock:^(GKEntity *entity)
//                                      {
//                                          OGMovementComponent *movementComponent = (OGMovementComponent *)[entity componentForClass:[OGMovementComponent class]];
//                                          
//                                          if (movementComponent)
//                                          {
//                                              movementComponent.speedFactor = 0.5;
//                                          }
//                                      }
//                                                                   interactionEndBlock:^(GKEntity *entity)
//                                      {
//                                          OGMovementComponent *movementComponent = (OGMovementComponent *)[entity componentForClass:[OGMovementComponent class]];
//                                          
//                                          if (movementComponent)
//                                          {
//                                              movementComponent.speedFactor = 1.0;
//                                          }
//                                          
//                                      } emitter:emitter];
//    
//    
//    [self addEntity:zoneEntity];
}

- (void)createTouchControlInputNode
{
    OGTouchControlInputNode *inputNode = [[OGTouchControlInputNode alloc] initWithFrame:self.frame thumbStickNodeSize:[OGConstants thumbStickNodeSize]];
    inputNode.size = self.size;
    self.controllInputNode = inputNode;
    self.controllInputNode.zPosition = OGZPositionCategoryTouchControl;
    
    OGInputComponent *inputComponent = (OGInputComponent *) [self.player componentForClass:[OGInputComponent class]];
    inputNode.inputSourceDelegate = (id<OGControlInputSourceDelegate>) inputComponent;
    inputNode.position = CGPointZero;
    [self.camera addChild:inputNode];
}

- (void)createCameraNode
{
    SKCameraNode *camera = [[SKCameraNode alloc] init];
    self.camera = camera;
    self.camera.zPosition = OGZPositionCategoryForeground;
    self.cameraController.camera = camera;
    [self addChild:camera];
    
    self.cameraController.target = self.player.renderComponent.node;
}

- (void)createPlayer
{
    OGPlayerEntity *player = [[OGPlayerEntity alloc] initWithConfiguration:self.sceneConfiguration.playerConfiguration];
    player.delegate = self;
    self.player = player;
    
    [self addEntity:self.player];
    
    self.listener = self.player.renderComponent.node;
    
    SKNode *playerInitialNode = [self childNodeWithName:OGGameScenePlayerInitialPointNodeName];
    self.player.renderComponent.node.position = playerInitialNode.position;
}

- (void)createEnemies
{
    NSUInteger counter = 0;
    
    for (OGEnemyConfiguration *enemyConfiguration in self.sceneConfiguration.enemiesConfiguration)
    {
        NSString *graphName = [NSString stringWithFormat:@"%@%lu", OGGameSceneUserDataGraph, (unsigned long) counter];
        GKGraph *graph = self.userData[OGGameSceneUserDataGraphs][graphName];
        
        OGEnemyEntity *enemy = [[enemyConfiguration.enemyClass alloc] initWithConfiguration:enemyConfiguration graph:graph];
        enemy.delegate = self;
        
        if ([enemy isMemberOfClass:[OGZombie class]])
        {
            OGTrailComponent *trailComponent = (OGTrailComponent *) [enemy componentForClass:[OGTrailComponent class]];
            trailComponent.targetNode = self;
        }
        
        [self addEntity:enemy];
        
        counter++;
    }
}

- (void)createDoors
{
    NSArray<SKNode *> *doorNodes = [self childNodeWithName:OGGameSceneDoorsNodeName].children;
    
    for (SKNode *doorNode in doorNodes)
    {
        if ([doorNode isKindOfClass:[SKSpriteNode class]])
        {
            OGDoorEntity *door = [[OGDoorEntity alloc] initWithSpriteNode:(SKSpriteNode *) doorNode];
            OGLockComponent *lockComponent = (OGLockComponent *) [door componentForClass:[OGLockComponent class]];
            OGTransitionComponent *transitionComponent = (OGTransitionComponent *) [door componentForClass:[OGTransitionComponent class]];
            
            door.transitionDelegate = self;
            
            BOOL doorLocked = [doorNode.userData[OGGameSceneDoorLockedKey] boolValue];
            
            lockComponent.target = self.player.renderComponent.node;
            lockComponent.openDistance = OGGameSceneDoorOpenDistance;
            lockComponent.locked = doorLocked;
            
            NSString *sourceNodeName = doorNode.userData[OGGameSceneSourceNodeName];
            NSString *destinationNodeName = doorNode.userData[OGGameSceneDestinationNodeName];
            
            transitionComponent.destination = destinationNodeName ? [self childNodeWithName:destinationNodeName] : nil;
            transitionComponent.source = sourceNodeName ? [self childNodeWithName:sourceNodeName] : nil;
            
            for (NSString *key in doorNode.userData.allKeys)
            {
                if ([key hasPrefix:OGGameSceneDoorKeyPrefix])
                {
                    [door addKeyName:doorNode.userData[key]];
                }
            }
            
            [self addEntity:door];
        }
    }
}

- (void)createSceneItems
{
    SKNode *items = [self childNodeWithName:OGGameSceneItemsNodeName];
    NSArray *weapons = [items childNodeWithName:OGGameSceneWeaponNodeName].children;
    NSArray *keys = [items childNodeWithName:OGGameSceneKeysNodeName].children;
    
    for (SKSpriteNode *weaponSprite in weapons)
    {
        CGFloat attackSpeed = [weaponSprite.userData[OGGameSceneAttackSpeedKey] floatValue];
        CGFloat reloadSpeed = [weaponSprite.userData[OGGameSceneReloadSpeedKey] floatValue];
        NSUInteger charge = [weaponSprite.userData[OGGameSceneChargeKey] integerValue];
        
        OGShootingWeapon *shootingWeapon = [[OGShootingWeapon alloc] initWithSpriteNode:weaponSprite
                                                                            attackSpeed:attackSpeed
                                                                            reloadSpeed:reloadSpeed
                                                                                 charge:charge];
        shootingWeapon.delegate = self;
        [self addEntity:shootingWeapon];
    }
    
    for (SKSpriteNode *keySprite in keys)
    {
        OGKey *key = [[OGKey alloc] initWithSpriteNode:keySprite];
        [self addEntity:key];
    }
}

#pragma mark HUD creation

- (void)createHUD
{
    self.hudNode = [OGHUDNode node];
    self.hudNode.size = self.size;
    
    if (self.camera)
    {
        [self.camera addChild:self.hudNode];
    }
    
    [self createInventoryBar];
    [self createWeaponStatistics];
}

- (void)createWeaponStatistics
{
    self.weaponStatisticsNode = [[OGWeaponStatisticsNode alloc] init];
    
    if (self.weaponStatisticsNode)
    {
        OGWeaponComponent *weaponComponent = (OGWeaponComponent *) [self.player componentForClass:[OGWeaponComponent class]];
        weaponComponent.weaponObserver = self.weaponStatisticsNode;
        [self.hudNode addHUDElement:self.weaponStatisticsNode];
    }
}

- (void)createInventoryBar
{
    OGInventoryComponent *inventoryComponent = (OGInventoryComponent *) [self.player componentForClass:[OGInventoryComponent class]];
    self.inventoryBarNode = [OGInventoryBarNode inventoryBarNodeWithInventoryComponent:inventoryComponent screenSize:self.camera.calculateAccumulatedFrame.size];
    //self.inventoryBarNode.playerEntity = self.player;
    
    if (self.hudNode)
    {
        [self.hudNode addHUDElement:self.inventoryBarNode];
    }
    
    [self.inventoryBarNode updateConstraints];
}

#pragma mark - Entity Adding

- (void)addEntity:(GKEntity *)entity
{
    [self.mutableEntities addObject:entity];
    
    for (GKComponentSystem *componentSystem in self.componentSystems)
    {
        [componentSystem addComponentWithEntity:entity];
    }
    
    OGRenderComponent *renderComponent = (OGRenderComponent *)[entity componentForClass:[OGRenderComponent class]];
    
    if(renderComponent)
    {
        if (renderComponent.isSortableByZ)
        {
            [self.entitiesSortableByZ addObject:entity];
        }
        
        SKNode *renderNode = renderComponent.node;
        
        if (renderNode && !renderNode.parent)
        {
            [self addChild:renderNode];
            
            SKNode *shadowNode = ((OGShadowComponent *) [entity componentForClass:[OGShadowComponent class]]).node;
            
            if (shadowNode)
            {
                shadowNode.zPosition = OGZPositionCategoryShadows;
            }
        }
    }
    
    OGIntelligenceComponent *intelligenceComponent = (OGIntelligenceComponent *) [entity componentForClass:[OGIntelligenceComponent class]];
    
    if (intelligenceComponent)
    {
        [intelligenceComponent enterInitialState];
    }
}

- (void)removeEntity:(GKEntity *)entity
{
    OGRenderComponent *renderComponent = (OGRenderComponent *) [entity componentForClass:[OGRenderComponent class]];
    
    if (renderComponent)
    {
        if (renderComponent.isSortableByZ)
        {
            [self.entitiesSortableByZ removeObject:entity];
        }
        
        SKNode *node = renderComponent.node;
        [node removeFromParent];
    }
    
    for (GKComponentSystem *componentSystem in self.componentSystems)
    {
        [componentSystem removeComponentWithEntity:entity];
    }
    
    [self.mutableEntities removeObject:entity];
}

- (void)playerDidDie
{
    [self.stateMachine enterState:[OGDeathLevelState class]];
}

#pragma mark - TransitionComponentDelegate

- (void)transitToDestinationWithTransitionComponent:(OGTransitionComponent *)component completion:(void (^)(void))completion
{
    self.currentRoom = component.destination;
    
    [self.cameraController moveCameraToNode:self.currentRoom];
    
    completion();
}

#pragma mark - Audio Player Delegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (flag)
    {
        [player play];
    }
}

#pragma mark - Contact handling

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    [self handleContact:contact contactCallback:^(id<OGContactNotifiableType> notifiable, GKEntity *entity)
     {
         [notifiable contactWithEntityDidBegin:entity];
     }];
}

- (void)didEndContact:(SKPhysicsContact *)contact
{
    [self handleContact:contact contactCallback:^(id<OGContactNotifiableType> notifiable, GKEntity *entity)
     {
         [notifiable contactWithEntityDidEnd:entity];
     }];
}

- (void)handleContact:(SKPhysicsContact *)contact contactCallback:(void (^)(id<OGContactNotifiableType>, GKEntity *))callback
{
    SKPhysicsBody *bodyA = contact.bodyA.node.physicsBody;
    SKPhysicsBody *bodyB = contact.bodyB.node.physicsBody;
    
    GKEntity *entityA = bodyA.node.entity;
    GKEntity *entityB = bodyB.node.entity;
    
    OGColliderType *colliderTypeA = [OGColliderType existingColliderTypeWithCategoryBitMask:bodyA.categoryBitMask];
    OGColliderType *colliderTypeB = [OGColliderType existingColliderTypeWithCategoryBitMask:bodyB.categoryBitMask];
    
    BOOL aNeedsCallback = [colliderTypeA notifyOnContactWith:colliderTypeB];
    BOOL bNeedsCallback = [colliderTypeB notifyOnContactWith:colliderTypeA];
    
    if ([entityA conformsToProtocol:@protocol(OGContactNotifiableType)] && aNeedsCallback)
    {
        callback((id<OGContactNotifiableType>) entityA, entityB);
    }
    
    if ([entityB conformsToProtocol:@protocol(OGContactNotifiableType)] && bNeedsCallback)
    {
        callback((id<OGContactNotifiableType>) entityB, entityA);
    }
}

#pragma mark - Scene Management

- (void)pause
{
    [self pauseWithoutPauseScreen];
    [self showPauseScreen];
}

- (void)pauseWithoutPauseScreen
{
    [super pause];
    
    self.physicsWorld.speed = OGGameScenePauseSpeed;
    self.speed = OGGameScenePauseSpeed;
    
    self.pausedTimeInterval = NSTimeIntervalSince1970;
    self.controllInputNode.shouldHideThumbStickNodes = YES;
    self.controllInputNode.shouldHidePauseNode = YES;
}

- (void)showPauseScreen
{
    if (!self.pauseScreenNode.parent)
    {
        [self.camera addChild:self.pauseScreenNode];
    }
}

- (void)resume
{
    [super resume];
    
    self.controllInputNode.shouldHideThumbStickNodes = NO;
    self.controllInputNode.shouldHidePauseNode = NO;
    
    self.physicsWorld.speed = OGGameScenePlaySpeed;
    self.speed = OGGameScenePlaySpeed;
    
    if (self.pauseScreenNode.parent)
    {
        [self.pauseScreenNode removeFromParent];
    }
    
    if (self.gameOverScreenNode.parent)
    {
        [self.gameOverScreenNode removeFromParent];
    }
    
    if (self.pausedTimeInterval != 0.0)
    {
        self.lastUpdateTimeInterval = NSTimeIntervalSince1970 - self.pausedTimeInterval;
    }
}

- (void)runStoryConclusion
{
    
}

- (void)showGameOverScreen
{
    if (!self.gameOverScreenNode.parent)
    {
        [self.camera addChild:self.gameOverScreenNode];
    }
}

#pragma mark - Snapshot

- (OGEntitySnapshot *)entitySnapshotWithEntity:(GKEntity *)entity
{
    if (!self.levelSnapshot)
    {
        self.levelSnapshot = [[OGLevelStateSnapshot alloc] initWithScene:self];
    }
    
    NSUInteger index = [self.levelSnapshot.snapshot[OGLevelStateSnapshotEntitiesKey] indexOfObject:entity];
    
    return [self.levelSnapshot.snapshot[OGLevelStateSnapshotSnapshotsKey] objectAtIndex:index];
}

#pragma mark - Update

- (void)update:(NSTimeInterval)currentTime
{
    [super update:currentTime];
    
    if (self.lastUpdateTimeInterval == 0)
    {
        self.lastUpdateTimeInterval = currentTime;
    }
    
    if (!self.customPaused)
    {
        self.levelSnapshot = nil;
        
        CGFloat deltaTime = currentTime - self.lastUpdateTimeInterval;
        self.lastUpdateTimeInterval = currentTime;
        
        NSArray *array = [NSArray arrayWithArray:self.componentSystems];
        for (GKComponentSystem *componentSystem in array)
        {
            [componentSystem updateWithDeltaTime:deltaTime];
        }
        
        [self.inventoryBarNode checkPlayerPosition];
    }
    
    [self.hudNode updateHUD];
}

- (void)didFinishUpdate
{
    [super didFinishUpdate];
    
    if (((OGRenderComponent *) [self.player componentForClass:[OGRenderComponent class]]).node)
    {
        [self.player updateAgentPositionToMatchNodePosition];
    }
    
    [self sortSpritesWithZPosition];
}

- (void)sortSpritesWithZPosition
{
    [self.entitiesSortableByZ sortUsingComparator:(NSComparator)^(GKEntity *objA, GKEntity *objB)
     {
         OGRenderComponent *renderComponentA = (OGRenderComponent *) [objA componentForClass:[OGRenderComponent class]];
         OGRenderComponent *renderComponentB = (OGRenderComponent *) [objB componentForClass:[OGRenderComponent class]];
         NSComparisonResult result = NSOrderedSame;
         
         if (renderComponentA.node.position.y > renderComponentB.node.position.y)
         {
             result = NSOrderedAscending;
         }
         else
         {
             result = NSOrderedDescending;
         }
         
         return result;
     }];
    
    NSUInteger characterZPosition = OGZPositionCategoryPhysicsWorld;
    
    for (GKEntity *entity in self.entitiesSortableByZ)
    {
        OGRenderComponent *renderComponent = (OGRenderComponent *) [entity componentForClass:[OGRenderComponent class]];
        renderComponent.node.zPosition = characterZPosition;        
        characterZPosition += OGGameSceneZSpacePerCharacter;
    }
}

#pragma mark - Getters

- (NSArray<SKSpriteNode *> *)obstacleSpriteNodes
{
    NSMutableArray<SKSpriteNode *> *result = nil;
    
    [self enumerateChildNodesWithName:OGGameSceneObstacleName usingBlock:^(SKNode * node, BOOL * stop)
     {
         [result addObject:(SKSpriteNode *)node];
     }];
    
    return result;
}

- (NSArray<GKPolygonObstacle *> *)polygonObstacles
{
    return [SKNode obstaclesFromNodePhysicsBodies:self.obstacleSpriteNodes];;
}

- (NSArray<GKEntity *> *)entities
{
    return self.mutableEntities.array;
}

- (GKObstacleGraph *)obstaclesGraph
{
    if (!_obstaclesGraph)
    {
        _obstaclesGraph = [[GKObstacleGraph alloc] initWithObstacles:[[NSArray alloc] init]
                                                        bufferRadius:OGEnemyEntityPathfindingGraphBufferRadius];
    }
    
    return _obstaclesGraph;
}

#pragma mark - Button Click Handling

- (void)onButtonClick:(OGButtonNode *)buttonNode
{
    if ([buttonNode.name isEqualToString:OGGameSceneResumeButtonName])
    {
        [self.sceneDelegate didCallResume];
    }
    else if ([buttonNode.name isEqualToString:OGGameSceneRestartButtonName])
    {
        [self.sceneDelegate didCallRestart];
    }
    else if ([buttonNode.name isEqualToString:OGGameSceneMenuButtonName])
    {
        [self.sceneDelegate didCallExit];
    }
    else if ([buttonNode.name isEqualToString:OGGameScenePauseButtonName])
    {
        [self.sceneDelegate didCallPause];
    }
}

@end
