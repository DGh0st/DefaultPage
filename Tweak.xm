#include <notify.h>

@interface ALApplicationList
@property (nonatomic, readonly) NSDictionary *applications;
-(id)sharedApplicationList;
-(NSDictionary *)applicationsFilteredUsingPredicate:(NSPredicate *)predicate onlyVisible:(BOOL)onlyVisible titleSortedIdentifiers:(NSArray **)outSortedByTitle;
@end

@interface SBIconController : UIViewController
+(id)sharedInstance;
-(void)handleHomeButtonTap;
-(BOOL)isNewsstandOpen;
-(BOOL)hasOpenFolder;
-(BOOL)_iconListIndexIsValid:(NSInteger)arg1;
-(BOOL)scrollToIconListAtIndex:(NSInteger)arg1 animate:(BOOL)arg2;
-(NSInteger)currentIconListIndex;
-(NSInteger)currentFolderIconListIndex;
-(_Bool)_presentRightEdgeSpotlight:(_Bool)arg1;
-(_Bool)_presentRightEdgeTodayView:(_Bool)arg1;
-(id)insertIcon:(id)arg1 intoListView:(id)arg2 iconIndex:(NSInteger)arg3 moveNow:(BOOL)arg4 ;
-(id)insertIcon:(id)arg1 intoListView:(id)arg2 iconIndex:(NSInteger)arg3 options:(NSUInteger)arg4 ;
-(id)iconListViewAtIndex:(NSInteger)arg1 inFolder:(id)arg2 createIfNecessary:(BOOL)arg3 ;
-(id)rootFolder;
-(NSInteger)maxIconCountForListInFolderClass:(Class)arg1;
-(void)removeIcon:(id)arg1 compactFolder:(BOOL)arg2;
-(void)removeIcon:(id)arg1 options:(unsigned long long)arg2;
-(id)folderIconListAtIndex:(NSInteger)arg1 ;
-(id)_currentFolderController;
-(void)setIsEditing:(BOOL)arg1;
-(BOOL)isEditing;
@end

@interface SBFolderController
@property(readonly, nonatomic) NSInteger currentPageIndex;
-(BOOL)setCurrentPageIndex:(NSInteger)arg1 animated:(BOOL)arg2;
-(void)_doAutoScrollByPageCount:(NSInteger)arg1;
@end

@interface UIApplication (DefaultPage)
+(id)sharedApplication;
@end

@interface SpringBoard : UIApplication
-(void)_handleMenuButtonEvent;
-(void)_simulateHomeButtonPress;
-(id)_accessibilityFrontMostApplication;
@end

@interface SBLeafIcon
-(id)applicationBundleID;
@end

@interface SBDownloadingIcon : SBLeafIcon
@end

@interface SBApplicationIcon : SBLeafIcon
@end

static NSString *const kIdentifier = @"com.dgh0st.defaultpage";
static NSString *const kSettingsPath = @"/var/mobile/Library/Preferences/com.dgh0st.defaultpage.plist";

static BOOL isEnabled = YES;
static BOOL isFolderPagingEnabled = NO;
static BOOL isPageNumberFolderCloseEnabled = NO;
static BOOL isUnlockResetEnabled = NO;
static BOOL isForceHomescreenEnabled = NO;
static BOOL isAutoSubtractEnabled = YES;
static BOOL isAppCloseResetEnabled = NO;
static BOOL isDefaultDownloadPage = NO;
static NSInteger pageNumber = 0;
static NSInteger downloadPageNumber = 1;

static void PreferencesChanged() {
	CFPreferencesAppSynchronize(CFSTR("com.dgh0st.defaultpage"));

	NSDictionary *prefs = nil;
	if ([NSHomeDirectory() isEqualToString:@"/var/mobile"]) {
		CFArrayRef keyList = CFPreferencesCopyKeyList((CFStringRef)kIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
		if (keyList) {
			prefs = (NSDictionary *)CFPreferencesCopyMultiple(keyList, (CFStringRef)kIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
			if (!prefs) {
				prefs = [NSDictionary new];
			}
			CFRelease(keyList);
		}
	} else {
		prefs = [[NSDictionary alloc] initWithContentsOfFile:kSettingsPath];
	}

	isEnabled = [prefs objectForKey:@"isEnabled"] ? [[prefs objectForKey:@"isEnabled"] boolValue] : YES;
	isFolderPagingEnabled = [prefs objectForKey:@"isFolderPagingEnabled"] ? [[prefs objectForKey:@"isFolderPagingEnabled"] boolValue] : NO;
	isPageNumberFolderCloseEnabled = [prefs objectForKey:@"isFolderPagingEnabled"] ? [[prefs objectForKey:@"isFolderPagingEnabled"] boolValue] : NO;
	isPageNumberFolderCloseEnabled = [prefs objectForKey:@"isPageNumberFolderCloseEnabled"] ? [[prefs objectForKey:@"isPageNumberFolderCloseEnabled"] boolValue] : NO;
	isUnlockResetEnabled = [prefs objectForKey:@"isUnlockResetEnabled"] ? [[prefs objectForKey:@"isUnlockResetEnabled"] boolValue] : NO;
	isForceHomescreenEnabled = [prefs objectForKey:@"isForceHomescreenEnabled"] ? [[prefs objectForKey:@"isForceHomescreenEnabled"] boolValue] : NO;
	isAutoSubtractEnabled = [prefs objectForKey:@"isAutoSubtractEnabled"] ? [[prefs objectForKey:@"isAutoSubtractEnabled"] boolValue] : YES;
	isAppCloseResetEnabled = [prefs objectForKey:@"isAppCloseResetEnabled"] ? [[prefs objectForKey:@"isAppCloseResetEnabled"] boolValue] : NO;
	isDefaultDownloadPage = [prefs objectForKey:@"isDefaultDownloadPage"] ? [[prefs objectForKey:@"isDefaultDownloadPage"] boolValue] : NO;
	pageNumber = [prefs objectForKey:@"pageNumber"] ? [[prefs objectForKey:@"pageNumber"] intValue] : 0;
	downloadPageNumber = [prefs objectForKey:@"downloadPageNumber"] ? [[prefs objectForKey:@"downloadPageNumber"] intValue] : 1;

	[prefs release];
}

static void DeviceLockStatusChanged() {
	static BOOL isFirstDeviceLockStatusChange = YES;
	if (isEnabled) {
		SBIconController *iconController = [%c(SBIconController) sharedInstance];
		if (isFirstDeviceLockStatusChange || (isUnlockResetEnabled && [iconController _iconListIndexIsValid: pageNumber] && [iconController currentIconListIndex] != pageNumber)) {
			[iconController scrollToIconListAtIndex:pageNumber animate:NO];
			isFirstDeviceLockStatusChange = NO;
		}
	}
}

static void ApplicationDidFinishLaunch() {
	static BOOL isFirstDeviceLockStatusChange = YES;
	if (isEnabled && isFirstDeviceLockStatusChange) {
		SBIconController *iconController = [%c(SBIconController) sharedInstance];
		[iconController scrollToIconListAtIndex:pageNumber animate:NO];
		isFirstDeviceLockStatusChange = NO;
	}
}

%hook SBIconController
-(void)handleHomeButtonTap {
	if (isEnabled) {
		if ([self isEditing]) {
			[self setIsEditing:NO]; // end editing mode
			return;
		}
		NSInteger pageNum = pageNumber;
		while (isAutoSubtractEnabled && ![self _iconListIndexIsValid:pageNum] && pageNum > 0) {
			pageNum--;
		}
		if (([self respondsToSelector:@selector(isNewsstandOpen)] && [self isNewsstandOpen]) || (!isFolderPagingEnabled && [self hasOpenFolder])) {
			%orig;
		} else 	if (isFolderPagingEnabled && [self hasOpenFolder]) {
			pageNum = pageNumber;
			if (isPageNumberFolderCloseEnabled && ([self currentFolderIconListIndex] == pageNum || pageNum == -1)) {
				%orig;
			} else {
				while (isAutoSubtractEnabled && ![self folderIconListAtIndex:pageNum]) {
					pageNum--;
				}
				if ([[self _currentFolderController] respondsToSelector:@selector(_doAutoScrollByPageCount:)])
					[[self _currentFolderController] _doAutoScrollByPageCount:pageNum - [self currentFolderIconListIndex]];
				else
					[[self _currentFolderController] setCurrentPageIndex:pageNum animated:YES];
			}
		} else if (pageNum == -1) {
			if ([self respondsToSelector:@selector(_presentRightEdgeSpotlight:)])
				[self _presentRightEdgeSpotlight:YES];
			else if ([self respondsToSelector:@selector(_presentRightEdgeTodayView:)])
				[self _presentRightEdgeTodayView:YES];
		} else if ([self _iconListIndexIsValid: pageNum] && [self currentIconListIndex] != pageNum) {
			// %orig; // not sure what the side effects are of not calling this are
			[self scrollToIconListAtIndex:pageNum animate:YES];
		}
	} else {
		%orig;
	}
}

-(void)viewWillAppear:(BOOL)arg1 {
	if (isEnabled) {
		if (isAppCloseResetEnabled && [self _iconListIndexIsValid:pageNumber] && [self currentIconListIndex] != pageNumber)
			[self scrollToIconListAtIndex:pageNumber animate:NO];
	}
	%orig(arg1);
}

-(void)addNewIconToDesignatedLocation:(id)arg1 animate:(BOOL)arg2 scrollToList:(BOOL)arg3 saveIconState:(BOOL)arg4 {
	NSArray *sortedDisplayIdentifiers;
	[[ALApplicationList sharedApplicationList] applicationsFilteredUsingPredicate:nil onlyVisible:YES titleSortedIdentifiers:&sortedDisplayIdentifiers];
	if (isEnabled && isDefaultDownloadPage && ![sortedDisplayIdentifiers containsObject:[arg1 applicationBundleID]]) {
		if ([self respondsToSelector:@selector(removeIcon:compactFolder:)])
			[self removeIcon:arg1 compactFolder:NO];
		else if ([self respondsToSelector:@selector(removeIcon:options:)])
			[self removeIcon:arg1 options:0];
		if ([self respondsToSelector:@selector(insertIcon:intoListView:iconIndex:moveNow:)])
			[self insertIcon:arg1 intoListView:[self iconListViewAtIndex:downloadPageNumber inFolder:[self rootFolder] createIfNecessary:YES] iconIndex:([self maxIconCountForListInFolderClass:[[self rootFolder] class]] - 1) moveNow:YES];
		else if ([self respondsToSelector:@selector(insertIcon:intoListView:iconIndex:options:)])
			[self insertIcon:arg1 intoListView:[self iconListViewAtIndex:downloadPageNumber inFolder:[self rootFolder] createIfNecessary:YES] iconIndex:([self maxIconCountForListInFolderClass:[[self rootFolder] class]] - 1) options:0];
	}
	%orig(arg1, arg2, arg3, arg4);
}
%end

%hook SBDashBoardViewController
-(void)deactivate {
	if (isEnabled && isForceHomescreenEnabled && [(SpringBoard *)[UIApplication sharedApplication] _accessibilityFrontMostApplication] != nil) {
		if ([(SpringBoard *)[%c(UIApplication) sharedApplication] respondsToSelector:@selector(_handleMenuButtonEvent)]) {
			[(SpringBoard *)[%c(UIApplication) sharedApplication] _handleMenuButtonEvent];
		} else {
			[(SpringBoard *)[%c(UIApplication) sharedApplication] _simulateHomeButtonPress];
		}
	}
	%orig;
}
%end

%dtor {
	CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(),
										NULL,
										CFSTR("com.dgh0st.defaultpage/settingschanged"),
										NULL);

	CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(),
										NULL,
										CFSTR("com.apple.springboard.DeviceLockStatusChanged"),
										NULL);

	CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(),
										NULL,
										CFSTR("UIApplicationDidFinishLaunchingNotification"),
										NULL);
}

%ctor {
	PreferencesChanged();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
				    NULL,
				    (CFNotificationCallback)PreferencesChanged,
				    CFSTR("com.dgh0st.defaultpage/settingschanged"),
				    NULL,
				    CFNotificationSuspensionBehaviorDeliverImmediately);

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
				    NULL,
				    (CFNotificationCallback)DeviceLockStatusChanged,
				    CFSTR("com.apple.springboard.DeviceLockStatusChanged"),
				    NULL,
				    CFNotificationSuspensionBehaviorDeliverImmediately);

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
				    NULL,
				    (CFNotificationCallback)ApplicationDidFinishLaunch,
				    CFSTR("UIApplicationDidFinishLaunchingNotification"),
				    NULL,
				    CFNotificationSuspensionBehaviorDeliverImmediately);
}
