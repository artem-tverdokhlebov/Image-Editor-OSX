//
//  ATVInstrumentsPanel.m
//  Image Editor
//
//  Created by Артём Твердохлебов on 8/19/16.
//  Copyright © 2016 Артём Твердохлебов. All rights reserved.
//

#import "ATVInstrumentsPanelController.h"
#import "ATVCanvasView.h"

@interface ATVInstrumentsPanelController ()

@property (assign) ATVDrawingMode drawingMode;

@end

@implementation ATVInstrumentsPanelController

- (instancetype)init
{
    self = [super initWithWindowNibName:@"ATVInstrumentsPanel"];
    if (self)
    {
    
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
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

- (IBAction)selectedModeChanged:(NSSegmentedControl *)sender {
    
    if (sender.selectedSegment != -1)
    {
        self.drawingMode = sender.selectedSegment;
    }
}

- (IBAction)buttonToogle:(NSButton *)sender
{
    if (sender.state == NSOnState)
    {
        sender.state = NSOffState;
    }
    else if (sender.state == NSOffState)
    {
        sender.state = NSOnState;
    }
}


@end
