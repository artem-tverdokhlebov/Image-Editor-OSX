//
//  ATVCanvasShapeElement.m
//  Image Editor
//
//  Created by Артём Твердохлебов on 8/24/16.
//  Copyright © 2016 Артём Твердохлебов. All rights reserved.
//

#import "ATVCanvasShapeElement.h"

NSString *const kATVCanvasShapeElementType = @"ATVCanvasShapeElementType";

NSString *const kATVCanvasShapeElementUTI = @"com.atverd.image-editor.canvasImageElement";

@interface ATVCanvasShapeElement()

@end

@implementation ATVCanvasShapeElement

- (instancetype)initWithShapeType:(ATVShapeType)shapeType
{
    return [self initWithShapeType:shapeType frameSize:NSMakeSize(0, 0) frameOrigin:NSMakePoint(0, 0)];
}

- (instancetype)initWithShapeType:(ATVShapeType)shapeType frameOrigin:(NSPoint)aFrameOrigin
{
    return [self initWithShapeType:shapeType frameSize:NSMakeSize(0, 0) frameOrigin:aFrameOrigin];
}

- (instancetype)initWithShapeType:(ATVShapeType)shapeType frameSize:(NSSize)aFrameSize frameOrigin:(NSPoint)aFrameOrigin
{
    self = [super init];
    if (self)
    {
        _shapeType = shapeType;
        
        _frame.size = aFrameSize;
        _frame.origin = aFrameOrigin;
    }
    
    return self;
}

+ (instancetype)canvasShapeElementWithType:(ATVShapeType)shapeType frameSize:(NSSize)aFrameSize frameOrigin:(NSPoint)aFrameOrigin
{
    return [[[self alloc] initWithShapeType:shapeType frameSize:aFrameSize frameOrigin:aFrameOrigin] autorelease];
}

+ (instancetype)canvasShapeElementWithType:(ATVShapeType)shapeType frameOrigin:(NSPoint)aFrameOrigin
{
    return [[[self alloc] initWithShapeType:shapeType frameOrigin:aFrameOrigin] autorelease];
}

#pragma mark Coding Protocol Implementation

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        _shapeType = [coder decodeIntegerForKey:kATVCanvasShapeElementType];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeInteger:_shapeType forKey:kATVCanvasShapeElementType];
}

#pragma mark Pasteboard Writing Protocol

- (NSArray<NSString *> *)writableTypesForPasteboard:(NSPasteboard *)pasteboard
{
    return @[kATVCanvasShapeElementUTI];
}

- (id)pasteboardPropertyListForType:(NSString *)type
{
    if ([type isEqualToString:kATVCanvasShapeElementUTI])
    {
        return [NSKeyedArchiver archivedDataWithRootObject:self];
    }
    
    return nil;
}

#pragma mark Pasteboard Reading Protocol

+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard
{
    return @[kATVCanvasShapeElementUTI];
}

+ (NSPasteboardReadingOptions)readingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pboard {
    if ([type isEqualToString:kATVCanvasShapeElementUTI]) {
        return NSPasteboardReadingAsKeyedArchive;
    }
    
    return 0;
}

- (void)dealloc
{
    [super dealloc];
}

@end