//
//  ATVCanvasModelController.m
//  Image Editor
//
//  Created by Артём Твердохлебов on 8/20/16.
//  Copyright © 2016 Артём Твердохлебов. All rights reserved.
//

#import "ATVCanvasModelController.h"

static NSString *kATVModelCanvasElements = @"ATVModelCanvasElements";
static NSString *kATVModelCanvasSize = @"ATVModelCanvasSize";

@interface ATVCanvasModelController()
{
    NSMutableArray<ATVCanvasElement *> *_canvasElements;
}
@property (copy, readwrite) NSArray<ATVCanvasElement *> *canvasElements;
@end

@implementation ATVCanvasModelController

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _canvasElements = [[NSMutableArray alloc] init];
        _canvasSize = NSMakeSize(500, 500);
    }
    
    return self;
}

#pragma mark NSCoding Implementation

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_canvasElements forKey:kATVModelCanvasElements];
    [aCoder encodeSize:_canvasSize forKey:kATVModelCanvasSize];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self)
    {
        _canvasElements = [[coder decodeObjectForKey:kATVModelCanvasElements] copy];
        _canvasSize = [coder decodeSizeForKey:kATVModelCanvasSize];
    }
    
    return self;
}

- (void)addCanvasElement:(ATVCanvasElement *)element
{
    NSMutableArray *canvasElements = [self.canvasElements mutableCopy];
    [canvasElements addObject:element];
    self.canvasElements = canvasElements;
    [canvasElements release];
}

- (void)removeCanvasElement:(ATVCanvasElement *)element
{
    NSMutableArray *canvasElements = [self.canvasElements mutableCopy];
    [canvasElements removeObject:element];
    self.canvasElements = canvasElements;
    [canvasElements release];
}
 
- (void)dealloc
{
    [_canvasElements release];
    [super dealloc];
}

@end
