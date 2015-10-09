@interface SBIconController
-(BOOL)isNewsstandOpen;
-(BOOL)hasOpenFolder;
-(BOOL)_iconListIndexIsValid:(NSInteger)arg1;
-(BOOL)scrollToIconListAtIndex:(NSInteger)arg1 animate:(BOOL)arg2;
-(NSInteger)currentIconListIndex;
-(NSInteger)currentFolderIconListIndex;
-(void)_runScrollFolderTest:(NSInteger)arg1;
@end

static NSString *const identifier = @"com.dgh0st.defaultpage";
static NSString *const kIsEnabled = @"isEnabled";
static NSString *const kIsFolderPagingEnabled = @"isFolderPagingEnabled";
static NSString *const kIsPageNumberFolderCloseEnabled = @"isPageNumberFolderCloseEnabled";
static NSString *const kIsUnlockResetEnabled = @"isUnlockResetEnabled";
static NSString *const kIsAutoSubtractEnabled = @"isAutoSubtractEnabled";
static NSString *const kPageNumber = @"pageNumber";

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
		while(boolValueForKey(kIsAutoSubtractEnabled) && ![self _iconListIndexIsValid:pageNum]){
			pageNum--;
		}
		if([self isNewsstandOpen] || (!boolValueForKey(kIsFolderPagingEnabled) && [self hasOpenFolder])){
			%orig;
		} else 	if(boolValueForKey(kIsFolderPagingEnabled) && [self hasOpenFolder]){
			if(boolValueForKey(kIsPageNumberFolderCloseEnabled) && [self currentFolderIconListIndex] == pageNum){
				%orig;
			} else if([self _iconListIndexIsValid:pageNum]){
				while(boolValueForKey(kIsAutoSubtractEnabled) && ![self scrollToIconListAtIndex:pageNum animate:YES]){
					pageNum--;
				}
				[self _runScrollFolderTest:pageNum];
			}
		} else if([self _iconListIndexIsValid: pageNum] && [self currentIconListIndex] != pageNum){
			%orig;
			[self scrollToIconListAtIndex:pageNum animate:YES];
		}
	} else {
		%orig;
	}
}
-(void)_lockScreenUIWillLock:(id)arg1{
	%orig;
	if(boolValueForKey(kIsEnabled)){
		NSInteger pageNum = intValueForKey(kPageNumber, 0);
		if(boolValueForKey(kIsUnlockResetEnabled) && [self _iconListIndexIsValid: pageNum] && [self currentIconListIndex] != pageNum){
			[self scrollToIconListAtIndex:pageNum animate:YES];
		}
	}
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
