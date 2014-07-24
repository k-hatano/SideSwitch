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
    NSRect dstRect=[panel frame];
    dstRect.size.height=[[NSScreen mainScreen] frame].size.height-22;
    dstRect.origin.y=0;
    [panel setFrame:dstRect display:YES];
    [panel setIsVisible:YES];
    [panel display];
    
    [NSThread detachNewThreadSelector:@selector(heartbeat:) toTarget:self withObject:nil];
}

- (void)showSwitcher{
    //if([panel frame].origin.x>=0) return;
    @synchronized(self){
        initializing=YES;
        
        NSRange range = NSMakeRange(0, [[arrayController arrangedObjects] count]);
        [arrayController removeObjectsAtArrangedObjectIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
        
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
            NSString *appName = nil;
            for(NSRunningApplication* app in apps){
                if([owner isEqualToString:app.localizedName]){
                    appName=app.localizedName;
                    icon=app.icon;
                    flg=YES;
                    break;
                }
            }
            if(!flg) continue;
            NSNumber *winId=CFDictionaryGetValue(dict, kCGWindowNumber);
            [arrayController addObject:@{@"window":[NSString stringWithFormat:@"%@",name],@"icon":icon,@"winId":winId,@"appName":appName}];
        }
        [arrayController setSelectionIndex:0];
        
        NSRect srcRect=[panel frame];
        NSRect dstRect=[panel frame];
        dstRect.origin.x=0;
        [panel setFrame:srcRect display:YES animate:NO];
        [panel setIsVisible:YES];
        [panel display];
        
        [panel setFrame:dstRect display:YES animate:YES];
        [panel display];
        
        initializing=NO;
    }
}

- (void)hideSwitcher{
    //if([panel frame].origin.x<0) return;
    @synchronized(self){
        NSRect srcRect=[panel frame];
        NSRect dstRect=[panel frame];
        dstRect.origin.x=-dstRect.size.width;
        [panel setFrame:srcRect display:YES animate:NO];
        [panel display];
        
        [panel setFrame:dstRect display:YES animate:YES];
        [panel setIsVisible:NO];
        [panel display];
    }
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification{
    if(initializing) return;
    
    NSDictionary *dict=[[arrayController selectedObjects] objectAtIndex:0];
    NSString *appName=[dict objectForKey:@"appName"];
    NSString *winId=[[dict objectForKey:@"winId"] stringValue];
    NSString *script=[NSString stringWithFormat:
                      @"tell application \"%@\" \n activate \n end tell \n tell application \"System Events\" \n set theprocess to the first process whose frontmost is true \n windows of theprocess \n tell window id %@ of theprocess \n perform action \"AXRaise\" \n end tell \n end tell"
                      ,appName,winId];
    NSAppleScript *appleScript=[[NSAppleScript alloc] initWithSource:script];
    [appleScript executeAndReturnError:nil];
}

- (void)heartbeat:(NSThread*)thread{
    while(YES){
        NSPoint point=[NSEvent mouseLocation];
        if([panel frame].origin.x>=0){
            if(point.x>=[panel frame].size.width) [self hideSwitcher];
        }else{
            if(point.x<=1) [self showSwitcher];
        }
        [NSThread sleepForTimeInterval:0.1f];
    }
}


@end
