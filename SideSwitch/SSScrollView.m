//
//  SSScrollView.m
//  SideSwitch
//
//  Created by kenta on 2014/07/24.
//
//

#import "SSScrollView.h"

@implementation SSScrollView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

+ (NSMenu*)defaultMenu {
	NSMenu * menu = [[NSMenu alloc] init];
	[menu addItemWithTitle:@"Quit" action:@selector(quit) keyEquivalent:@""];
	return menu;
}

- (void)quit{
    [[NSApplication sharedApplication] terminate:self];
}

@end
