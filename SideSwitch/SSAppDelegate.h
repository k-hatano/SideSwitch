//
//  SSAppDelegate.h
//  SideSwitch
//
//  Created by HatanoKenta on 2014/07/23.
//
//

#import <Cocoa/Cocoa.h>

@interface SSAppDelegate : NSObject <NSApplicationDelegate>{
    IBOutlet NSArrayController *arrayController;
}

@property (assign) IBOutlet NSWindow *window;

@end
