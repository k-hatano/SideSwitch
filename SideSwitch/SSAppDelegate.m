//
//  SSAppDelegate.m
//  SideSwitch
//
//  Created by HatanoKenta on 2014/07/23.
//
//

#import "SSAppDelegate.h"

@implementation SSAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification{
    [self showSwitcher];
}

- (void)showSwitcher{
    [panel setFloatingPanel:YES];
    
    NSArray *apps = [[NSWorkspace sharedWorkspace] runningApplications];
    
    CFArrayRef windowList =CGWindowListCopyWindowInfo((kCGWindowListOptionOnScreenOnly|kCGWindowListExcludeDesktopElements), kCGNullWindowID);
    for(int i=0;i < CFArrayGetCount(windowList); i++){
        BOOL flg=NO;
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
                flg=YES;
            }
        }
        if(!flg) continue;
        NSNumber *winId=CFDictionaryGetValue(dict, kCGWindowNumber);
        [arrayController addObject:@{@"window":[NSString stringWithFormat:@"%@",name],@"icon":icon,@"id":winId}];
    }
    
    NSRect srcRect=[panel frame];
    NSRect dstRect=[panel frame];
    srcRect.origin.x-=srcRect.size.width;
    [panel setFrame:srcRect display:YES];
    [panel setIsVisible:YES];
    
    [panel setFrame:dstRect display:YES animate:YES];
}

- (void)hideSwitcher{
    NSRect srcRect=[panel frame];
    NSRect dstRect=[panel frame];
    dstRect.origin.x-=dstRect.size.width;
    [panel setFrame:srcRect display:YES];
    
    [panel setFrame:dstRect display:YES animate:YES];
    [panel setIsVisible:NO];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification{
    NSLog(@"%lu",[arrayController selectionIndex]);
}


@end
