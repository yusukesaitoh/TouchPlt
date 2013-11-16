//
//  TouchPltUtil.h
//  TouchPlt
//
//  Created by Yusuke Saitoh on 2013/11/04.
//  Copyright (c) 2013年 Yusuke Saitoh. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@class CanvasView;

@interface TouchPltUtil : NSObject

+ (NSString *)createSvgString:(CanvasView *)canvasView;
+ (NSString *)createPltString:(CanvasView *)canvasView exportType:(int)exportType;

@end

@interface NSDate(Util)

- (NSString *)datetimeString;

@end
