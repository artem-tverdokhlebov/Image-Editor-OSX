//
//  ATVCanvasShapeElement.h
//  Image Editor
//
//  Created by Артём Твердохлебов on 8/24/16.
//  Copyright © 2016 Артём Твердохлебов. All rights reserved.
//

#import "ATVCanvasPrimitiveElement.h"

typedef NS_ENUM(NSInteger, ATVShapeType) {
    kATVRectangleShape,
    kATVCircleShape,
};

extern NSString *const kATVCanvasShapeElementUTI;

@interface ATVCanvasShapeElement : ATVCanvasPrimitiveElement <NSPasteboardWriting, NSPasteboardReading>

@property ATVShapeType shapeType;

- (instancetype)initWithShapeType:(ATVShapeType)shapeType;
- (instancetype)initWithShapeType:(ATVShapeType)shapeType frameOrigin:(NSPoint)aFrameOrigin;
- (instancetype)initWithShapeType:(ATVShapeType)shapeType frameSize:(NSSize)aFrameSize frameOrigin:(NSPoint)aFrameOrigin;

+ (instancetype)canvasShapeElementWithType:(ATVShapeType)shapeType frameOrigin:(NSPoint)aFrameOrigin;
+ (instancetype)canvasShapeElementWithType:(ATVShapeType)shapeType frameSize:(NSSize)aFrameSize frameOrigin:(NSPoint)aFrameOrigin;

@end
