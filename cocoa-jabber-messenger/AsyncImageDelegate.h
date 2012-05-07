//
//  AsyncImageDelegate.h
//  SinaUC
//
//  Created by 硕实 陈 on 12-5-6.
//  Copyright (c) 2012年 NHN Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AsyncImageDelegate <NSObject>
- (void) imageloaded:(NSString*) picName withData:(NSData*) data;
@end

