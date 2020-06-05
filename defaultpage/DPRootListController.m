#include "DPRootListController.h"
#include <spawn.h>

@implementation DPRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"DefaultPage" target:self] retain];
	}

	return _specifiers;
}

-(void)email{
	if([MFMailComposeViewController canSendMail]){
		MFMailComposeViewController *email = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
		[email setSubject:@"DefaultPage Support"];
		[email setToRecipients:[NSArray arrayWithObjects:@"deeppwnage@yahoo.com", nil]];
		[email addAttachmentData:[NSData dataWithContentsOfFile:@"/var/mobile/Library/Preferences/com.dgh0st.defaultpage.plist"] mimeType:@"application/xml" fileName:@"Prefs.plist"];
		pid_t pid;
		const char *argv[] = { "/usr/bin/dpkg", "-l" ">" "/tmp/dpkgl.log" };
		extern char *const *environ;
		posix_spawn(&pid, argv[0], NULL, NULL, (char *const *)argv, environ);
		waitpid(pid, NULL, 0);
		[email addAttachmentData:[NSData dataWithContentsOfFile:@"/tmp/dpkgl.log"] mimeType:@"text/plain" fileName:@"dpkgl.txt"];
		[self.navigationController presentViewController:email animated:YES completion:nil];
		[email setMailComposeDelegate:self];
		[email release];
	}
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissViewControllerAnimated: YES completion: nil];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

-(void)donate{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://paypal.me/DGhost"]];
}

-(void)follow{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://mobile.twitter.com/D_Gh0st"]];
}

#pragma clang diagnostic pop

-(void)viewDidLoad {
	[super viewDidLoad];
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 2, self.table.bounds.size.width, 80)];
	[headerView setBackgroundColor:[UIColor blackColor]];
	[headerView setContentMode:UIViewContentModeCenter];
	[headerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];

	CGRect frame = CGRectMake(0, 16, self.table.bounds.size.width, 32);
	CGRect underFrame = CGRectMake(0, 48, self.table.bounds.size.width, 16);
 
	UILabel *label = [[UILabel alloc] initWithFrame:frame];
	[label setNumberOfLines:1];
	label.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:42];
	[label setText:@"DefaultPage"];
	[label setBackgroundColor:[UIColor clearColor]];
	label.textColor = [UIColor whiteColor];
	label.textAlignment = NSTextAlignmentCenter;
	label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	label.contentMode = UIViewContentModeScaleToFill;

	UILabel *underLabel = [[UILabel alloc] initWithFrame:underFrame];
	[underLabel setNumberOfLines:1];
	underLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
	[underLabel setText:@"By DGh0st"];
	[underLabel setBackgroundColor:[UIColor clearColor]];
	underLabel.textColor = [UIColor whiteColor];
	underLabel.textAlignment = NSTextAlignmentCenter;
	underLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	underLabel.contentMode = UIViewContentModeScaleToFill;

	[headerView addSubview:label];
	[headerView addSubview:underLabel];

	self.table.tableHeaderView = headerView;

	[label release];
	[underLabel release];
	[headerView release];
}

@end