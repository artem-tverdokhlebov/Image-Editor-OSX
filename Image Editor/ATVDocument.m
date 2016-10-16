//
//  Document.m
//  Image Editor
//
//  Created by Артём Твердохлебов on 8/19/16.
//  Copyright © 2016 Артём Твердохлебов. All rights reserved.
//

#import "ATVDocument.h"
#import "ATVDocumentWindowController.h"

@interface ATVDocument ()
{
@private
    ATVCanvasModelController *_modelController;
    ATVDocumentWindowController *_windowController;
}
@end

@implementation ATVDocument

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _modelController = [[ATVCanvasModelController alloc] init];
    }
    
    return self;
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (void)makeWindowControllers
{
    ATVDocumentWindowController *windowController = [[ATVDocumentWindowController alloc] initWithCanvasModel:self.modelController];
    [self addWindowController:windowController];

    [windowController release];
    
    self.windowController = windowController;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.modelController];
    
    if (!data && outError)
    {
        *outError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteUnknownError userInfo:nil];
        
        return nil;
    }
    
    return data;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    BOOL readSuccess = NO;
    
    ATVCanvasModelController *modelController = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    self.modelController = modelController;
    
    if (!modelController && outError)
    {
        *outError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadUnknownError userInfo:nil];
    }
    else
    {
        readSuccess = YES;
    }
    
    return readSuccess;
}

- (IBAction)exportDocumentAsPNG:(id)sender
{
    [self exportDocumentAs:(NSString *) kUTTypePNG];
}

- (IBAction)exportDocumentAsJPEG:(id)sender
{
    [self exportDocumentAs:(NSString *) kUTTypeJPEG];
}

- (IBAction)exportDocumentAsTIFF:(id)sender
{
    [self exportDocumentAs:(NSString *) kUTTypeTIFF];
}

- (void)exportDocumentAs:(NSString *)typeName
{
    NSWindow *window = [self.windowController window];
    NSSavePanel *panel = [NSSavePanel savePanel];
    
    [panel setAllowedFileTypes:@[ typeName ]];
    
    [panel beginSheetModalForWindow:window completionHandler:
     ^(NSInteger result) {
         if (result == NSFileHandlingPanelOKButton)
         {
             NSBitmapImageFileType imageType;
             
             if ([typeName isEqualToString:(NSString *)kUTTypePNG])
             {
                 imageType = NSPNGFileType;
             }
             else if ([typeName isEqualToString:(NSString *)kUTTypeJPEG])
             {
                 imageType = NSJPEGFileType;
             }
             else if ([typeName isEqualToString:(NSString *)kUTTypeTIFF])
             {
                 imageType = NSTIFFFileType;
             }
             else
             {
                 return;
             }
             
             NSData *imageData = [self.windowController canvasRepresentationUsingType:imageType];
             
             if (imageData)
             {
                 NSURL *fileURL = [panel URL];
                 
                 [imageData writeToURL:fileURL atomically:YES];
             }
         }
     }];
}

- (void)dealloc
{
    [_modelController release];
    [super dealloc];
}

@end
