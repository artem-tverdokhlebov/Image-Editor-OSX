//
//  ATVDocumentWindowController.h
//  Image Editor
//
//  Created by Артём Твердохлебов on 8/20/16.
//  Copyright © 2016 Артём Твердохлебов. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ATVCanvasView.h"
#import "ATVCanvasModelController.h"

@interface ATVDocumentWindowController : NSWindowController <NSWindowDelegate, ATVCanvasViewDelegate, ATVCanvasElementDelegate>

- (instancetype)initWithCanvasModel:(ATVCanvasModelController *)modelController;

- (NSData *)canvasRepresentationUsingType:(NSBitmapImageFileType)imageType;

@end
