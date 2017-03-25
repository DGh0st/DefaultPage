#include <notify.h>

@interface ALApplicationList
@property (nonatomic, readonly) NSDictionary *applications;
-(id)sharedApplicationList;
- (NSDictionary *)applicationsFilteredUsingPredicate:(NSPredicate *)predicate onlyVisible:(BOOL)onlyVisible titleSortedIdentifiers:(NSArray **)outSortedByTitle;
@end


@interface SBIconController
-(BOOL)isNewsstandOpen;
-(BOOL)hasOpenFolder;
-(BOOL)_iconListIndexIsValid:(NSInteger)arg1;
-(BOOL)scrollToIconListAtIndex:(NSInteger)arg1 animate:(BOOL)arg2;
-(NSInteger)currentIconListIndex;
-(NSInteger)currentFolderIconListIndex;
-(void)_runScrollFolderTest:(NSInteger)arg1;
-(_Bool)_presentRightEdgeSpotlight:(_Bool)arg1;
-(id)insertIcon:(id)arg1 intoListView:(id)arg2 iconIndex:(NSInteger)arg3 moveNow:(BOOL)arg4 ;
-(id)iconListViewAtIndex:(NSInteger)arg1 inFolder:(id)arg2 createIfNecessary:(BOOL)arg3 ;
-(id)rootFolder;
-(NSInteger)maxIconCountForListInFolderClass:(Class)arg1 ;
-(void)removeIcon:(id)arg1 compactFolder:(BOOL)arg2 ;
-(id)folderIconListAtIndex:(NSInteger)arg1 ;
-(id)_currentFolderController;
@end

@interface SBFolderController
-(void)_doAutoScrollByPageCount:(NSInteger)arg1 ;
@end

@interface UIApplication (DefaultPage)
+(id)sharedApplication;
@end

@interface SpringBoard
-(void)_handleMenuButtonEvent;
-(void)_simulateHomeButtonPress;
-(BOOL)respondsToSelector:(SEL)aSelector;
@end

@interface SBLeafIcon
-(id)applicationBundleID;
@end

@interface SBDownloadingIcon : SBLeafIcon
@end

@interface SBApplicationIcon : SBLeafIcon
@end

static NSString *const identifier = @"com.dgh0st.defaultpage";
static NSString *const kIsEnabled = @"isEnabled";
static NSString *const kIsFolderPagingEnabled = @"isFolderPagingEnabled";
static NSString *const kIsPageNumberFolderCloseEnabled = @"isPageNumberFolderCloseEnabled";
static NSString *const kIsUnlockResetEnabled = @"isUnlockResetEnabled";
static NSString *const kIsForceHomescreenEnabled = @"isForceHomescreenEnabled";
static NSString *const kIsAutoSubtractEnabled = @"isAutoSubtractEnabled";
static NSString *const kIsAppCloseResetEnabled = @"isAppCloseResetEnabled";
static NSString *const kIsDefaultDownloadPage = @"isDefaultDownloadPage";
static NSString *const kPageNumber = @"pageNumber";
static NSString *const kDownloadPageNumber = @"downloadPageNumber";

static void PreferencesChanged() {
	CFPreferencesAppSynchronize(CFSTR("com.dgh0st.defaultpage"));
}

static BOOL boolValueForKey(NSString *key){
	NSNumber *result = (__bridge NSNumber *)CFPreferencesCopyAppValue((CFStringRef)key, (CFStringRef)identifier);
	BOOL temp = result ? [result boolValue] : NO;
	[result release];
	return temp;
}

static NSInteger intValueForKey(NSString *key, NSInteger defaultValue){
	NSNumber *result= (__bridge NSNumber *)CFPreferencesCopyAppValue((CFStringRef)key, (CFStringRef)identifier);
	NSInteger temp = result ? [result intValue] : defaultValue;
	[result release];
	return temp;
}

%hook SBIconController
-(void)handleHomeButtonTap {
	if(boolValueForKey(kIsEnabled)){
		NSInteger pageNum = intValueForKey(kPageNumber, 0);
		while(boolValueForKey(kIsAutoSubtractEnabled) && ![self _iconListIndexIsValid:pageNum] && pageNum > 0){
			pageNum--;
		}
		if(([%c(self) respondsToSelector:@selector(isNewsstandOpen)] && [self isNewsstandOpen]) || (!boolValueForKey(kIsFolderPagingEnabled) && [self hasOpenFolder])){
			%orig;
		} else 	if(boolValueForKey(kIsFolderPagingEnabled) && [self hasOpenFolder]){
			pageNum = intValueForKey(kPageNumber, 0);
			if(boolValueForKey(kIsPageNumberFolderCloseEnabled) && ([self currentFolderIconListIndex] == pageNum || pageNum == -1)){
				%orig;
			} else {
				while(boolValueForKey(kIsAutoSubtractEnabled) && ![self folderIconListAtIndex:pageNum]){
					pageNum--;
				}
				[[self _currentFolderController] _doAutoScrollByPageCount:pageNum - [self currentFolderIconListIndex]];
			}
		} else if(pageNum == -1){
			[self _presentRightEdgeSpotlight:YES];
		} else if([self _iconListIndexIsValid: pageNum] && [self currentIconListIndex] != pageNum){
			%orig;
			[self scrollToIconListAtIndex:pageNum animate:YES];
		}
	} else {
		%orig;
	}
}

-(void)_lockScreenUIWillLock:(id)arg1{
	if (boolValueForKey(kIsEnabled) && boolValueForKey(kIsForceHomescreenEnabled)) {
		if ([(SpringBoard *)[%c(UIApplication) sharedApplication] respondsToSelector:@selector(_handleMenuButtonEvent)]) {
			[(SpringBoard *)[%c(UIApplication) sharedApplication] _handleMenuButtonEvent];
		} else {
			[(SpringBoard *)[%c(UIApplication) sharedApplication] _simulateHomeButtonPress];
		}
	}
	%orig(arg1);
	if(boolValueForKey(kIsEnabled)){
		NSInteger pageNum = intValueForKey(kPageNumber, 0);
		if(boolValueForKey(kIsUnlockResetEnabled) && [self _iconListIndexIsValid: pageNum] && [self currentIconListIndex] != pageNum){
			[self scrollToIconListAtIndex:pageNum animate:NO];
		}
	}
}

-(void)viewWillAppear:(BOOL)arg1 {
	if(boolValueForKey(kIsEnabled)) {
		NSInteger pageNum = intValueForKey(kPageNumber, 0);
		if(boolValueForKey(kIsAppCloseResetEnabled) && [self _iconListIndexIsValid: pageNum] && [self currentIconListIndex] != pageNum){
			[self scrollToIconListAtIndex:pageNum animate:NO];
		}
	}
	%orig(arg1);
}

-(void)addNewIconToDesignatedLocation:(id)arg1 animate:(BOOL)arg2 scrollToList:(BOOL)arg3 saveIconState:(BOOL)arg4 {
	NSArray *sortedDisplayIdentifiers;
	[[ALApplicationList sharedApplicationList] applicationsFilteredUsingPredicate:nil onlyVisible:YES titleSortedIdentifiers:&sortedDisplayIdentifiers];
	if (boolValueForKey(kIsEnabled) && boolValueForKey(kIsDefaultDownloadPage) && ![sortedDisplayIdentifiers containsObject:[arg1 applicationBundleID]]) {
		NSInteger downloadPageNum = intValueForKey(kDownloadPageNumber, 0);
		[self removeIcon:arg1 compactFolder:NO];
		[self insertIcon:arg1 intoListView:[self iconListViewAtIndex:downloadPageNum inFolder:[self rootFolder] createIfNecessary:YES] iconIndex:([self maxIconCountForListInFolderClass:[[self rootFolder] class]] - 1) moveNow:YES];
	}
	%orig(arg1, arg2, arg3, arg4);
}
%end

%hook SBDashBoardViewController
-(void)deactivate {
	if (boolValueForKey(kIsEnabled) && boolValueForKey(kIsForceHomescreenEnabled)) {
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
}

%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
				    NULL,
				    (CFNotificationCallback)PreferencesChanged,
				    CFSTR("com.dgh0st.defaultpage/settingschanged"),
				    NULL,
				    CFNotificationSuspensionBehaviorDeliverImmediately);
}
