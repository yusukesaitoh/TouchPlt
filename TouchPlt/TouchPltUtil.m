//
//  TouchPltUtil.m
//  TouchPlt
//
//  Created by Yusuke Saitoh on 2013/11/04.
//  Copyright (c) 2013年 Yusuke Saitoh. All rights reserved.
//

#import "TouchPltUtil.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#import "Polygon.h"
#import "CanvasView.h"

@implementation TouchPltUtil

+ (NSString *)createSvgString:(CanvasView *)canvasView
{
    int width = (int)canvasView.frame.size.width;
    int height = (int)canvasView.frame.size.height;
    
    NSMutableString *svgStr = [NSMutableString stringWithString:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\" \"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">\n<svg version=\"1.1\" id=\"layer_1\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" "];
    [svgStr appendString:[NSString stringWithFormat:@"x=\"0px\" y=\"0px\" width=\"%dpx\" height=\"%dpx\" viewBox=\"0 0 %d %d\" enable-background=\"new 0 0 %d %d\" xml:space=\"preserve\">\n", width, height, width, height, width, height] ];
    
    NSArray *polygons = canvasView.polygons;
    
    for (Polygon *polygon in polygons) {
        CGPoint point;
        NSString *type;
        if (polygon.isClosed) type = @"polygon";
        else type = @"polyline";
        
        for (int i = 0; i < polygon.points.count; i++) {
            point = [[polygon.points objectAtIndex:i] CGPointValue];
            if (i == 0)
                [svgStr appendString:[NSString stringWithFormat:@"<%@ fill=\"none\" stroke=\"#000000\" stroke-miterlimit=\"10\" points=\"%.3f,%.3f ", type, point.x, point.y]];
            else
                [svgStr appendString:[NSString stringWithFormat:@"%.3f,%.3f ", point.x, point.y]];
        }
        [svgStr appendString:@"\" />\n"];
    }
    [svgStr appendString:@"</svg>"];
    
    return svgStr;
}

+ (NSString *)createPltString:(CanvasView *)canvasView exportType:(int)exportType
{
    NSString *settingPrefix = @"";
    switch (exportType) {
        case 0:
            // Thin
            settingPrefix = @"FN0,&100,100,100,^0,0,\\0,0,SO0,L0,!110,FX2,0,FC18,";
            break;
            
        case 1:
            // Normal
            settingPrefix = @"FN0,&100,100,100,^0,0,\\0,0,SO0,L0,!110,FX10,0,FC18,";
            break;
            
        case 2:
            // Thick
            settingPrefix = @"FN0,&100,100,100,^0,0,\\0,0,SO0,L0,!110,FX27,0,FC18,";
            break;
            
        case 3:
            // Pen Drawing
            settingPrefix = @"FN0,&100,100,100,^0,0,\\0,0,SO0,L0,!110,FX10,0,FC0,";
            break;
    }
    
    float scale = 508/ [TouchPltUtil screenDensity]*[[UIScreen mainScreen] scale];
    
    NSMutableString *pltStr = [NSMutableString stringWithString:settingPrefix];
    
    NSArray *polygons = canvasView.polygons;
    
    for (Polygon *polygon in polygons) {
        CGPoint point;
        for (int i = 0; i < polygon.points.count; i++) {
            point = [[polygon.points objectAtIndex:i] CGPointValue];
            if (i == 0)
                [pltStr appendString:[NSString stringWithFormat:@"M%d,%d,", (int)(point.y * scale), (int)(point.x * scale)]];
            else
                [pltStr appendString:[NSString stringWithFormat:@"D%d,%d,", (int)(point.y * scale), (int)(point.x * scale)]];
        }
        if (polygon.isClosed) {
            point = [[polygon.points objectAtIndex:0] CGPointValue];
            [pltStr appendString:[NSString stringWithFormat:@"D%d,%d,", (int)(point.y * scale), (int)(point.x * scale)]];
        }
    }
    [pltStr appendString:@"M0,0,"];
    return pltStr;
}


+ (float)screenDensity
{
    float scale = 1;
    if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) {
        scale = [[UIScreen mainScreen] scale];
    }
    
    float ppi;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        NSString *platform = [TouchPltUtil platform];
        if ([platform isEqualToString:@"iPad2,5"]
            || [platform isEqualToString:@"iPad2,6"]
            || [platform isEqualToString:@"iPad2,7"]
            || [platform isEqualToString:@"iPad4,4"]
            || [platform isEqualToString:@"iPad4,5"]
            )
            ppi = 163 * scale;
        else
            ppi = 132 * scale;
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        ppi = 163 * scale;
    } else {
        ppi = 160 * scale;
    }
    return ppi;
}

+ (NSString *)platform
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}


@end

#pragma mark - NSDate

@implementation NSDate(Util)

- (NSString *)datetimeString
{
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"YYYY.MM.dd HH:mm:ss"];
	NSString *result = [df stringFromDate:self];
	return result;
}

@end
