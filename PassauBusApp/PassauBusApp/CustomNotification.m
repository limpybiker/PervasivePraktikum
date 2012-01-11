
#import "CustomNotification.h"

@implementation CustomNotification

@synthesize actionSheet;

#pragma mark initialization

- (id)init {
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


#pragma mark notification methods

- (void) displayCustomNotificationWithText:(NSString *)text {
    
    [self displayCustomNotificationWithText:text AndButtonTitle:@"OK"];
    
}


- (void) displayCustomNotificationWithText:(NSString *)text inView:(UIView *)view {
    self.actionSheet=[[[UIActionSheet alloc] initWithTitle:text
                                                  delegate:self 
                                         cancelButtonTitle:@"OK"
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:nil] autorelease];
    
	self.actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [self.actionSheet showInView:view];
}



- (void) displayCustomNotificationWithText:(NSString *)text AndButtonTitle:(NSString *)buttonTitle {
    
    self.actionSheet=[[[UIActionSheet alloc] initWithTitle:text
                                            delegate:self 
                                   cancelButtonTitle:buttonTitle 
                              destructiveButtonTitle:nil
                                   otherButtonTitles:nil] autorelease];
    
	self.actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    //self.actionSheet sh
}



#pragma mark Pulldown Stuff

- (void)dealloc {
    [actionSheet release];
    
	[super dealloc];
}

@end
