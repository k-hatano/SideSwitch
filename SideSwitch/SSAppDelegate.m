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
            [arrayController addObject:@{@"window":[NSString stringWithFormat:@"%@",name],@"icon":icon,@"id":winId,@"appName":appName}];
        }
        
        NSRect srcRect=[panel frame];
        NSRect dstRect=[panel frame];
        dstRect.origin.x=0;
        [panel setFrame:srcRect display:YES];
        [panel setIsVisible:YES];
        
        [panel setFrame:dstRect display:YES animate:YES];
        [panel displayIfNeeded];
        
        initializing=NO;
    }
}

- (void)hideSwitcher{
    //if([panel frame].origin.x<0) return;
    @synchronized(self){
        NSRect srcRect=[panel frame];
        NSRect dstRect=[panel frame];
        dstRect.origin.x=-dstRect.size.width;
        [panel setFrame:srcRect display:YES];
        
        [panel setFrame:dstRect display:YES animate:YES];
        [panel setIsVisible:NO];
    }
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification{
    if(initializing) return;
    
    NSLog(@"%lu",[arrayController selectionIndex]);
    
    NSDictionary *dict=[[arrayController selectedObjects] objectAtIndex:0];
    NSString *appName=[dict objectForKey:@"appName"];
    NSString *script=[NSString stringWithFormat:@"tell application \"%@\" to activate",appName];
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
