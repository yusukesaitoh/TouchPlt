//
//  Polygon.h
//  TouchPlt
//
//  Created by Yusuke Saitoh on 2013/11/04.
//  Copyright (c) 2013年 Yusuke Saitoh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Polygon : NSObject <NSCopying>{
    
}
- (CGRect)frame;

@property(strong) NSMutableArray *points;
@property(assign) BOOL isClosed;

@end
