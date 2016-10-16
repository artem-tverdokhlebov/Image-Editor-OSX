//
//  ATVCanvas.h
//  Image Editor
//
//  Created by Артём Твердохлебов on 8/20/16.
//  Copyright © 2016 Артём Твердохлебов. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ATVCanvasModelController.h"
#import "ATVCanvasImageElement.h"
#import "ATVCanvasShapeElement.h"
#import "ATVCanvasLineElement.h"

typedef NS_ENUM(NSInteger, ATVDrawingMode) {
    kATVPointerMode,
    kATVDrawRectangleMode,
    kATVDrawCircleMode,
    kATVDrawLineMode
};

extern NSString *const kATVCanvasViewSelectionChanged;

@class ATVCanvasViewDelegate;

@protocol ATVCanvasViewDelegate <NSObject>
- (void)addCanvasElement:(ATVCanvasElement *)canvasElement;
- (void)deleteCanvasElement:(ATVCanvasElement *)canvasElement;
@end

@interface ATVCanvasView : NSView

@property (assign) id<ATVCanvasViewDelegate> delegate;

@property (assign) ATVCanvasElement *selectedCanvasElement;
@property (retain) ATVCanvasModelController *modelController;

- (NSData *)imageRepresentationUsingType:(NSBitmapImageFileType)imageType;

- (void)invalidateFilteredImageForElement:(ATVCanvasElement *)element;

@end