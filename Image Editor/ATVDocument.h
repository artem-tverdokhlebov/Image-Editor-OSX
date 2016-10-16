//
//  Document.h
//  Image Editor
//
//  Created by Артём Твердохлебов on 8/19/16.
//  Copyright © 2016 Артём Твердохлебов. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ATVDocumentWindowController.h"
#import "ATVCanvasView.h"
#import "ATVCanvasImageElement.h"


@interface ATVDocument : NSDocument

@property (assign) ATVDocumentWindowController *windowController;

@property (retain) ATVCanvasModelController *modelController;

@end

