//
//  SSScrollView.h
//  SideSwitch
//
//  Created by kenta on 2014/07/24.
//
//

#import <Cocoa/Cocoa.h>
#import "SSAppDelegate.h"

@interface SSScrollView : NSScrollView{
    IBOutlet SSAppDelegate* appDelegate;
}

- (void)preferences;
- (void)quit;

@end
