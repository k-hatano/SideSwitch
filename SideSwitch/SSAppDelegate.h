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
    IBOutlet NSTableView *table;
    IBOutlet NSWindow *preferencesWindow;
    
    BOOL initializing;
    NSInteger mousePointerAt;
}

@property (assign) IBOutlet NSWindow *window;

- (void)showPreferencesWindow;
- (void)showSwitcher;
- (void)hideSwitcher;
- (void)heartbeat:(NSThread*)thread;

- (IBAction)updatePreferences:(id)sender;

@end
