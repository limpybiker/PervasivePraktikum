#import <Foundation/Foundation.h>

@interface CustomNotification : NSObject <UIActionSheetDelegate> {
    UIActionSheet *actionSheet;    
}

@property (nonatomic, retain) UIActionSheet *actionSheet;

- (void) displayCustomNotificationWithText:(NSString *)text;
- (void) displayCustomNotificationWithText:(NSString *)text inView:(UIView *)view;
- (void) displayCustomNotificationWithText:(NSString *)text AndButtonTitle:(NSString *)buttonTitle;


@end
