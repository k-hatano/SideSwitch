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
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        int selection=0;
        
        [panel setIsVisible:NO];
        NSArray *apps = [[NSWorkspace sharedWorkspace] runningApplications];
        int i=0;
        for(NSRunningApplication* app in apps){
            if (app.activationPolicy != NSApplicationActivationPolicyRegular) continue;
            
            NSImage *icon = [[NSImage alloc] initWithSize:NSMakeSize(32, 32)];
            [icon lockFocus];
            [app.icon drawInRect:NSMakeRect(0, 0, icon.size.width, icon.size.height)
                        fromRect:NSMakeRect(0, 0, app.icon.size.width, app.icon.size.height)
                       operation:NSCompositeCopy
                        fraction:1.0f];
            [icon unlockFocus];
            NSString *name=[NSString stringWithFormat:@"%@",[app localizedName]];
            if(!name) name=@"";
            
            NSDictionary *dic=@{@"icon":icon,@"name":name,@"textColor":app.hidden?[NSColor grayColor]:[NSColor whiteColor],@"pid":[NSNumber numberWithInteger:app.processIdentifier]};
            [array addObject:dic];
            
            if(app.ownsMenuBar) selection=i;
            i++;
        }
        
        NSRange range = NSMakeRange(0, [[arrayController arrangedObjects] count]);
        [arrayController removeObjectsAtArrangedObjectIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
        [arrayController addObjects:array];
        [arrayController setSelectionIndex:selection];
        
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
    NSInteger pid=[[dict objectForKey:@"pid"] integerValue];
    
    [[NSRunningApplication runningApplicationWithProcessIdentifier:(pid_t)pid] activateWithOptions:NSApplicationActivateIgnoringOtherApps];
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
