//
//  ATVCanvasElement.h
//  Image Editor
//
//  Created by Артём Твердохлебов on 8/19/16.
//  Copyright © 2016 Артём Твердохлебов. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreImage/CoreImage.h>

@class ATVCanvasElement;

@protocol ATVCanvasElementDelegate <NSObject>
@optional
- (void)canvasElementFrameWillChange:(ATVCanvasElement *)element;
- (void)canvasElementFrameDidChange:(ATVCanvasElement *)element;

- (void)canvasElementSizeDidChange:(ATVCanvasElement *)element;

- (void)canvasElementPropertiesDidChange:(ATVCanvasElement *)element;

- (void)canvasElementRotationAngleDidChange:(ATVCanvasElement *)element;
- (void)canvasElementFiltersDidChange:(ATVCanvasElement *)element;
@end

@interface ATVCanvasElement : NSObject <NSCoding>
{
    NSRect _frame;
    CGFloat _opacity;
    CGFloat _rotationAngle;
}

@property NSRect frame;
@property (copy) NSArray<CIFilter *> *filters;

@property CGFloat opacity;
@property CGFloat rotationAngle;

- (NSRect)rotatedFrame;

@property (assign) id<ATVCanvasElementDelegate> delegate;

@property NSPoint frameOrigin;
@property NSSize frameSize;

- (void)offsetOriginByX:(CGFloat)x andY:(CGFloat)y;

- (void)addFilter:(CIFilter *)filter;
- (void)removeFilter:(CIFilter *)filter;

@end
