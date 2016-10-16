//
//  ATVCanvasLineElement.h
//  Image Editor
//
//  Created by Артём Твердохлебов on 8/24/16.
//  Copyright © 2016 Артём Твердохлебов. All rights reserved.
//

#import "ATVCanvasPrimitiveElement.h"

extern NSString *const kATVCanvasLineElementUTI;

@interface ATVCanvasLineElement : ATVCanvasPrimitiveElement <NSPasteboardWriting, NSPasteboardReading>

@property (assign, readonly) NSPoint firstPoint;
@property (assign, readonly) NSPoint secondPoint;

- (NSPoint)firstPointInRect:(NSRect)frame;
- (NSPoint)secondPointInRect:(NSRect)frame;

- (instancetype)initWithFirstPoint:(NSPoint)firstPoint secondPoint:(NSPoint)secondPoint;

+ (instancetype)canvasLineElementWithFirstPoint:(NSPoint)firstPoint secondPoint:(NSPoint)secondPoint;

@end
