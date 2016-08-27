#include <SpringBoard/SpringBoard.h>

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
-(id)insertIcon:(id)arg1 intoListView:(id)arg2 iconIndex:(NSInteger)arg3 moveNow:(BOOL)arg4 pop:(BOOL)arg5 ;
-(id)iconListViewAtIndex:(NSInteger)arg1 inFolder:(id)arg2 createIfNecessary:(BOOL)arg3 ;
-(id)rootFolder;
-(NSInteger)maxIconCountForListInFolderClass:(Class)arg1 ;
-(void)removeIcon:(id)arg1 compactFolder:(BOOL)arg2 ;
@end

@interface UIApplication (DefaultPage)
+(id)sharedApplication;
@end

@interface SpringBoard (DefaultPage)
-(void)_handleMenuButtonEvent;
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
-(void)handleHomeButtonTap{
	if(boolValueForKey(kIsEnabled)){
		NSInteger pageNum = intValueForKey(kPageNumber, 0);
		while(boolValueForKey(kIsAutoSubtractEnabled) && ![self _iconListIndexIsValid:pageNum] && pageNum > 0){
			pageNum--;
		}
		if(([%c(self) respondsToSelector:@selector(isNewsstandOpen)] && [self isNewsstandOpen]) || (!boolValueForKey(kIsFolderPagingEnabled) && [self hasOpenFolder])){
			%orig;
		} else 	if(boolValueForKey(kIsFolderPagingEnabled) && [self hasOpenFolder]){
			if(boolValueForKey(kIsPageNumberFolderCloseEnabled) && ([self currentFolderIconListIndex] == pageNum || pageNum == -1)){
				%orig;
			} else if([self _iconListIndexIsValid:pageNum]){
				while(boolValueForKey(kIsAutoSubtractEnabled) && ![self scrollToIconListAtIndex:pageNum animate:YES]){
					pageNum--;
				}
				[self _runScrollFolderTest:pageNum];
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
		[(SpringBoard *)[%c(UIApplication) sharedApplication] _handleMenuButtonEvent];
	}
	%orig;
	if(boolValueForKey(kIsEnabled)){
		NSInteger pageNum = intValueForKey(kPageNumber, 0);
		if(boolValueForKey(kIsUnlockResetEnabled) && [self _iconListIndexIsValid: pageNum] && [self currentIconListIndex] != pageNum){
			[self scrollToIconListAtIndex:pageNum animate:NO];
		}
	}
}


-(void)_launchIcon:(id)arg1{
	if(boolValueForKey(kIsEnabled) && ![[arg1 class] isEqual: %c(SBFolderIcon)]){
		NSInteger pageNum = intValueForKey(kPageNumber, 0);
		if(boolValueForKey(kIsAppCloseResetEnabled) && [self _iconListIndexIsValid: pageNum] && [self currentIconListIndex] != pageNum){
			[self scrollToIconListAtIndex:pageNum animate:NO];
		}
	}
	%orig(arg1);
}

-(void)unscatterAnimated:(_Bool)arg1 afterDelay:(double)arg2 withCompletion:(id)arg3{
	if(boolValueForKey(kIsEnabled)){
		NSInteger pageNum = intValueForKey(kPageNumber, 0);
		if(boolValueForKey(kIsAppCloseResetEnabled) && [self _iconListIndexIsValid: pageNum] && [self currentIconListIndex] != pageNum){
			[self scrollToIconListAtIndex:pageNum animate:NO];
		}
	}
	%orig(arg1, arg2, arg3);
}

-(void)addNewIconToDesignatedLocation:(id)arg1 animate:(BOOL)arg2 scrollToList:(BOOL)arg3 saveIconState:(BOOL)arg4 {
	if (boolValueForKey(kIsEnabled) && boolValueForKey(kIsDefaultDownloadPage) && [[arg1 class] isEqual:%c(SBDownloadingIcon)]) {
		NSInteger downloadPageNum = intValueForKey(kDownloadPageNumber, 0);
		if (arg4) {
			[self insertIcon:arg1 intoListView:[self iconListViewAtIndex:downloadPageNum inFolder:[self rootFolder] createIfNecessary:YES] iconIndex:([self maxIconCountForListInFolderClass:[[self rootFolder] class]] - 1) moveNow:YES pop:YES];
		} else {
			[self removeIcon:arg1 compactFolder:NO];
			[self insertIcon:arg1 intoListView:[self iconListViewAtIndex:downloadPageNum inFolder:[self rootFolder] createIfNecessary:YES] iconIndex:([self maxIconCountForListInFolderClass:[[self rootFolder] class]] - 1) moveNow:YES];
		}
	}
	%orig(arg1, arg2, arg3, arg4);
}
%end

%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
				    NULL,
				    (CFNotificationCallback)PreferencesChanged,
				    CFSTR("com.dgh0st.defaultpage/settingschanged"),
				    NULL,
				    CFNotificationSuspensionBehaviorDeliverImmediately);
}
