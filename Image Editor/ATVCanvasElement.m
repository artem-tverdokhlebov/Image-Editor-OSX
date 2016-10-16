//
//  ATVCanvasElement.m
//  Image Editor
//
//  Created by Артём Твердохлебов on 8/19/16.
//  Copyright © 2016 Артём Твердохлебов. All rights reserved.
//

#import "ATVCanvasElement.h"

NSString *const kATVCanvasElementFrame = @"ATVCanvasElementFrame";
NSString *const kATVCanvasElementFilters = @"ATVCanvasElementFilters";
NSString *const kATVCanvasElementOpacity = @"ATVCanvasElementOpacity";
NSString *const kATVCanvasElementRotationAngle = @"ATVCanvasElementRotationAngle";

@interface ATVCanvasElement()
{
    NSArray<CIFilter *> *_filters;
}
@end

@implementation ATVCanvasElement

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _filters = [[NSArray alloc] init];
        _opacity = 1.0;
    }
    
    return self;
}

- (NSRect)frame
{
    return _frame;
}

- (void)setFrame:(NSRect)frame
{
    BOOL isSizesEqual = YES;
    if(!NSEqualRects(_frame, frame))
    {
        if(!NSEqualSizes(_frame.size, frame.size))
        {
            isSizesEqual = NO;
        }
        
        if ([self.delegate respondsToSelector:@selector(canvasElementFrameWillChange:)])
            [self.delegate canvasElementFrameWillChange:self];
        
        _frame = frame;
        
        if ([self.delegate respondsToSelector:@selector(canvasElementSizeDidChange:)])
            [self.delegate canvasElementFrameDidChange:self];
        
        if (!isSizesEqual && [self.delegate respondsToSelector:@selector(canvasElementSizeDidChange:)])
            [self.delegate canvasElementSizeDidChange:self];
    }
}

- (void)setFrameOrigin:(NSPoint)newOrigin
{
    if (!NSEqualPoints(_frame.origin, newOrigin))
    {
        self.frame = NSMakeRect(newOrigin.x, newOrigin.y, self.frame.size.width, self.frame.size.height);
    }
}

- (NSPoint)frameOrigin
{
    return self.frame.origin;
}

- (void)setFrameSize:(NSSize)size
{
    if(!NSEqualSizes(_frame.size, size))
    {
        self.frame = NSMakeRect(self.frame.origin.x, self.frame.origin.y, size.width, size.height);
    }
}

- (NSSize)frameSize
{
    return self.frame.size;
}

- (void)offsetOriginByX:(CGFloat)x andY:(CGFloat)y
{
    self.frameOrigin = NSMakePoint(self.frameOrigin.x + x,  self.frameOrigin.y + y);
}

- (void)addFilter:(CIFilter *)filter
{
    NSMutableArray *filters = [self.filters mutableCopy];
    [filters addObject:filter];
    self.filters = [filters autorelease];
    
    if ([self.delegate respondsToSelector:@selector(canvasElementFiltersDidChange:)])
        [self.delegate canvasElementFiltersDidChange:self];
}

- (void)removeFilter:(CIFilter *)filter
{
    NSMutableArray *filters = [self.filters mutableCopy];

    for (CIFilter *item in self.filters)
    {
        if ([item.name isEqualToString:filter.name])
        {
            [filters removeObject:item];
        }
    }
    
    self.filters = [filters autorelease];
    
    if ([self.delegate respondsToSelector:@selector(canvasElementRotationAngleDidChange:)])
        [self.delegate canvasElementRotationAngleDidChange:self];
}

- (NSRect)rotatedFrame
{
    NSBezierPath *bezierPath = [NSBezierPath bezierPathWithRect:self.frame];
    
    NSAffineTransform *rotationTransform = [NSAffineTransform transform];
    
    [rotationTransform translateXBy:self.frame.origin.x + (self.frame.size.width / 2) yBy:self.frame.origin.y + (self.frame.size.height / 2)];
    [rotationTransform rotateByDegrees:self.rotationAngle];
    [rotationTransform translateXBy:-(self.frame.origin.x + (self.frame.size.width / 2)) yBy:-(self.frame.origin.y + (self.frame.size.height / 2))];
    
    [bezierPath transformUsingAffineTransform:rotationTransform];
    
    return bezierPath.controlPointBounds;
}

- (CGFloat)opacity
{
    return _opacity;
}

- (void)setOpacity:(CGFloat)opacity
{
    _opacity = opacity;
    
    if ([self.delegate respondsToSelector:@selector(canvasElementPropertiesDidChange:)])
        [self.delegate canvasElementPropertiesDidChange:self];
}

- (CGFloat)rotationAngle
{
    return _rotationAngle;
}

- (void)setRotationAngle:(CGFloat)rotationAngle
{
    _rotationAngle = rotationAngle;
    
    if ([self.delegate respondsToSelector:@selector(canvasElementPropertiesDidChange:)])
        [self.delegate canvasElementPropertiesDidChange:self];
}

#pragma mark NSCoding Implementation

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeRect:_frame forKey:kATVCanvasElementFrame];
    [aCoder encodeObject:_filters forKey:kATVCanvasElementFilters];
    [aCoder encodeDouble:_opacity forKey:kATVCanvasElementOpacity];
    [aCoder encodeDouble:_rotationAngle forKey:kATVCanvasElementRotationAngle];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self)
    {
        _frame = [coder decodeRectForKey:kATVCanvasElementFrame];
        _filters = [[coder decodeObjectForKey:kATVCanvasElementFilters] copy];
        _opacity = [coder decodeDoubleForKey:kATVCanvasElementOpacity];
        _rotationAngle = [coder decodeDoubleForKey:kATVCanvasElementRotationAngle];
    }
    
    return self;
}

- (void)dealloc
{
    [_filters release];
    [super dealloc];
}

@end
