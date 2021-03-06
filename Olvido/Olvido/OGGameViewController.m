//
//  GameViewController.m
//  Olvido
//
//  Created by Дмитрий Антипенко on 9/27/16.
//  Copyright (c) 2016 Дмитрий Антипенко. All rights reserved.
//

#import "OGGameViewController.h"
#import "OGAudioManager.h"
#import "OGMainMenuScene.h"
#import "OGConstants.h"
#import "OGLevelManager.h"
#import "OGSceneManager.h"
#import "OGGameScene.h"
#import "OGMenuManager.h"

@interface OGGameViewController ()

@property (nonatomic, strong) OGAudioManager *audioManager;

@end

@implementation OGGameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SKView *view = (SKView *) self.view;
    
    view.multipleTouchEnabled = YES;
    
    /* DEBUG OPTIONS */
    view.showsFPS = YES;
    view.showsNodeCount = YES;
    /* DEBUG OPTIONS */
    
    self.sceneManager = [OGSceneManager sceneManagerWithView:view];
    self.audioManager = [OGAudioManager audioManager];
    
    self.levelManager = [OGLevelManager levelManager];
    self.levelManager.sceneManager = self.sceneManager;
    self.levelManager.audioManager = self.audioManager;
    
    self.menuManager = [OGMenuManager menuManager];
    self.menuManager.sceneManager = self.sceneManager;
    self.menuManager.audioManager = self.audioManager;
    
    self.menuManager.levelManager = self.levelManager;
    self.levelManager.menuManager = self.menuManager;
    
    [self.menuManager loadMainMenu];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    else
    {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
