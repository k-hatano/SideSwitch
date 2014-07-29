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
    dstRect.origin.x=-dstRect.size.width;
    dstRect.origin.y=0;
    [panel setFloatingPanel:YES];
    [panel setFrame:dstRect display:NO];
    [panel setIsVisible:YES];
    [panel setIsVisible:NO];
    initializing=YES;
    
    [NSThread detachNewThreadSelector:@selector(heartbeat:) toTarget:self withObject:nil];
}

- (void)showSwitcher{
    //if([panel frame].origin.x>=0) return;
    @synchronized(self){
        initializing=YES;
        
        NSRange range = NSMakeRange(0, [[arrayController arrangedObjects] count]);
        [arrayController removeObjectsAtArrangedObjectIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
        
        [panel setIsVisible:NO];
        NSArray *apps = [[NSWorkspace sharedWorkspace] runningApplications];
        CFArrayRef windowList =CGWindowListCopyWindowInfo((kCGWindowListOptionOnScreenOnly|kCGWindowListExcludeDesktopElements), kCGNullWindowID);
        for(int i=0;i < CFArrayGetCount(windowList); i++){
            BOOL flg=NO;
            CFDictionaryRef dict = CFArrayGetValueAtIndex(windowList, i);
            
            if ((int)CFDictionaryGetValue(dict, kCGWindowLayer)>1000) {
                continue;
            }
            
            CFStringRef n = CFDictionaryGetValue(dict, kCGWindowName);
            NSString *name = (__bridge_transfer NSString *)n;
            if(name==nil || [name isEqualToString:@""]) continue;
            CFStringRef o = CFDictionaryGetValue(dict, kCGWindowOwnerName);
            NSString *owner = (__bridge_transfer NSString *)o;
            NSImage *icon = [[NSImage alloc] initWithSize:NSMakeSize(32, 32)];
            NSString *appName = nil;
            
            for(NSRunningApplication* app in apps){if([owner isEqualToString:app.localizedName]){
                    appName=app.localizedName;
                    [icon lockFocus];
                    [app.icon drawInRect:NSMakeRect(0, 0, icon.size.width, icon.size.height)
                                fromRect:NSMakeRect(0, 0, app.icon.size.width, app.icon.size.height)
                               operation:NSCompositeCopy
                                fraction:1.0f];
                    [icon unlockFocus];
                    flg=YES;
                    break;
                }
            }
            if(!flg) continue;
            NSNumber *winId=CFDictionaryGetValue(dict, kCGWindowNumber);
            [arrayController addObject:@{@"window":name,@"icon":icon,@"winId":winId,@"appName":appName}];
        }
        [arrayController setSelectionIndex:0];
        
        NSRect srcRect=[panel frame];
        NSRect dstRect=[panel frame];
        dstRect.origin.x=0;
        dstRect.size.height=dstRect.size.height+1;
        [table reloadData];
        [panel setFrame:srcRect display:YES animate:NO];
        [panel setIsVisible:YES];
        
        [panel setFrame:dstRect display:YES animate:YES];
        [table reloadData];
        
        initializing=NO;
        
    }
}

- (void)hideSwitcher{
    //if([panel frame].origin.x<0) return;
    @synchronized(self){
        NSRect srcRect=[panel frame];
        NSRect dstRect=[panel frame];
        dstRect.origin.x=-dstRect.size.width;
        dstRect.size.height=dstRect.size.height-1;
        [panel setFrame:srcRect display:YES animate:NO];
        
        [panel setFrame:dstRect display:YES animate:YES];
        [panel setIsVisible:NO];
    }
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification{
    if(initializing) return;
    
    NSDictionary *dict=[[arrayController selectedObjects] objectAtIndex:0];
    NSString *appName=[dict objectForKey:@"appName"];
    NSString *winName=[dict objectForKey:@"window"];
    NSString *script=[NSString stringWithFormat:
                      @"tell application \"System Events\" \n tell process \"%@\" \n set thewindow to first window of (windows whose name is \"%@\") \n tell thewindow \n perform action \"AXRaise\" \n end tell \n  set frontmost to true \n end tell \n end tell"
                      ,appName,winName];
    NSLog(@"%@",script);
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
