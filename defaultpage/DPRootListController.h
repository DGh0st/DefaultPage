#import <Preferences/PSListController.h>
#import <Preferences/PSTableCell.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface PSTableCell (DefaultPage)
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
@end

@interface PSListController (DefaultPage)
- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion;
- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion;
- (UINavigationController*)navigationController;
@end

@interface DPRootListController : PSListController <MFMailComposeViewControllerDelegate>

@end
