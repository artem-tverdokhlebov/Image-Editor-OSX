//
//  ATVDocumentWindowController.m
//  Image Editor
//
//  Created by Артём Твердохлебов on 8/20/16.
//  Copyright © 2016 Артём Твердохлебов. All rights reserved.
//

#import "ATVDocumentWindowController.h"

@interface ATVDocumentWindowController ()
{
@private
    ATVCanvasModelController *_modelController;
}
@property (assign) IBOutlet ATVCanvasView *canvasView;
@property (retain) ATVCanvasModelController *modelController;
@end

@implementation ATVDocumentWindowController

- (instancetype)initWithCanvasModel:(ATVCanvasModelController *)modelController
{
    self = [super initWithWindowNibName:@"ATVDocumentWindow"];
    if (self)
    {
        _modelController = [modelController retain];
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [self.window setContentSize:self.modelController.canvasSize];
    
    for(ATVCanvasElement *element in self.modelController.canvasElements)
    {
        element.delegate = self;
    }
    
    self.canvasView.modelController = self.modelController;
    self.canvasView.delegate = self;
    
    [self addObserver:self forKeyPath:@"modelController.canvasElements" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)windowDidResize:(NSNotification *)notification
{
    self.modelController.canvasSize = self.window.frame.size;
}

- (NSUndoManager *)undoManager
{
    return [[[NSDocumentController sharedDocumentController] currentDocument] undoManager];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"modelController.canvasElements"])
    {
        self.canvasView.needsDisplay = YES;
    }
}

#pragma mark Copy & Paste (Duplicate)

- (IBAction)copy:(id)sender
{
    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] writeObjects:@[self.canvasView.selectedCanvasElement]];
}

- (IBAction)paste:(id)sender
{
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    NSString *type = [pasteboard availableTypeFromArray:@[kATVCanvasImageElementUTI, kATVCanvasShapeElementUTI, kATVCanvasLineElementUTI]];
    
    if (type)
    {
        NSData *pasteboardData = [pasteboard dataForType:type];
        
        ATVCanvasImageElement *object = [NSKeyedUnarchiver unarchiveObjectWithData:pasteboardData];
        
        object.delegate = self;
        
        [self addCanvasElement:object];
    }
}

- (IBAction)duplicate:(id)sender
{
    [self copy:sender];
    [self paste:sender];
}

# pragma mark Move Events

- (IBAction)moveUp:(id)sender
{
    [self offsetElement:self.canvasView.selectedCanvasElement byX:0 andY:-2];
}

- (IBAction)moveDown:(id)sender
{
    [self offsetElement:self.canvasView.selectedCanvasElement byX:0 andY:2];
}

- (IBAction)moveLeft:(id)sender
{
    [self offsetElement:self.canvasView.selectedCanvasElement byX:-2 andY:0];
}

- (IBAction)moveRight:(id)sender
{
    [self offsetElement:self.canvasView.selectedCanvasElement byX:2 andY:0];
}

#pragma mark Methods for Undo & Redo

- (void)offsetElement:(ATVCanvasElement *)element byX:(NSInteger)x andY:(NSInteger)y
{
    [[self.undoManager prepareWithInvocationTarget:self] offsetElement:element byX:-x andY:-y];
    
    if (![self.undoManager isUndoing])
        [self.undoManager setActionName:@"Move Element"];
    
    [element offsetOriginByX:x andY:y];
}

#pragma mark Canvas View Delegate Methods

- (void)addCanvasElement:(ATVCanvasElement *)canvasElement
{
    [[self.undoManager prepareWithInvocationTarget:self] deleteCanvasElement:canvasElement];
    
    if (![self.undoManager isUndoing])
        [self.undoManager setActionName:@"Add Element"];
    
    [self.modelController addCanvasElement:canvasElement];
}

- (void)deleteCanvasElement:(ATVCanvasElement *)canvasElement
{
    [[self.undoManager prepareWithInvocationTarget:self] addCanvasElement:canvasElement];
    
    if (![self.undoManager isUndoing])
        [self.undoManager setActionName:@"Remove Element"];
    
    if (self.canvasView.selectedCanvasElement == canvasElement)
        self.canvasView.selectedCanvasElement = nil;
    
    [self.modelController removeCanvasElement:canvasElement];
}

#pragma mark Canvas Element Delegate Methods

- (void)canvasElementFrameDidChange:(ATVCanvasElement *)element
{
    self.canvasView.needsDisplay = YES;
}

- (void)canvasElementFiltersDidChange:(ATVCanvasElement *)element
{
    [self.canvasView invalidateFilteredImageForElement:element];
}

- (void)canvasElementSizeDidChange:(ATVCanvasElement *)element
{
    if (element.filters.count > 0)
        [self.canvasView invalidateFilteredImageForElement:element];
}

- (void)canvasElementPropertiesDidChange:(ATVCanvasElement *)element
{
    self.canvasView.needsDisplay = YES;
    
    if (element.filters.count > 0)
        [self.canvasView invalidateFilteredImageForElement:element];
}

- (void)canvasElementRotationAngleDidChange:(ATVCanvasElement *)element
{
    self.canvasView.needsDisplay = YES;
}

- (NSData *)canvasRepresentationUsingType:(NSBitmapImageFileType)imageType
{
    return [self.canvasView imageRepresentationUsingType:imageType];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    if (menuItem.action == @selector(copy:) || menuItem.action == @selector(duplicate:))
    { 
        return !!self.canvasView.selectedCanvasElement;
    }
    else if (menuItem.action == @selector(paste:))
    {
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        NSString *type = [pasteboard availableTypeFromArray:@[kATVCanvasImageElementUTI, kATVCanvasShapeElementUTI, kATVCanvasLineElementUTI]];
        
        return !!type;
    }
    
    return YES;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"modelController.canvasElements"];
    
    [_modelController release];
    [super dealloc];
}

@end
