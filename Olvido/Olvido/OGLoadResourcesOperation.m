//
//  OGLoadResourcesOperation.m
//  Olvido
//
//  Created by Алексей Подолян on 11/10/16.
//  Copyright © 2016 Дмитрий Антипенко. All rights reserved.
//

#import "OGLoadResourcesOperation.h"
#import "OGResourceLoadable.h"

NSUInteger const kOGLoadResourcesOperationProgressTotalUnitCount = 1;

@interface OGLoadResourcesOperation ()

@property (nonatomic, strong) NSProgress *progress;
@property (nonatomic, unsafe_unretained) Class<OGResourceLoadable> loadableClass;

@end

@implementation OGLoadResourcesOperation

- (instancetype)initWithLoadableClass:(Class<OGResourceLoadable>)loadableClass
{
    self = [self init];
    
    if (self)
    {
        _loadableClass = loadableClass;
        _progress = [NSProgress progressWithTotalUnitCount:kOGLoadResourcesOperationProgressTotalUnitCount];
    }
    
    return self;
}

- (void)start
{
    if (!self.isCancelled)
    {
        if (self.progress.isCancelled)
        {
            [self cancel];
        }
        else
        {
            if ([self.loadableClass resourcesNeedLoading])
            {
                [self.loadableClass loadResourcesWithCompletionHandler:^
                 {
                     [self finish];
                 }];
            }
            else
            {
                [self finish];
            }
        }
    }
}

- (void)finish
{
    self.progress.completedUnitCount = kOGLoadResourcesOperationProgressTotalUnitCount;
}

@end
