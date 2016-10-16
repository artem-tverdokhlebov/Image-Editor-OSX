//
//  ATVCanvasLineElement.m
//  Image Editor
//
//  Created by Артём Твердохлебов on 8/24/16.
//  Copyright © 2016 Артём Твердохлебов. All rights reserved.
//

#import "ATVCanvasLineElement.h"

NSString *const kATVCanvasLineElementIsLineStartsInOrigin = @"ATVCanvasLineElementIsLineStartsInOrigin";

NSString *const kATVCanvasLineElementUTI = @"com.atverd.image-editor.canvasLineElement";

@interface ATVCanvasLineElement()
@property (assign) BOOL isLineStartsInOrigin;
@end

@implementation ATVCanvasLineElement

- (instancetype)initWithFirstPoint:(NSPoint)firstPoint secondPoint:(NSPoint)secondPoint
{
    self = [super init];
    if (self)
    {
        _isLineStartsInOrigin = ((firstPoint.x == MIN(firstPoint.x, secondPoint.x) && firstPoint.y == MIN(firstPoint.y, secondPoint.y))) || ((secondPoint.x == MIN(firstPoint.x, secondPoint.x) && secondPoint.y == MIN(firstPoint.y, secondPoint.y)));
        _frame = NSMakeRect(MIN(firstPoint.x, secondPoint.x), MIN(firstPoint.y, secondPoint.y), fabs(firstPoint.x - secondPoint.x), fabs(firstPoint.y - secondPoint.y));
    }
    
    return self;
}

+ (instancetype)canvasLineElementWithFirstPoint:(NSPoint)firstPoint secondPoint:(NSPoint)secondPoint
{
    return [[[self alloc] initWithFirstPoint:firstPoint secondPoint:secondPoint] autorelease];
}

- (NSPoint)firstPoint
{
    return [self firstPointInRect:self.frame];
}

- (NSPoint)secondPoint
{
    return [self secondPointInRect:self.frame];
}

- (NSPoint)firstPointInRect:(NSRect)frame
{
    if(self.isLineStartsInOrigin)
    {
        return NSMakePoint(frame.origin.x, frame.origin.y);
    }
    else
    {
        return NSMakePoint(frame.origin.x, frame.origin.y + frame.size.height);
    }
}

- (NSPoint)secondPointInRect:(NSRect)frame
{
    if(self.isLineStartsInOrigin)
    {
        return NSMakePoint(frame.origin.x + frame.size.width, frame.origin.y + frame.size.height);
    }
    else
    {
        return NSMakePoint(frame.origin.x + frame.size.width, frame.origin.y);
    }
}

#pragma mark Coding Protocol Implementation

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        _isLineStartsInOrigin = [coder decodeBoolForKey:kATVCanvasLineElementIsLineStartsInOrigin];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeBool:_isLineStartsInOrigin forKey:kATVCanvasLineElementIsLineStartsInOrigin];
}

#pragma mark Pasteboard Writing Protocol

- (NSArray<NSString *> *)writableTypesForPasteboard:(NSPasteboard *)pasteboard
{
    return @[kATVCanvasLineElementUTI];
}

- (id)pasteboardPropertyListForType:(NSString *)type
{
    if ([type isEqualToString:kATVCanvasLineElementUTI])
    {
        return [NSKeyedArchiver archivedDataWithRootObject:self];
    }
    
    return nil;
}

#pragma mark Pasteboard Reading Protocol

+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard
{
    return @[kATVCanvasLineElementUTI];
}

+ (NSPasteboardReadingOptions)readingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pboard {
    if ([type isEqualToString:kATVCanvasLineElementUTI]) {
        return NSPasteboardReadingAsKeyedArchive;
    }
    
    return 0;
}

- (void)dealloc
{
    [super dealloc];
}

@end
