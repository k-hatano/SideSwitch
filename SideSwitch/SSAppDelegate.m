//
//  SSAppDelegate.m
//  SideSwitch
//
//  Created by HatanoKenta on 2014/07/23.
//
//

#import "SSAppDelegate.h"

@implementation SSAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSArray *apps = [[NSWorkspace sharedWorkspace] runningApplications];
    
    CFArrayRef windowList =CGWindowListCopyWindowInfo((kCGWindowListOptionAll|kCGWindowListOptionOnScreenOnly|kCGWindowListExcludeDesktopElements), kCGNullWindowID);
    for(int i=0;i < CFArrayGetCount(windowList); i++){
        CFDictionaryRef dict = CFArrayGetValueAtIndex(windowList, i);
        CFStringRef n = CFDictionaryGetValue(dict, kCGWindowName);
        NSString *name = (__bridge_transfer NSString *)n;
        if(name==nil || [name isEqualToString:@""]) continue;
        CFStringRef o = CFDictionaryGetValue(dict, kCGWindowOwnerName);
        NSString *owner = (__bridge_transfer NSString *)o;
        NSImage *icon = [[NSImage alloc] init];
        for(NSRunningApplication* app in apps){
            if([owner isEqualToString:app.localizedName]){
                icon=app.icon;
            }
        }
        [arrayController addObject:@{@"window":[NSString stringWithFormat:@"%@",name],@"icon":icon}];
    }
}

@end
