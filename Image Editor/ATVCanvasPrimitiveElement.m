//
//  ATVCanvasPrimitiveElement.m
//  Image Editor
//
//  Created by Артём Твердохлебов on 8/30/16.
//  Copyright © 2016 Артём Твердохлебов. All rights reserved.
//

#import "ATVCanvasPrimitiveElement.h"

NSString *const kATVCanvasPrimitiveElementLineColor = @"ATVCanvasShapePrimitiveLineColor";
NSString *const kATVCanvasPrimitiveElementLineWidth = @"ATVCanvasShapePrimitiveLineWidth";

@interface ATVCanvasPrimitiveElement()
{
    NSColor *_lineColor;
    NSUInteger _lineWidth;
}
@end

@implementation ATVCanvasPrimitiveElement

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _lineColor = [NSColor blackColor];
    }
    
    return self;
}

- (NSColor *)lineColor
{
    return _lineColor;
}

- (void)setLineColor:(NSColor *)lineColor
{
    if (_lineColor != lineColor)
    {
        [_lineColor release];
        _lineColor = [lineColor retain];
        
        if ([self.delegate respondsToSelector:@selector(canvasElementPropertiesDidChange:)])
            [self.delegate canvasElementPropertiesDidChange:self];
    }
}

- (NSUInteger)lineWidth
{
    return _lineWidth;
}

- (void)setLineWidth:(NSUInteger)lineWidth
{
    _lineWidth = lineWidth;
    
    if ([self.delegate respondsToSelector:@selector(canvasElementPropertiesDidChange:)])
        [self.delegate canvasElementPropertiesDidChange:self];
}

#pragma mark Coding Protocol Implementation

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        _lineColor = [[coder decodeObjectForKey:kATVCanvasPrimitiveElementLineColor] retain];
        _lineWidth = [coder decodeIntegerForKey:kATVCanvasPrimitiveElementLineWidth];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_lineColor forKey:kATVCanvasPrimitiveElementLineColor];
    [aCoder encodeInteger:_lineWidth forKey:kATVCanvasPrimitiveElementLineWidth];
}

- (void)dealloc
{
    [_lineColor release];
    [super dealloc];
}

@end
