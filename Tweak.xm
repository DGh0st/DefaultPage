#include <notify.h>

@interface ALApplicationList
@property (nonatomic, readonly) NSDictionary *applications;
-(id)sharedApplicationList;
-(NSDictionary *)applicationsFilteredUsingPredicate:(NSPredicate *)predicate onlyVisible:(BOOL)onlyVisible titleSortedIdentifiers:(NSArray **)outSortedByTitle;
@end

@interface SBFolderIcon : NSObject // 4 - 13
@end

@interface SBRootFolder : NSObject // 4 - 13
@property (assign, nonatomic, weak) SBFolderIcon *icon; // 6 - 13
@end

@interface SBIconListModel : NSObject // iOS 4 - 13
-(BOOL)addIcon:(id)arg1; // iOS 4 - 13
@end

@interface SBIconListView : UIView // iOS 4 - 13
-(SBIconListModel *)model; // iOS 4 - 13
@end

@interface SBFolderController : UIViewController // iOS 7 - 13
@property (nonatomic,readonly) NSInteger firstIconPageIndex; // iOS 13
@property (nonatomic,readonly) NSInteger lastIconPageIndex; // iOS 13
@property (nonatomic,readonly) NSInteger defaultPageIndex; // iOS 13
@property (assign, nonatomic, weak) id folderDelegate; // iOS 12 - 13
@property(readonly, nonatomic) NSInteger currentPageIndex;
-(BOOL)setCurrentPageIndex:(NSInteger)arg1 animated:(BOOL)arg2;
-(void)_doAutoScrollByPageCount:(NSInteger)arg1;
@end

@interface SBRootFolderController : SBFolderController // iOS 7 - 13
@property (nonatomic,readonly) NSInteger todayViewPageIndex; // iOS 13
@end

@interface SBHIconManager : NSObject // iOS 13
@property (nonatomic,retain) SBRootFolder *rootFolder; // iOS 13
@property (nonatomic,retain) SBRootFolderController *rootFolderController; // iOS 13
-(BOOL)isEditing; // iOS 13
-(void)setEditing:(BOOL)arg1; // iOS 13
-(void)removeIcon:(id)arg1 options:(NSUInteger)arg2 completion:(id)arg3; // iOS 13
// -(void)addIcons:(id)arg1 intoFolderIcon:(id)arg2 openFolderOnFinish:(BOOL)arg3 complete:(id)arg4;
-(SBIconListView *)iconListViewAtIndex:(NSUInteger)arg1 inFolder:(id)arg2 createIfNecessary:(BOOL)arg3; // iOS 13
@end

@interface SBIconController : UIViewController // iOS 3 - 13
@property (nonatomic,readonly) SBHIconManager *iconManager; // iOS 13
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
-(id)_currentFolderController; // iOS 7 - 13
-(id)_rootFolderController; // iOS 7 - 13
-(void)setIsEditing:(BOOL)arg1;
-(BOOL)isEditing;
@end

@interface SBCoverSheetPresentationManager : NSObject // iOS 11 - 13
+(id)sharedInstance; // iOS 11 - 13
-(BOOL)hasBeenDismissedSinceKeybagLock; // iOS 11 - 13.1
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

		if (isFirstDeviceLockStatusChange || isUnlockResetEnabled) {
			if ([iconController respondsToSelector:@selector(_iconListIndexIsValid:)]) {
				if ([iconController _iconListIndexIsValid: pageNumber] && [iconController currentIconListIndex] != pageNumber)
					[iconController scrollToIconListAtIndex:pageNumber animate:NO];
			} else {
				SBRootFolderController *rootFolderController = [iconController _rootFolderController];
				if (rootFolderController.defaultPageIndex != rootFolderController.currentPageIndex)
					[rootFolderController setCurrentPageIndex:rootFolderController.defaultPageIndex animated:NO];
			}
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

%group preiOS13
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
%end

%group forceHomescreenpreiOS11
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
%end

%group forceHomescreeniOS11plus
%hook SBCoverSheetSlidingViewController
-(void)_dismissCoverSheetAnimated:(BOOL)arg1 withCompletion:(void(^)())arg2 {
	if (isEnabled && isForceHomescreenEnabled) {
		void (^completion)() = ^{
			if (arg2 != nil)
				arg2();

			if ([[%c(SBCoverSheetPresentationManager) sharedInstance] hasBeenDismissedSinceKeybagLock] && [(SpringBoard *)[UIApplication sharedApplication] _accessibilityFrontMostApplication] != nil)
				[(SpringBoard *)[%c(UIApplication) sharedApplication] _simulateHomeButtonPress];
		};
		%orig(arg1, completion);
	} else {
		%orig(arg1, arg2);
	}
}
%end
%end

%group iOS13plus
%hook SBFolderController
-(NSInteger)defaultPageIndex {
	if (isEnabled) {
		NSInteger pageNum = pageNumber;

		// get a valid page number
		if (isAutoSubtractEnabled && pageNum > self.lastIconPageIndex - self.firstIconPageIndex && pageNum > 0)
			pageNum = self.lastIconPageIndex - self.firstIconPageIndex;

		// folder's delegate is of type SBRootFolderController
		// root folder's delegate is of type SBHIconManager
		if ([self.folderDelegate isKindOfClass:%c(SBRootFolderController)]) {
			if (!isFolderPagingEnabled || pageNum == -1)
				return %orig();
			return pageNum + self.firstIconPageIndex;
		}

		// spotlight
		if (pageNum == -1)
			return %orig();

		// default selected + offset of first page
		return pageNum + self.firstIconPageIndex;
	}
	return %orig();
}
%end

%hook SBIconController
-(void)handleHomeButtonTap {
	if (isEnabled) {
		// end editing mode
		if ([self.iconManager isEditing]) {
			[self.iconManager setEditing:NO];
			return;
		}

		SBFolderController *folderController = [self _currentFolderController];
		if ([folderController isKindOfClass:%c(SBRootFolderController)]) {
			SBRootFolderController *rootFolderController = (SBRootFolderController *)folderController;

			// scroll to today page view if needed otherwise do default behavior of scrolling to default page
			if (pageNumber == -1 && rootFolderController.todayViewPageIndex != NSIntegerMax)
				[rootFolderController setCurrentPageIndex:rootFolderController.todayViewPageIndex animated:YES];
			else
				[rootFolderController setCurrentPageIndex:rootFolderController.defaultPageIndex animated:YES];
		} else if (isFolderPagingEnabled) {
			// close out of folder if same page close is enabled otherwise scroll to selected default page
			if (isPageNumberFolderCloseEnabled && folderController.defaultPageIndex == folderController.currentPageIndex)
				%orig();
			else
				[folderController setCurrentPageIndex:folderController.defaultPageIndex animated:YES];
		} else {
			%orig();
		}
	} else {
		%orig();
	}
}

-(void)viewWillAppear:(BOOL)arg1 {
	if (isEnabled) {
		SBFolderController *folderController = [self _currentFolderController];
		if (isAppCloseResetEnabled && folderController.defaultPageIndex != folderController.currentPageIndex)
			[folderController setCurrentPageIndex:folderController.defaultPageIndex animated:NO];
	}
	%orig(arg1);
}
%end

%hook SBHIconManager
-(void)addNewIconToDesignatedLocation:(id)arg1 animate:(BOOL)arg2 scrollToList:(BOOL)arg3 saveIconState:(BOOL)arg4 {
	NSArray *sortedDisplayIdentifiers;
	[[ALApplicationList sharedApplicationList] applicationsFilteredUsingPredicate:nil onlyVisible:YES titleSortedIdentifiers:&sortedDisplayIdentifiers];
	if (isEnabled && isDefaultDownloadPage && ![sortedDisplayIdentifiers containsObject:[arg1 applicationBundleID]]) {
		[self removeIcon:arg1 options:0 completion:^{
			[[[self iconListViewAtIndex:downloadPageNumber inFolder:self.rootFolder createIfNecessary:YES] model] addIcon:arg1];
		}];
	}
	%orig(arg1, arg2, arg3, arg4);
}
%end
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

	if (%c(SBHIconManager) == nil) {
		CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(),
											NULL,
											CFSTR("UIApplicationDidFinishLaunchingNotification"),
											NULL);
	}
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

	if (%c(SBHIconManager)) {
		%init(iOS13plus);
	} else {
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
						NULL,
						(CFNotificationCallback)ApplicationDidFinishLaunch,
						CFSTR("UIApplicationDidFinishLaunchingNotification"),
						NULL,
						CFNotificationSuspensionBehaviorDeliverImmediately);

		%init(preiOS13);
	}

	if (%c(SBCoverSheetSlidingViewController)) {
		%init(forceHomescreeniOS11plus);
	} else {
		%init(forceHomescreenpreiOS11);
	}
}
