//
//  Polygon.m
//  TouchPlt
//
//  Created by Yusuke Saitoh on 2013/11/04.
//  Copyright (c) 2013年 Yusuke Saitoh. All rights reserved.
//

#import "Polygon.h"

@implementation Polygon

- (id)init
{
    self = [super init];
    if (self) {
        self.points = [NSMutableArray array];
        self.isClosed = NO;
    }
    return self;
}

- (id)copyWithZone:(NSZone*)zone
{
    Polygon* result = [[[self class] allocWithZone:zone] init];
    
    if (result)
    {
        
        result->_points = [[NSMutableArray allocWithZone:zone] initWithArray:_points copyItems:YES];
        result->_isClosed = _isClosed;
    }
    
    return result;
}

- (CGRect)frame {
    CGRect frame = CGRectMake(MAXFLOAT, MAXFLOAT, 0, 0);
    float maxX = 0, maxY = 0;
    
    for (NSValue *pointValue in self.points) {
        CGPoint p = [pointValue CGPointValue];
        frame.origin.x = fminf(frame.origin.x, p.x);
        frame.origin.y = fminf(frame.origin.y, p.y);
        maxX = fmaxf(maxX, p.x);
        maxY = fmaxf(maxY, p.y);
    }
    
    frame.size.width = maxX - frame.origin.x;
    frame.size.height = maxY - frame.origin.y;
    
    return frame;
}

@end
