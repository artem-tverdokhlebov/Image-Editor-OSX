//
//  ATVCanvasImageElement.m
//  Image Editor
//
//  Created by Артём Твердохлебов on 8/20/16.
//  Copyright © 2016 Артём Твердохлебов. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "ATVCanvasImageElement.h"

NSString *const kATVCanvasImageElementImage = @"ATVCanvasImageElementImage";

NSString *const kATVCanvasImageElementUTI = @"com.atverd.image-editor.canvasImageElement";

@interface ATVCanvasImageElement()
@property (retain, readwrite) NSImage *image;
@end

@implementation ATVCanvasImageElement

- (instancetype)initWithImage:(NSImage *)anImage
{
    return [self initWithImage:anImage frameSize:anImage.size frameOrigin:NSMakePoint(0, 0)];
}

- (instancetype)initWithImage:(NSImage *)anImage frameOrigin:(NSPoint)aFrameOrigin
{
    return [self initWithImage:anImage frameSize:anImage.size frameOrigin:aFrameOrigin];
}

- (instancetype)initWithImage:(NSImage *)anImage frameSize:(NSSize)aFrameSize frameOrigin:(NSPoint)aFrameOrigin
{
    self = [super init];
    if (self)
    {
        _image = [anImage retain];
        
        _frame.size = aFrameSize;
        _frame.origin = aFrameOrigin;
    }
    
    return self;
}

+ (instancetype)canvasImageElementWithImage:(NSImage *)anImage frameSize:(NSSize)aFrameSize frameOrigin:(NSPoint)aFrameOrigin
{
    return [[[self alloc] initWithImage:anImage frameSize:aFrameSize frameOrigin:aFrameOrigin] autorelease];
}

+ (instancetype)canvasImageElementWithImage:(NSImage *)anImage frameOrigin:(NSPoint)aFrameOrigin
{
    return [[[self alloc] initWithImage:anImage frameOrigin:aFrameOrigin] autorelease];
}

#pragma mark Coding Protocol Implementation

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        _image = [[coder decodeObjectForKey:kATVCanvasImageElementImage] retain];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_image forKey:kATVCanvasImageElementImage];
}

#pragma mark Pasteboard Writing Protocol

- (NSArray<NSString *> *)writableTypesForPasteboard:(NSPasteboard *)pasteboard
{
    return @[kATVCanvasImageElementUTI];
}

- (id)pasteboardPropertyListForType:(NSString *)type
{
    if ([type isEqualToString:kATVCanvasImageElementUTI])
    {
        return [NSKeyedArchiver archivedDataWithRootObject:self];
    }
    
    return nil;
}

#pragma mark Pasteboard Reading Protocol

+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard
{
    return @[kATVCanvasImageElementUTI];
}

+ (NSPasteboardReadingOptions)readingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pboard {
    if ([type isEqualToString:kATVCanvasImageElementUTI]) {
        return NSPasteboardReadingAsKeyedArchive;
    }

    return 0;
}

- (void)dealloc
{
    [_image release];
    [super dealloc];
}

@end
