//
//  AppDelegate.m
//  Image Editor
//
//  Created by Артём Твердохлебов on 8/19/16.
//  Copyright © 2016 Артём Твердохлебов. All rights reserved.
//

#import "ATVAppDelegate.h"
#import "ATVDocumentWindowController.h"
#import "ATVImagesLibraryPanelController.h"
#import "ATVInstrumentsPanelController.h"
#import "ATVInspectorPanelController.h"

@interface ATVAppDelegate ()
@property (assign) IBOutlet ATVImagesLibraryPanelController *imagesLibraryPanelController;
@property (assign) IBOutlet ATVInstrumentsPanelController *instrumentsPanelController;
@property (assign) IBOutlet ATVInspectorPanelController *inspectorPanelController;

@property (assign) IBOutlet NSMenuItem *accountStateMenuItem;
@property (assign) IBOutlet NSMenuItem *documentsMenuItem;

@property (assign) IBOutlet NSMenuItem *loginMenuItem;
@property (assign) IBOutlet NSMenuItem *logoutMenuItem;
@end

@implementation ATVAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self.imagesLibraryPanelController.window orderFront:self];
    [self.instrumentsPanelController.window orderFront:self];
    [self.inspectorPanelController.window orderFront:self];
    
    [self addObserver:self forKeyPath:@"instrumentsPanelController.drawingMode" options:NSKeyValueObservingOptionNew context:nil];
    [NSApp addObserver:self forKeyPath:@"mainWindow.document.windowController" options:NSKeyValueObservingOptionNew context:nil];
    
    [NSApp addObserver:self forKeyPath:@"mainWindow.document.windowController.canvasView.selectedCanvasElement" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"instrumentsPanelController.drawingMode"] || [keyPath isEqualToString:@"mainWindow.document.windowController"])
    {
        if ([[NSApp valueForKeyPath:@"mainWindow.windowController"] isKindOfClass:[ATVDocumentWindowController class]])
        {
            [NSApp setValue:[self.instrumentsPanelController valueForKey:@"drawingMode"] forKeyPath:@"mainWindow.document.windowController.canvasView.drawingMode"];
        }
    }
    
    if ([keyPath isEqualToString:@"mainWindow.document.windowController.canvasView.selectedCanvasElement"])
    {
        if ([[NSApp valueForKeyPath:@"mainWindow.windowController"] isKindOfClass:[ATVDocumentWindowController class]])
        {
            [self.inspectorPanelController setValue:[NSApp valueForKeyPath:@"mainWindow.document.windowController.canvasView.selectedCanvasElement"] forKey:@"currentElement"];
        }
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    
}

- (IBAction)changePanelState:(NSMenuItem *)sender
{
    if ([sender.title isEqualToString:@"Instruments"])
    {
        [self.instrumentsPanelController tooglePanel];
    }
    else if ([sender.title isEqualToString:@"Standard Images"])
    {
        [self.imagesLibraryPanelController tooglePanel];
    }
    else if ([sender.title isEqualToString:@"Inspector"])
    {
        [self.inspectorPanelController tooglePanel];
    }
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    if ([menuItem.title isEqualToString:@"Instruments"])
    {
        menuItem.state = self.instrumentsPanelController.window.visible;
    }
    else if ([menuItem.title isEqualToString:@"Standard Images"])
    {
        menuItem.state = self.imagesLibraryPanelController.window.visible;
    }
    else if ([menuItem.title isEqualToString:@"Inspector"])
    {
        menuItem.state = self.inspectorPanelController.window.visible;
    }
    
    return YES;
}

- (void)dealloc
{
    [NSApp removeObserver:self forKeyPath:@"mainWindow.document.windowController.canvasView.selectedCanvasElement" context:nil];
    
    [NSApp removeObserver:self forKeyPath:@"mainWindow.windowController"];
    [self removeObserver:self forKeyPath:@"instrumentsPanelController.drawingMode"];

    [super dealloc];
}

@end
