//
//  BuddyCell.h
//  Ta
//
//  Created by Sangeun Kim on 3/25/11.
//  Copyright 2011 NHN Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BuddyCell : NSTextFieldCell {
@private
    NSString* subTitle;
    NSString* title;
}
@property (nonatomic, copy) NSString* subTitle;
@property (nonatomic, copy) NSString* title;
@end
