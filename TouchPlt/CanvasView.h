//
//  CanvasView.h
//  TouchPlt
//
//  Created by Yusuke Saitoh on 2013/11/04.
//  Copyright (c) 2013年 Yusuke Saitoh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CanvasView : UIView

- (void)deleteAll;

@property(strong, nonatomic) NSMutableArray *polygons;
@property(assign, nonatomic) int mode;

@end
