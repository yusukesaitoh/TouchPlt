//
//  CanvasView.m
//  TouchPlt
//
//  Created by Yusuke Saitoh on 2013/11/04.
//  Copyright (c) 2013年 Yusuke Saitoh. All rights reserved.
//

#import "CanvasView.h"
#import "Polygon.h"

@implementation CanvasView {
    NSMutableArray *activeTouches;
    Polygon *editingPolygon;
    int editingIndex;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp
{
    activeTouches = [NSMutableArray arrayWithCapacity:0];
    self.polygons = [NSMutableArray arrayWithCapacity:0];
    self.mode = 0;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetShouldAntialias(context, YES);
    
    CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f);
    CGContextFillRect(context, self.bounds);
    
    CGContextSetLineWidth(context, 1);
    
    CGContextSetRGBStrokeColor(context, 0.0f, 0.0f, 0.0f, 1.0f);
    for (Polygon *polygon in self.polygons) {
        [self drawLine:polygon context:context];
    }
    
    CGContextSetRGBStrokeColor(context, 0.0f, 0.0f, 1.0f, 1.0f);
    [self drawLine:editingPolygon context:context];
    
}

- (void)drawLine:(Polygon*)polygon context:(CGContextRef)context
{
    CGContextBeginPath(context);
    
    for (int i = 0; i < polygon.points.count; i++) {
        CGPoint point = [[polygon.points objectAtIndex:i] CGPointValue];
        if(i == 0)
            CGContextMoveToPoint(context, point.x, point.y);
        else
            CGContextAddLineToPoint(context, point.x, point.y);
    }
    if (polygon.isClosed) {
        CGPoint point = [[polygon.points objectAtIndex:0] CGPointValue];
        CGContextAddLineToPoint(context, point.x, point.y);
    }

    if (self.mode == 1) {
        CGContextSetRGBFillColor(context, 0.0f, 0.0f, 1.0f, 0.05f);
        CGContextDrawPath(context, kCGPathEOFillStroke);
    } else if (self.mode == 2) {
        CGContextSetRGBFillColor(context, 1.0f, 0.0f, 0.0f, 0.05f);
        CGContextDrawPath(context, kCGPathEOFillStroke);
    } else if (self.mode == 3) {
        CGContextSetRGBFillColor(context, 0.0f, 1.0f, 0.0f, 0.05f);
        CGContextDrawPath(context, kCGPathEOFillStroke);
    } else {
        CGContextStrokePath(context);
    }
}

- (BOOL)polygonContainsPoint:(Polygon*)polygon point:(CGPoint)point
{
    int count = 0;
    
    for(int i = 0; i < polygon.points.count; i++){
        CGPoint crntPt = [[polygon.points objectAtIndex:i] CGPointValue];
        CGPoint nextPt;
        if (i == polygon.points.count-1)
            nextPt = [[polygon.points objectAtIndex:0] CGPointValue];
        else
            nextPt = [[polygon.points objectAtIndex:i+1] CGPointValue];
            float d = [self pointLineDist:point a:crntPt b:nextPt];
            if(d < 5) return YES;
        
        if (crntPt.x <= point.x && point.x <= nextPt.x && ((crntPt.y <= nextPt.y && crntPt.y <= point.y && point.y <= nextPt.y) || (crntPt.y > nextPt.y && nextPt.y <= point.y && point.y <= crntPt.y)) && (point.y-crntPt.y)*(nextPt.x-crntPt.x) == (nextPt.y-crntPt.y)*(point.x-crntPt.x))
            return YES;


        if (i == polygon.points.count-1) {
            nextPt = [[polygon.points firstObject] CGPointValue];
        } else {
            nextPt = [[polygon.points objectAtIndex:i+1] CGPointValue];
        }
        
        
        if( ((crntPt.y <= point.y) && (nextPt.y > point.y))
           || ((crntPt.y > point.y) && (nextPt.y <= point.y)) ){
            
            float vt = (point.y - crntPt.y) / (nextPt.y - crntPt.y);
            if(point.x < (crntPt.x + (vt * (nextPt.x - crntPt.x)))){
                ++count;
            }
        }
    }
    return count%2 == 1;
}

- (double)pointLineDist:(CGPoint)p a:(CGPoint)a b:(CGPoint)b
{
    CGPoint closest;
    float dx = b.x - a.x;
    float dy = b.y - a.y;
    if ((dx == 0) && (dy == 0))
    {
        closest = a;
        dx = p.x - a.x;
        dy = p.y - a.y;
        return sqrt(dx * dx + dy * dy);
    }
    
    float t = ((p.x - a.x) * dx + (p.y - a.y) * dy) / (dx * dx + dy * dy);
    
    if (t < 0)
    {
        closest = CGPointMake(a.x, a.y);
        dx = p.x - a.x;
        dy = p.y - a.y;
    }
    else if (t > 1)
    {
        closest = CGPointMake(b.x, b.y);
        dx = p.x - b.x;
        dy = p.y - b.y;
    }
    else
    {
        closest = CGPointMake(a.x + t * dx, a.y + t * dy);
        dx = p.x - closest.x;
        dy = p.y - closest.y;
    }
    
    return sqrt(dx * dx + dy * dy);
}

#pragma mark - Touches Handling

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    for(UITouch *touch in touches){
        [activeTouches addObject:touch];
    }
	
	if([activeTouches count] == 1) {
		UITouch *t = [activeTouches objectAtIndex:0];
		CGPoint crntPt = [t locationInView:self];
        switch (self.mode) {
            case 0:
                editingPolygon =  [[Polygon alloc]init];
                [editingPolygon.points addObject:[NSValue valueWithCGPoint:crntPt]];
                break;
                
            case 1:
            {
                for(int i = 0; i < self.polygons.count; i++){
                    Polygon *polygon = [self.polygons objectAtIndex:i];
                    if([self polygonContainsPoint:polygon point:crntPt])
                    {
                        [self.polygons removeObjectAtIndex:i];
                        editingPolygon = polygon;
                        editingIndex = i;
                        break;
                    }
                }
            }
                break;
                
            case 2:
            {
                for(int i = 0; i < self.polygons.count; i++){
                    Polygon *polygon = [self.polygons objectAtIndex:i];
                    if([self polygonContainsPoint:polygon point:crntPt])
                    {
                        [self.polygons removeObjectAtIndex:i];
                        editingPolygon = nil;
                        break;
                    }
                }
            }
                break;
                
            case 3:
            {
                for(int i = 0; i < self.polygons.count; i++){
                    Polygon *polygon = [self.polygons objectAtIndex:i];
                    if([self polygonContainsPoint:polygon point:crntPt])
                    {
                        polygon.isClosed = !polygon.isClosed;
                        editingPolygon = nil;
                        break;
                    }
                }
            }
                break;
                
            default:
                break;
        }
	}
    [self setNeedsDisplay];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if([activeTouches count]>2){
        return;
    }
    if([activeTouches count]==1){
        UITouch *t0 = [activeTouches objectAtIndex:0];
		CGPoint crntPt = [t0 locationInView:self];
        CGPoint prevPt = [t0 previousLocationInView:self];
        
        switch (self.mode) {
            case 0:
                if ( CGRectContainsPoint(self.bounds, crntPt)) {
                    if (!CGPointEqualToPoint(crntPt, prevPt))
                        [editingPolygon.points addObject:[NSValue valueWithCGPoint:crntPt]];
                }
                break;
                
            case 1:
            {
                float dx = crntPt.x - prevPt.x;
                float dy = crntPt.y - prevPt.y;
                
                CGRect crntFrame = [editingPolygon frame];
                
                if ( crntFrame.origin.x + dx <  self.bounds.origin.x) {
                    if (dx < 0)
                        dx = -crntFrame.origin.x;
                    else
                        dx = 0;
                } else if (crntFrame.origin.x + crntFrame.size.width + dx > self.bounds.size.width) {
                    if (dx > self.bounds.size.width)
                        dx = self.bounds.size.width-(crntFrame.origin.x + crntFrame.size.width);
                    else
                        dx = 0;
                }
                
                if ( crntFrame.origin.y + dy <  self.bounds.origin.y) {
                    if (dy < 0)
                        dy = -crntFrame.origin.y;
                    else
                        dy = 0;

                } else if (crntFrame.origin.y + crntFrame.size.height + dy > self.bounds.size.height) {
                    if (dy > self.bounds.size.height)
                    {
                        dy = self.bounds.size.height-(crntFrame.origin.y + crntFrame.size.height);
                    } else
                    {
                        dy = 0;
                    }
                }
                
                for (int i = 0; i < editingPolygon.points.count; i++) {
                    CGPoint point = [[editingPolygon.points objectAtIndex:i] CGPointValue];
                    point.x += dx;
                    point.y += dy;
                    [editingPolygon.points replaceObjectAtIndex:i withObject:[NSValue valueWithCGPoint:point]];
                }
            }
                break;
                
            default:
                break;
        }
    }
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for(UITouch *touch in touches){
        
        switch (self.mode) {
            case 0:
                editingPolygon.points = [self douglasPeucker:editingPolygon.points];
                [self.polygons insertObject:editingPolygon atIndex:0];
                editingPolygon = nil;
                break;
                
            case 1:
            {
                if(editingPolygon) [self.polygons insertObject:editingPolygon atIndex:editingIndex];
                editingPolygon = nil;
                editingIndex = 0;
            }
                break;
                
            default:
                break;
        }
        [activeTouches removeObject:touch];
    }
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for(UITouch *touch in touches){
        [activeTouches removeObject:touch];
    }
    editingPolygon = nil;
    
}


- (NSMutableArray *)douglasPeucker:(NSMutableArray *)points
{
    float dmax = 0;
    int index = 0;
    
    float epsilon = 1;
    
    for (int i = 1; i < points.count; i++) {
        float d = [self perpendicularDistance:[[points objectAtIndex:i] CGPointValue]  a:[[points firstObject] CGPointValue] b:[[points lastObject] CGPointValue]];
        
        if (d > dmax) {
            index = i;
            dmax = d;
        }
    }
    
    NSMutableArray *points1, *points2, *resultPoints;
    if (dmax >= epsilon) {
        points1 = [self douglasPeucker: [[points subarrayWithRange:NSMakeRange(0, index)] mutableCopy]];
        points2 = [self douglasPeucker: [[points subarrayWithRange:NSMakeRange(index, points.count-index)] mutableCopy]];
        resultPoints = [NSMutableArray arrayWithArray:points1];
        [resultPoints addObjectsFromArray: points2];
    } else {
        resultPoints = [NSMutableArray arrayWithObjects:[points firstObject], [points lastObject], nil];
    }
    
    return resultPoints;
}

- (double)perpendicularDistance:(CGPoint)p a:(CGPoint)a b:(CGPoint)b
{
    double dx, dy, r2;
    double t, cx, cy;
    dx = b.x - a.x;
    dy = b.y - a.y;
    if (dx == 0 && dy == 0)
        return sqrt((p.x - a.x) * (p.x - a.x) + (p.y - a.y) * (p.y - a.y));
    r2 = dx * dx + dy * dy;
    t = (dx * (p.x - a.x) + dy * (p.y - a.y)) / r2;
    if (t < 0)
        return sqrt((p.x - a.x) * (p.x - a.x) + (p.y - a.y) * (p.y - a.y));
    if (t > 1)
        return sqrt((p.x - b.x) * (p.x - b.x) + (p.y - b.y) * (p.y - b.y));
    cx = (1 - t) * a.x + t * b.x;
    cy = (1 - t) * a.y + t * b.y;
    return sqrt((p.x - cx) * (p.x - cx) + (p.y - cy) * (p.y - cy));
}

- (void)deleteAll
{
    self.polygons = [NSMutableArray arrayWithCapacity:0];
    [self setNeedsDisplay];
}


@end
