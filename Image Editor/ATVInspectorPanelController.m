//
//  ATVInspectorPanelController.m
//  Image Editor
//
//  Created by Артём Твердохлебов on 8/22/16.
//  Copyright © 2016 Артём Твердохлебов. All rights reserved.
//

#import "ATVInspectorPanelController.h"

#import "ATVDocument.h"
#import "ATVDocumentWindowController.h"

#import "ATVCanvasShapeElement.h"
#import "ATVCanvasLineElement.h"

@interface ATVInspectorPanelController ()

@property (assign) CGFloat selectionOriginX;
@property (assign) CGFloat selectionOriginY;
@property (assign) CGFloat selectionSizeWidth;
@property (assign) CGFloat selectionSizeHeight;

@property (assign) NSColor *selectionColor;
@property NSUInteger selectionLineWidth;

@property CGFloat selectionOpacity;

@property CGFloat selectionRotationAngle;

@property (assign, readonly) BOOL isPrimitiveElement;

@property (assign) BOOL gaussianBlurFilter;
@property (assign) BOOL sepiaToneFilter;
@property (assign) BOOL colorInvertFilter;
@property (assign) BOOL colorPosterizeFilter;
@property (assign) BOOL photoEffectProcessFilter;
@property (assign) BOOL comicEffectFilter;
@property (assign) BOOL edgesFilter;
@property (assign) BOOL photoEffectInstantFilter;
@property (assign) BOOL colorMonochromeFilter;
@property (assign) BOOL motionBlurFilter;

@property (assign) ATVCanvasElement *currentElement;

@end

@implementation ATVInspectorPanelController

- (instancetype)init
{
    self = [super initWithWindowNibName:@"ATVInspectorPanel"];
    if (self)
    {
        
    }
    
    return self;
}

- (CGFloat)selectionOriginX
{
    return self.currentElement.frame.origin.x;
}

- (void)setSelectionOriginX:(CGFloat)selectionOriginX
{
    [[self.undoManager prepareWithInvocationTarget:self] setSelectionOriginX:self.currentElement.frame.origin.x];
    
    if (![self.undoManager isUndoing])
        [self.undoManager setActionName:@"Move Element"];
    
    [self.currentElement setFrameOrigin:NSMakePoint(selectionOriginX, self.currentElement.frame.origin.y)];
}

- (CGFloat)selectionOriginY
{
    return self.currentElement.frame.origin.y;
}

- (void)setSelectionOriginY:(CGFloat)selectionOriginY
{
    [[self.undoManager prepareWithInvocationTarget:self] setSelectionOriginY:self.currentElement.frame.origin.y];
    
    if (![self.undoManager isUndoing])
        [self.undoManager setActionName:@"Move Element"];
    
    self.currentElement.frameOrigin = NSMakePoint(self.currentElement.frameOrigin.x, selectionOriginY);
}

- (CGFloat)selectionSizeWidth
{
    return self.currentElement.frame.size.width;
}

- (void)setSelectionSizeWidth:(CGFloat)selectionSizeWidth
{
    [[self.undoManager prepareWithInvocationTarget:self] setSelectionSizeWidth:self.currentElement.frame.size.width];
    
    if (![self.undoManager isUndoing])
        [self.undoManager setActionName:@"Resize Element"];
    
    self.currentElement.frameSize = NSMakeSize(selectionSizeWidth, self.currentElement.frameSize.height);
}

- (CGFloat)selectionSizeHeight
{
    return self.currentElement.frame.size.height;
}

- (void)setSelectionSizeHeight:(CGFloat)selectionSizeHeight
{
    [[self.undoManager prepareWithInvocationTarget:self] setSelectionSizeHeight:self.currentElement.frame.size.height];
    
    if (![self.undoManager isUndoing])
        [self.undoManager setActionName:@"Resize Element"];
    
    self.currentElement.frameSize = NSMakeSize(self.currentElement.frameSize.width, selectionSizeHeight);
}

- (NSColor *)selectionColor
{
    if ([self.currentElement isKindOfClass:[ATVCanvasPrimitiveElement class]])
    {
        ATVCanvasPrimitiveElement *primitiveElement = (ATVCanvasPrimitiveElement *) self.currentElement;
        
        return primitiveElement.lineColor;
    }
    
    return nil;
}

- (void)setSelectionColor:(NSColor *)selectionColor
{
    [[self.undoManager prepareWithInvocationTarget:self] setSelectionColor:self.selectionColor];
    
    if (![self.undoManager isUndoing])
        [self.undoManager setActionName:@"Change Color"];
    
    if ([self.currentElement isKindOfClass:[ATVCanvasPrimitiveElement class]])
    {
        ATVCanvasPrimitiveElement *primitiveElement = (ATVCanvasPrimitiveElement *) self.currentElement;
        
        primitiveElement.lineColor = selectionColor;
    }
}

- (NSUInteger)selectionLineWidth
{
    if ([self.currentElement isKindOfClass:[ATVCanvasPrimitiveElement class]])
    {
        ATVCanvasPrimitiveElement *primitiveElement = (ATVCanvasPrimitiveElement *) self.currentElement;
        
        return primitiveElement.lineWidth;
    }
    
    return 0;
}

- (void)setSelectionLineWidth:(NSUInteger)selectionLineWidth
{
    [[self.undoManager prepareWithInvocationTarget:self] setSelectionLineWidth:self.selectionLineWidth];
    
    if (![self.undoManager isUndoing])
        [self.undoManager setActionName:@"Change Line Width"];
    
    if ([self.currentElement isKindOfClass:[ATVCanvasShapeElement class]])
    {
        ATVCanvasShapeElement *shapeElement = (ATVCanvasShapeElement *) self.currentElement;
        
        shapeElement.lineWidth = selectionLineWidth;
    }
    
    if ([self.currentElement isKindOfClass:[ATVCanvasLineElement class]])
    {
        ATVCanvasLineElement *lineElement = (ATVCanvasLineElement *) self.currentElement;
        
        lineElement.lineWidth = selectionLineWidth;
    }
}

- (CGFloat)selectionOpacity
{
    return self.currentElement.opacity;
}

- (void)setSelectionOpacity:(CGFloat)selectionOpacity
{
    [[self.undoManager prepareWithInvocationTarget:self] setSelectionOpacity:self.selectionOpacity];
    
    if (![self.undoManager isUndoing])
        [self.undoManager setActionName:@"Change Opacity"];
    
    self.currentElement.opacity = selectionOpacity;
}

- (CGFloat)selectionRotationAngle
{
    return self.currentElement.rotationAngle;
}

- (void)setSelectionRotationAngle:(CGFloat)selectionRotationAngle
{
    [[self.undoManager prepareWithInvocationTarget:self] setSelectionRotationAngle:self.selectionRotationAngle];
    
    if (![self.undoManager isUndoing])
        [self.undoManager setActionName:@"Change Opacity"];
    
    self.currentElement.rotationAngle = selectionRotationAngle;
}

#pragma mark Filters Properties

- (BOOL)gaussianBlurFilter
{
    return [self isFilterApplied:@"CIGaussianBlur"];
}

- (void)setGaussianBlurFilter:(BOOL)gaussianBlurFilter
{
    [[self.undoManager prepareWithInvocationTarget:self] setGaussianBlurFilter:!gaussianBlurFilter];
    
    if (![self.undoManager isUndoing])
        [self.undoManager setActionName:@"Change Filter"];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur" keysAndValues:@"inputRadius", [NSNumber numberWithFloat:4.0], nil];
    
    if (gaussianBlurFilter)
    {
        [self.currentElement addFilter:filter];
    }
    else
    {
        [self.currentElement removeFilter:filter];
    }
}

- (BOOL)sepiaToneFilter
{
    return [self isFilterApplied:@"CISepiaTone"];
}

- (void)setSepiaToneFilter:(BOOL)sepiaToneFilter
{
    [[self.undoManager prepareWithInvocationTarget:self] setSepiaToneFilter:!sepiaToneFilter];
    
    if (![self.undoManager isUndoing])
        [self.undoManager setActionName:@"Change Filter"];
    
    CIFilter *filter = [CIFilter filterWithName:@"CISepiaTone" keysAndValues:kCIInputIntensityKey, [NSNumber numberWithFloat:5.0], nil];
    
    if (sepiaToneFilter)
    {
        [self.currentElement addFilter:filter];
    }
    else
    {
        [self.currentElement removeFilter:filter];
    }
}

- (BOOL)colorInvertFilter
{
    return [self isFilterApplied:@"CIColorInvert"];
}

- (void)setColorInvertFilter:(BOOL)colorInvertFilter
{
    [[self.undoManager prepareWithInvocationTarget:self] setColorInvertFilter:!colorInvertFilter];
    
    if (![self.undoManager isUndoing])
        [self.undoManager setActionName:@"Change Filter"];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIColorInvert"];
    
    if (colorInvertFilter)
    {
        [self.currentElement addFilter:filter];
    }
    else
    {
        [self.currentElement removeFilter:filter];
    }
}

- (BOOL)colorPosterizeFilter
{
    return [self isFilterApplied:@"CIColorPosterize"];
}

- (void)setColorPosterizeFilter:(BOOL)colorPosterizeFilter
{
    [[self.undoManager prepareWithInvocationTarget:self] setColorPosterizeFilter:!colorPosterizeFilter];
    
    if (![self.undoManager isUndoing])
        [self.undoManager setActionName:@"Change Filter"];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIColorPosterize"];
    
    if (colorPosterizeFilter)
    {
        [self.currentElement addFilter:filter];
    }
    else
    {
        [self.currentElement removeFilter:filter];
    }
}

- (BOOL)photoEffectProcessFilter
{
    return [self isFilterApplied:@"CIPhotoEffectProcess"];
}

- (void)setPhotoEffectProcessFilter:(BOOL)photoEffectProcessFilter
{
    [[self.undoManager prepareWithInvocationTarget:self] setPhotoEffectProcessFilter:!photoEffectProcessFilter];
    
    if (![self.undoManager isUndoing])
        [self.undoManager setActionName:@"Change Filter"];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIPhotoEffectProcess"];
    
    if (photoEffectProcessFilter)
    {
        [self.currentElement addFilter:filter];
    }
    else
    {
        [self.currentElement removeFilter:filter];
    }
}

- (BOOL)comicEffectFilter
{
    return [self isFilterApplied:@"CIComicEffect"];
}

- (void)setComicEffectFilter:(BOOL)comicEffectFilter
{
    [[self.undoManager prepareWithInvocationTarget:self] setComicEffectFilter:!comicEffectFilter];
    
    if (![self.undoManager isUndoing])
        [self.undoManager setActionName:@"Change Filter"];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIComicEffect"];
    
    if (comicEffectFilter)
    {
        [self.currentElement addFilter:filter];
    }
    else
    {
        [self.currentElement removeFilter:filter];
    }
}

- (BOOL)edgesFilter
{
    return [self isFilterApplied:@"CIEdges"];
}

- (void)setEdgesFilter:(BOOL)edgesFilter
{
    [[self.undoManager prepareWithInvocationTarget:self] setEdgesFilter:!edgesFilter];
    
    if (![self.undoManager isUndoing])
        [self.undoManager setActionName:@"Change Filter"];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIEdges"];
    
    if (edgesFilter)
    {
        [self.currentElement addFilter:filter];
    }
    else
    {
        [self.currentElement removeFilter:filter];
    }
}

- (BOOL)photoEffectInstantFilter
{
    return [self isFilterApplied:@"CIPhotoEffectInstant"];
}

- (void)setPhotoEffectInstantFilter:(BOOL)photoEffectInstantFilter
{
    [[self.undoManager prepareWithInvocationTarget:self] setPhotoEffectInstantFilter:!photoEffectInstantFilter];
    
    if (![self.undoManager isUndoing])
        [self.undoManager setActionName:@"Change Filter"];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIPhotoEffectInstant"];
    
    if (photoEffectInstantFilter)
    {
        [self.currentElement addFilter:filter];
    }
    else
    {
        [self.currentElement removeFilter:filter];
    }
}

- (BOOL)colorMonochromeFilter
{
    return [self isFilterApplied:@"CIColorMonochrome"];
}

- (void)setColorMonochromeFilter:(BOOL)colorMonochromeFilter
{
    [[self.undoManager prepareWithInvocationTarget:self] setColorMonochromeFilter:!colorMonochromeFilter];
    
    if (![self.undoManager isUndoing])
        [self.undoManager setActionName:@"Change Filter"];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIColorMonochrome" withInputParameters:@{kCIInputColorKey : [CIColor colorWithRed:0 green:1 blue:0]}];
    
    if (colorMonochromeFilter)
    {
        [self.currentElement addFilter:filter];
    }
    else
    {
        [self.currentElement removeFilter:filter];
    }
}

- (BOOL)motionBlurFilter
{
    return [self isFilterApplied:@"CIMotionBlur"];
}

- (void)setMotionBlurFilter:(BOOL)motionBlurFilter
{
    [[self.undoManager prepareWithInvocationTarget:self] setMotionBlurFilter:!motionBlurFilter];
    
    if (![self.undoManager isUndoing])
        [self.undoManager setActionName:@"Change Filter"];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIMotionBlur"];
    
    if (motionBlurFilter)
    {
        [self.currentElement addFilter:filter];
    }
    else
    {
        [self.currentElement removeFilter:filter];
    }
}

- (BOOL)isFilterApplied:(NSString *)filterName
{
    for (CIFilter *filter in self.currentElement.filters)
    {
        if ([filter.name isEqualToString:filterName])
        {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)isPrimitiveElement
{
    return [self.currentElement isKindOfClass:[ATVCanvasPrimitiveElement class]];
}

+ (NSSet *)keyPathsForValuesAffectingSelectionColor
{
    return [NSSet setWithObjects:@"currentElement.lineColor", nil];
}

+ (NSSet *)keyPathsForValuesAffectingSelectionLineWidth
{
    return [NSSet setWithObjects:@"currentElement.lineWidth", nil];
}

+ (NSSet *)keyPathsForValuesAffectingSelectionOpacity
{
    return [NSSet setWithObjects:@"currentElement.opacity", nil];
}

+ (NSSet *)keyPathsForValuesAffectingSelectionRotationAngle
{
    return [NSSet setWithObjects:@"currentElement.rotationAngle", nil];
}

#pragma mark KeyPaths Affecting Selection Frame

+ (NSSet *)keyPathsForValuesAffectingSelectionOriginX
{
    return [NSSet setWithObjects:@"currentElement.frame", nil];
}

+ (NSSet *)keyPathsForValuesAffectingSelectionOriginY
{
    return [NSSet setWithObjects:@"currentElement.frame", nil];
}

+ (NSSet *)keyPathsForValuesAffectingSelectionSizeWidth
{
    return [NSSet setWithObjects:@"currentElement.frame", nil];
}

+ (NSSet *)keyPathsForValuesAffectingSelectionSizeHeight
{
    return [NSSet setWithObjects:@"currentElement.frame", nil];
}

#pragma mark KeyPaths Affecting Filters

+ (NSSet *)keyPathsForValuesAffectingGaussianBlurFilter
{
    return [NSSet setWithObjects:@"currentElement.filters", nil];
}

+ (NSSet *)keyPathsForValuesAffectingSepiaToneFilter
{
    return [NSSet setWithObjects:@"currentElement.filters", nil];
}

+ (NSSet *)keyPathsForValuesAffectingColorInvertFilter
{
    return [NSSet setWithObjects:@"currentElement.filters", nil];
}

+ (NSSet *)keyPathsForValuesAffectingColorPosterizeFilter
{
    return [NSSet setWithObjects:@"currentElement.filters", nil];
}

+ (NSSet *)keyPathsForValuesAffectingPhotoEffectProcessFilter
{
    return [NSSet setWithObjects:@"currentElement.filters", nil];
}

+ (NSSet *)keyPathsForValuesAffectingComicEffectFilter
{
    return [NSSet setWithObjects:@"currentElement.filters", nil];
}

+ (NSSet *)keyPathsForValuesAffectingEdgesFilter
{
    return [NSSet setWithObjects:@"currentElement.filters", nil];
}

+ (NSSet *)keyPathsForValuesAffectingPhotoEffectInstantFilter
{
    return [NSSet setWithObjects:@"currentElement.filters", nil];
}

+ (NSSet *)keyPathsForValuesAffectingColorMonochromeFilter
{
    return [NSSet setWithObjects:@"currentElement.filters", nil];
}

+ (NSSet *)keyPathsForValuesAffectingMotionBlurFilter
{
    return [NSSet setWithObjects:@"currentElement.filters", nil];
}

- (void)tooglePanel
{
    if (self.window.visible)
    {
        [[self window] close];
    }
    else
    {
        [[self window] orderFront:self];
    }
}

- (NSUndoManager *)undoManager
{
    return [[[NSDocumentController sharedDocumentController] currentDocument] undoManager];
}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return self.undoManager;
}

- (void)dealloc
{
    [super dealloc];
}

@end
