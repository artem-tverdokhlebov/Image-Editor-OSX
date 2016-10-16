//
//  ATVCanvas.m
//  Image Editor
//
//  Created by Артём Твердохлебов on 8/20/16.
//  Copyright © 2016 Артём Твердохлебов. All rights reserved.
//

#import "ATVCanvasView.h"
#import "ATVCanvasImageElement.h"
#import "ATVCanvasShapeElement.h"
#import "ATVCanvasLineElement.h"

NSString *const kATVCanvasViewSelectionChanged = @"ATVCanvasViewSelectionChanged";

@interface ATVCanvasView()
{
@private
    NSCache *_filteredImagesCache;
    ATVCanvasModelController *_modelController;
    ATVCanvasElement *_selectedCanvasElement;
}

@property (assign) ATVDrawingMode drawingMode;

@property (assign) NSPoint originPoint;

@property (assign) NSPoint dragOffsetPoint;
@property (assign) NSRect newRect;

@property (assign) NSPoint firstPoint;
@property (assign) NSPoint secondPoint;

@property (retain, readonly) NSCache *filteredImagesCache;

@end

@implementation ATVCanvasView

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (BOOL)becomeFirstResponder
{
    return YES;
}

- (instancetype)initWithCanvasModel:(ATVCanvasModelController *)modelController
{
    self = [super init];
    if (self)
    {
        _modelController = [modelController retain];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [self registerForDraggedTypes:@[NSTIFFPboardType, NSFilenamesPboardType]];
}

- (ATVCanvasElement *)selectedCanvasElement
{
    return _selectedCanvasElement;
}

- (void)setSelectedCanvasElement:(ATVCanvasElement *)selectedCanvasElement
{
    if (_selectedCanvasElement != selectedCanvasElement)
    {
        _selectedCanvasElement = selectedCanvasElement;
        
        self.needsDisplay = YES;
    }
}

- (NSCache *)filteredImagesCache
{
    if (_filteredImagesCache == nil)
    {
        _filteredImagesCache = [[NSCache alloc] init];
    }
    
    return _filteredImagesCache;
}

- (NSUndoManager *)undoManager
{
    return [[[NSDocumentController sharedDocumentController] currentDocument] undoManager];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    [[NSColor whiteColor] setFill];
    NSRectFill(dirtyRect);
    
    for (ATVCanvasElement *element in self.modelController.canvasElements)
    {
        if (element == self.selectedCanvasElement)
        {
            [NSGraphicsContext saveGraphicsState];
            
            NSSetFocusRingStyle(NSFocusRingOnly);
            
            NSRect elementFrame = NSZeroRect;
            
            if (element.rotationAngle == 0)
            {
                elementFrame = element.frame;
            }
            else
            {
                elementFrame = [element rotatedFrame];
            }
            
            [[NSBezierPath bezierPathWithRect: NSInsetRect(elementFrame, -1, -1)] fill];
            
            [NSGraphicsContext restoreGraphicsState];
        }
        
        if (element.filters.count > 0)
        {
            NSImage *filteredImage = [self filteredImageForElement:element];
            
            if (filteredImage)
            {
                NSAffineTransform *rotate = [[NSAffineTransform alloc] init];
                NSGraphicsContext *context = [NSGraphicsContext currentContext];
                
                [context saveGraphicsState];
                [rotate translateXBy:element.frame.origin.x + (element.frame.size.width / 2) yBy:element.frame.origin.y + (element.frame.size.height / 2)];
                [rotate rotateByDegrees:element.rotationAngle];
                [rotate translateXBy:-(element.frame.origin.x + (element.frame.size.width / 2)) yBy:-(element.frame.origin.y + (element.frame.size.height / 2))];
                
                [rotate concat];
                
                [filteredImage drawInRect:element.frame fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1 respectFlipped:YES hints:nil];
                
                [rotate release];
                [context restoreGraphicsState];
                
                continue;
            }
        }
        
        if ([element isKindOfClass:[ATVCanvasImageElement class]])
        {
            ATVCanvasImageElement *imageElement = (ATVCanvasImageElement *) element;
            
            NSAffineTransform *rotate = [[NSAffineTransform alloc] init];
            NSGraphicsContext *context = [NSGraphicsContext currentContext];
            
            [context saveGraphicsState];
            [rotate translateXBy:imageElement.frame.origin.x + (imageElement.frame.size.width / 2) yBy:imageElement.frame.origin.y + (imageElement.frame.size.height / 2)];
            [rotate rotateByDegrees:imageElement.rotationAngle];
            [rotate translateXBy:-(element.frame.origin.x + (imageElement.frame.size.width / 2)) yBy:-(imageElement.frame.origin.y + (imageElement.frame.size.height / 2))];
            
            [rotate concat];
            
            [imageElement.image drawInRect:imageElement.frame fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:imageElement.opacity respectFlipped:YES hints:nil];
            
            [rotate release];
            [context restoreGraphicsState];
            
            continue;
        }
        
        if ([element isKindOfClass:[ATVCanvasShapeElement class]])
        {
            ATVCanvasShapeElement *shapeElement = (ATVCanvasShapeElement *) element;
            
            [self drawCanvasShapeElement:shapeElement inRect:shapeElement.frame rotated:YES];
        }
        
        if ([element isKindOfClass:[ATVCanvasLineElement class]])
        {
            ATVCanvasLineElement *lineElement = (ATVCanvasLineElement *) element;
            
            [self drawCanvasLineElement:lineElement inRect:lineElement.frame rotated:YES];
        }
    }
    
    if (self.drawingMode == kATVDrawRectangleMode)
    {
        NSBezierPath *rectPath = [NSBezierPath bezierPath];
        [rectPath appendBezierPathWithRect:self.newRect];
        [rectPath stroke];
    }
    
    if (self.drawingMode == kATVDrawCircleMode)
    {
        NSBezierPath *rectPath = [NSBezierPath bezierPath];
        [rectPath appendBezierPathWithOvalInRect:self.newRect];
        [rectPath stroke];
    }
    
    if (self.drawingMode == kATVDrawLineMode)
    {
        NSBezierPath *rectPath = [NSBezierPath bezierPath];
        [rectPath moveToPoint:self.firstPoint];
        [rectPath lineToPoint:self.secondPoint];
        [rectPath stroke];
    }
}

#pragma mark Elements Draw Methods

- (void)drawCanvasShapeElement:(ATVCanvasShapeElement *)element inRect:(NSRect)frame rotated:(BOOL)rotated
{
    [[element.lineColor colorWithAlphaComponent:element.opacity] setStroke];
    
    NSBezierPath *shapePath = [NSBezierPath bezierPath];
    
    if (element.shapeType == kATVRectangleShape)
    {
        [shapePath appendBezierPathWithRect:frame];
    }
    else if (element.shapeType == kATVCircleShape)
    {
        [shapePath appendBezierPathWithOvalInRect:frame];
    }
    
    if (rotated)
        if (element.rotationAngle != 0)
        {
            NSAffineTransform *rotationTransform = [NSAffineTransform transform];
            
            [rotationTransform translateXBy:frame.origin.x + (frame.size.width / 2) yBy:frame.origin.y + (frame.size.height / 2)];
            [rotationTransform rotateByDegrees:element.rotationAngle];
            [rotationTransform translateXBy:-(frame.origin.x + (frame.size.width / 2)) yBy:-(frame.origin.y + (frame.size.height / 2))];
            
            [shapePath transformUsingAffineTransform:rotationTransform];
        }
    
    [shapePath setLineWidth:element.lineWidth];
    
    [shapePath stroke];
}

- (void)drawCanvasLineElement:(ATVCanvasLineElement *)element inRect:(NSRect)frame rotated:(BOOL)rotated
{
    [[element.lineColor colorWithAlphaComponent:element.opacity] setStroke];
    
    NSBezierPath *rectPath = [NSBezierPath bezierPath];
    
    [rectPath moveToPoint:[element firstPointInRect:frame]];
    [rectPath lineToPoint:[element secondPointInRect:frame]];
    
    if (rotated)
    {
        if (element.rotationAngle != 0)
        {
            NSAffineTransform *rotationTransform = [NSAffineTransform transform];
            
            [rotationTransform translateXBy:frame.origin.x + (frame.size.width / 2) yBy:frame.origin.y + (frame.size.height / 2)];
            [rotationTransform rotateByDegrees:element.rotationAngle];
            [rotationTransform translateXBy:-(frame.origin.x + (frame.size.width / 2)) yBy:-(frame.origin.y + (frame.size.height / 2))];
            
            [rectPath transformUsingAffineTransform:rotationTransform];
        }
    }
    
    [rectPath setLineWidth:element.lineWidth];
    
    [rectPath stroke];
}

#pragma mark Drag & Drop

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    NSPasteboard *draggingPasteboard = [sender draggingPasteboard];
    
    NSString *desiredType = [draggingPasteboard availableTypeFromArray:@[NSPasteboardTypeTIFF, NSFilenamesPboardType]];
    
    if (desiredType != nil)
    {
        return NSDragOperationCopy;
    }
    else
    {
        return NSDragOperationNone;
    }
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender
{
    return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    NSPasteboard *draggingPasteboard = [sender draggingPasteboard];
    
    NSString *desiredType = [draggingPasteboard availableTypeFromArray:@[NSPasteboardTypeTIFF, NSFilenamesPboardType]];
    
    if ([desiredType isEqualToString:NSPasteboardTypeTIFF])
    {
        NSData *pasteboardData = [draggingPasteboard dataForType:desiredType];
        
        if (pasteboardData == nil)
        {
            return NO;
        }
        
        NSImage *imageFromPasteboard = [[[NSImage alloc] initWithData:pasteboardData] autorelease];
        
        NSPoint imageOrigin = [self convertPoint:[sender draggingLocation] fromView:nil];
        
        imageOrigin.x -= imageFromPasteboard.size.width / 2;
        imageOrigin.y -= imageFromPasteboard.size.height / 2;
        
        ATVCanvasImageElement *imageElement = [ATVCanvasImageElement canvasImageElementWithImage:imageFromPasteboard frameOrigin:imageOrigin];
        
        imageElement.delegate = self.window.windowController;
        
        [self.delegate addCanvasElement:imageElement];
        
        return YES;
    }
    
    if ([desiredType isEqualToString:NSFilenamesPboardType])
    {
        NSArray *filePathArray = [draggingPasteboard propertyListForType:NSFilenamesPboardType];
        NSString *filePath = [filePathArray objectAtIndex:0];
        NSImage *imageFromFile = [[[NSImage alloc] initWithContentsOfFile:filePath] autorelease];
        
        if (imageFromFile == nil)
        {
            return NO;
        }
        
        NSPoint imageOrigin = [self convertPoint:[sender draggingLocation] fromView:nil];
        
        imageOrigin.x -= imageFromFile.size.width / 2;
        imageOrigin.y -= imageFromFile.size.height / 2;
        
        ATVCanvasImageElement *imageElement = [ATVCanvasImageElement canvasImageElementWithImage:imageFromFile frameOrigin:imageOrigin];
        
        imageElement.delegate = self.window.windowController;
        
        [self.delegate addCanvasElement:imageElement];
        
        return YES;
    }
    
    return NO;
}

#pragma Mouse Events

- (void)mouseDown:(NSEvent *)theEvent
{
    NSPoint mouseLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    self.originPoint = mouseLocation;
    
    if (self.drawingMode == kATVPointerMode)
    {
        for(ATVCanvasElement *element in [self.modelController.canvasElements reverseObjectEnumerator])
        {
            NSRect elementFrame = NSZeroRect;
            
            if (element.rotationAngle == 0)
            {
                elementFrame = element.frame;
            }
            else
            {
                elementFrame = [element rotatedFrame];
            }
            
            if (NSPointInRect(mouseLocation, elementFrame))
            {
                self.selectedCanvasElement = element;
                
                self.dragOffsetPoint = NSMakePoint(self.originPoint.x - self.selectedCanvasElement.frame.origin.x, self.originPoint.y - self.selectedCanvasElement.frame.origin.y);
                
                return;
            }
        }
        
        self.selectedCanvasElement = nil;
    }
    else if (self.drawingMode == kATVDrawRectangleMode || self.drawingMode == kATVDrawCircleMode)
    {
        self.newRect = NSMakeRect(mouseLocation.x, mouseLocation.y, 0, 0);
    }
    else if (self.drawingMode == kATVDrawLineMode)
    {
        self.firstPoint = mouseLocation;
    }
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    NSPoint mouseLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    if (self.drawingMode == kATVPointerMode)
    {
        NSPoint dragPoint = NSMakePoint(mouseLocation.x - self.dragOffsetPoint.x, mouseLocation.y - self.dragOffsetPoint.y);
        [self.selectedCanvasElement setFrameOrigin:dragPoint];
    }
    else if (self.drawingMode == kATVDrawRectangleMode || self.drawingMode == kATVDrawCircleMode)
    {
        if (mouseLocation.x - self.originPoint.x > 0 && mouseLocation.y - self.originPoint.y > 0)
        {
            self.newRect = NSMakeRect(self.originPoint.x, self.originPoint.y, mouseLocation.x - self.originPoint.x, mouseLocation.y - self.originPoint.y);
        }
        else if (mouseLocation.x - self.originPoint.x < 0 && mouseLocation.y - self.originPoint.y < 0)
        {
            self.newRect = NSMakeRect(mouseLocation.x, mouseLocation.y, self.originPoint.x - mouseLocation.x, self.originPoint.y - mouseLocation.y);
        }
        else if (mouseLocation.x - self.originPoint.x < 0 && mouseLocation.y - self.originPoint.y > 0)
        {
            self.newRect = NSMakeRect(mouseLocation.x, self.originPoint.y, self.originPoint.x - mouseLocation.x, mouseLocation.y - self.originPoint.y);
        }
        else if (mouseLocation.x - self.originPoint.x > 0 && mouseLocation.y - self.originPoint.y < 0)
        {
            self.newRect = NSMakeRect(self.originPoint.x, mouseLocation.y, mouseLocation.x - self.originPoint.x, self.originPoint.y - mouseLocation.y);
        }
    }
    else if (self.drawingMode == kATVDrawLineMode)
    {
        self.secondPoint = mouseLocation;
    }
    
    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    NSPoint mouseLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    if (self.originPoint.x == mouseLocation.x && self.originPoint.y == mouseLocation.y)
        return;
    
    if (self.drawingMode == kATVPointerMode)
    {
        NSPoint originDragPoint = NSMakePoint(self.originPoint.x - self.dragOffsetPoint.x, self.originPoint.y - self.dragOffsetPoint.y);
        
        [[self.undoManager prepareWithInvocationTarget:self] moveElement:self.selectedCanvasElement to:originDragPoint];
        
        if(![self.undoManager isUndoing])
            [self.undoManager setActionName:@"Move Element"];
    }
    
    if (self.drawingMode == kATVDrawRectangleMode || self.drawingMode == kATVDrawCircleMode)
    {
        ATVShapeType shapeType;
        
        if (self.drawingMode == kATVDrawRectangleMode)
        {
            shapeType = kATVRectangleShape;
        }
        else if (self.drawingMode == kATVDrawCircleMode)
        {
            shapeType = kATVCircleShape;
        }
        
        ATVCanvasShapeElement *shapeElement = [ATVCanvasShapeElement canvasShapeElementWithType:shapeType frameSize:self.newRect.size frameOrigin:self.newRect.origin];
        
        shapeElement.delegate = self.window.windowController;
        
        self.newRect = NSZeroRect;
        
        [self.delegate addCanvasElement:shapeElement];
    }
    
    if (self.drawingMode == kATVDrawLineMode)
    {
        self.secondPoint = mouseLocation;
        
        ATVCanvasLineElement *lineElement = [ATVCanvasLineElement canvasLineElementWithFirstPoint:self.firstPoint secondPoint:self.secondPoint];
        
        lineElement.delegate = self.window.windowController;
        
        self.firstPoint = NSZeroPoint;
        self.secondPoint = NSZeroPoint;
        
        [self.delegate addCanvasElement:lineElement];
    }
}

- (void)moveElement:(ATVCanvasElement *)element to:(NSPoint)location
{
    [[self.undoManager prepareWithInvocationTarget:self] moveElement:element to:element.frame.origin];
    
    if(![self.undoManager isUndoing])
        [self.undoManager setActionName:@"Move Element"];
    
    [element setFrameOrigin:location];
}

#pragma mark Actions

- (IBAction)delete:(id)sender
{
    if (self.selectedCanvasElement)
    {
        ATVCanvasElement *selectedElement = self.selectedCanvasElement;
        
        [self.delegate deleteCanvasElement:selectedElement];
    }
}

- (NSData *)imageRepresentationUsingType:(NSBitmapImageFileType)imageType
{
    ATVCanvasElement *selectedElement = self.selectedCanvasElement;
    
    self.selectedCanvasElement = nil;
    
    [self display];
    
    [self lockFocus];
    NSBitmapImageRep *representation = [[[NSBitmapImageRep alloc] initWithFocusedViewRect:[self bounds]] autorelease];
    [self unlockFocus];
    
    self.selectedCanvasElement = selectedElement;
    
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:0.8] forKey:NSImageCompressionFactor];
    
    return [representation representationUsingType:imageType properties:imageProps];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    if (menuItem.action == @selector(delete:))
    {
        return !!self.selectedCanvasElement;
    }
    
    return YES;
}

- (void)applyFiltersToElement:(ATVCanvasElement *)element
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CIImage *inputImage = nil;
        if ([element isKindOfClass:[ATVCanvasImageElement class]])
        {
            ATVCanvasImageElement *imageElement = (ATVCanvasImageElement *) element;
            
            NSImage *sourceImage = imageElement.image;
            NSImage *resizedImage = [[[NSImage alloc] initWithSize: imageElement.frameSize] autorelease];
            
            [resizedImage lockFocus];
            [sourceImage setSize:imageElement.frameSize];
            [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
            [sourceImage drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.];
            [resizedImage unlockFocus];
            
            inputImage = [[[CIImage alloc] initWithData:[resizedImage TIFFRepresentation]] autorelease];
        }
        else
        {
            NSImage *bezierPathImage = [[NSImage alloc] initWithSize:element.frame.size];
            
            [bezierPathImage lockFocus];
            
            if ([element isKindOfClass:[ATVCanvasShapeElement class]])
            {
                ATVCanvasShapeElement *shapeElement = (ATVCanvasShapeElement *) element;
                [self drawCanvasShapeElement:shapeElement inRect:NSMakeRect(0, 0, shapeElement.frameSize.width, shapeElement.frameSize.height) rotated:NO];
            }
            else if ([element isKindOfClass:[ATVCanvasLineElement class]])
            {
                ATVCanvasLineElement *lineElement = (ATVCanvasLineElement *) element;
                [self drawCanvasLineElement:lineElement inRect:NSMakeRect(0, 0, lineElement.frame.size.width, lineElement.frame.size.height) rotated:NO];
            }
            
            [bezierPathImage unlockFocus];
            
            inputImage = [[[CIImage alloc] initWithData:[bezierPathImage TIFFRepresentation]] autorelease];
            
            [bezierPathImage release];
        }
        
        CIImage *filteredImage = inputImage;
        
        for (CIFilter *filter in element.filters)
        {
            [filter setValue:filteredImage forKey:kCIInputImageKey];
            
            filteredImage = [[filter valueForKey:kCIOutputImageKey] imageByCroppingToRect:CGRectMake(0, 0, element.frameSize.width, element.frameSize.height)];
        }
        
        NSCIImageRep *rep = [NSCIImageRep imageRepWithCIImage:filteredImage];
        NSImage *image = [[[NSImage alloc] initWithSize:element.frameSize] autorelease];
        [image addRepresentation:rep];
        
        [self.filteredImagesCache setObject:image forKey:element];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.needsDisplay = YES;
        });
    });
}

- (NSImage *)filteredImageForElement:(ATVCanvasElement *)element
{
    NSImage *filteredImage = [self.filteredImagesCache objectForKey:element];
    
    if (filteredImage)
    {
        return filteredImage;
    }
    else
    {
        [self applyFiltersToElement:element];
        return nil;
    }
}

- (void)invalidateFilteredImageForElement:(ATVCanvasElement *)element
{
    [self.filteredImagesCache removeObjectForKey:element];
    [self applyFiltersToElement:element];
}

- (BOOL)isFlipped
{
    return YES;
}

- (void)dealloc
{
    [_filteredImagesCache release];
    [_modelController release];
    [super dealloc];
}

@end
