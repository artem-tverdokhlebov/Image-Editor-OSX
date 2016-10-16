//
//  ATVCanvasImageElement.h
//  Image Editor
//
//  Created by Артём Твердохлебов on 8/20/16.
//  Copyright © 2016 Артём Твердохлебов. All rights reserved.
//

#import "ATVCanvasElement.h"

extern NSString *const kATVCanvasImageElementUTI;

@interface ATVCanvasImageElement : ATVCanvasElement <NSPasteboardWriting, NSPasteboardReading>
{
    NSImage *_image;
}

@property (retain, readonly) NSImage *image;

- (instancetype)initWithImage:(NSImage *)anImage;
- (instancetype)initWithImage:(NSImage *)anImage frameOrigin:(NSPoint)aFrameOrigin;
- (instancetype)initWithImage:(NSImage *)anImage frameSize:(NSSize)aFrameSize frameOrigin:(NSPoint)aFrameOrigin;

+ (instancetype)canvasImageElementWithImage:(NSImage *)anImage frameOrigin:(NSPoint)aFrameOrigin;
+ (instancetype)canvasImageElementWithImage:(NSImage *)anImage frameSize:(NSSize)aFrameSize frameOrigin:(NSPoint)aFrameOrigin;

@end
