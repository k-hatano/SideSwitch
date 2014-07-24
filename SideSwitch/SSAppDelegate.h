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
    IBOutlet NSPanel *panel;
}

@property (assign) IBOutlet NSWindow *window;

- (void)showSwitcher;
- (void)hideSwitcher;

@end
