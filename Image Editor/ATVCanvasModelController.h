//
//  ATVCanvasModelController.h
//  Image Editor
//
//  Created by Артём Твердохлебов on 8/20/16.
//  Copyright © 2016 Артём Твердохлебов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATVCanvasElement.h"

@interface ATVCanvasModelController : NSObject <NSCoding>

@property (copy, readonly) NSArray<ATVCanvasElement *> *canvasElements;
@property NSSize canvasSize;

- (void)addCanvasElement:(ATVCanvasElement *)element;
- (void)removeCanvasElement:(ATVCanvasElement *)element;

@end
