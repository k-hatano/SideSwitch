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
    lastArray = [[NSMutableArray alloc] init];
    [self updatePreferences:self];
    
    [NSThread detachNewThreadSelector:@selector(heartbeat:) toTarget:self withObject:nil];
}

- (void)showSwitcher{
    //if([panel frame].origin.x>=0) return;
    @synchronized(self){
        lastArray = [[NSMutableArray alloc] init];
        
        initializing=YES;
        
        NSRange range = NSMakeRange(0, [[arrayController arrangedObjects] count]);
        [arrayController removeObjectsAtArrangedObjectIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
        
        NSArray *apps = [[NSWorkspace sharedWorkspace] runningApplications];
        CFArrayRef windowList =CGWindowListCopyWindowInfo((kCGWindowListOptionOnScreenOnly|kCGWindowListExcludeDesktopElements), kCGNullWindowID);
        for(int i=0;i < CFArrayGetCount(windowList); i++){
            BOOL flg=NO;
            CFDictionaryRef dict = CFArrayGetValueAtIndex(windowList, i);
            
            if ((int)CFDictionaryGetValue(dict, kCGWindowLayer)>1000) {
                continue;
            }
            
            CFStringRef o = CFDictionaryGetValue(dict, kCGWindowOwnerName);
            NSString *owner = (__bridge_transfer NSString *)o;
            
            if ([owner isEqualToString:[[NSRunningApplication currentApplication] localizedName]]) {
                continue;
            }
            
            CFStringRef n = CFDictionaryGetValue(dict, kCGWindowName);
            NSString *name = (__bridge_transfer NSString *)n;
            if(name==nil || [name isEqualToString:@""]) continue;
            NSImage *icon = [[NSImage alloc] initWithSize:NSMakeSize(32, 32)];
            NSString *appName = nil;
            NSString *ios = CFDictionaryGetValue(dict, kCGWindowIsOnscreen);
            NSInteger isOnScreen = [ios integerValue];
            
            for(NSRunningApplication* app in apps){
                if([owner isEqualToString:app.localizedName]){
                    appName=[[[app.bundleURL absoluteString] lastPathComponent] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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
            NSDictionary *dic=@{@"window":name,@"icon":icon,@"winId":winId,@"appName":appName,@"textColor":isOnScreen?[NSColor whiteColor]:[NSColor lightGrayColor]};
            [lastArray addObject:dic];
            [arrayController addObject:dic];
        }
        [arrayController setSelectionIndex:0];
        CFBridgingRelease(windowList);
        
        NSRect srcRect=[panel frame];
        NSRect dstRect=[panel frame];
        dstRect.origin.x=0;
        dstRect.size.height=dstRect.size.height+1;
        
        [table reloadData];
        [panel setFrame:srcRect display:NO animate:NO];
        [panel setIsVisible:YES];
        
        [table reloadData];
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
        [panel setFrame:srcRect display:NO animate:NO];
        
        [panel setFrame:dstRect display:YES animate:YES];
        [panel setIsVisible:NO];
    }
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification{
    if(initializing) return;
    
    NSArray* selections=[arrayController selectedObjects];
    if(!selections||[selections count]<=0) return;
    NSDictionary *dict=[selections objectAtIndex:0];
    NSString *appName=[dict objectForKey:@"appName"];
    NSString *winId=[dict objectForKey:@"winId"];
    NSString *script;
    if([@"Finder.app" isEqualToString:appName]){
        script=[NSString stringWithFormat:
                @"tell application \"%@\" \n activate \n activate window id %@\n end tell"
                ,appName,winId];
    }else{
        script=[NSString stringWithFormat:
                @"tell application \"%@\" \n activate window id %@ \n activate \n end tell"
                ,appName,winId];
    }
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
            switch(mousePointerAt){
                case 0:{
                    if(point.x<=1) [self showSwitcher];
                    break;
                }
                case 1:{
                    NSInteger height = [[NSScreen mainScreen] frame].size.height;
                    if(point.x<=1 && point.y>=height-1) [self showSwitcher];
                    break;
                }
                case 2:{
                    if(point.x<=1 && point.y<=1) [self showSwitcher];
                    break;
                }
                default:{
                    break;
                }
            }
        }
        [NSThread sleepForTimeInterval:0.1f];
    }
}

- (void)showPreferencesWindow{
    [preferencesWindow makeKeyAndOrderFront:self];
}

- (IBAction)updatePreferences:(id)sender{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id value = [defaults valueForKey:@"mousePointerAt"];
    if (value){
        mousePointerAt = [value integerValue];
    }
    
}


@end
