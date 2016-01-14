@interface SBIconController
-(BOOL)isNewsstandOpen;
-(BOOL)hasOpenFolder;
-(BOOL)_iconListIndexIsValid:(NSInteger)arg1;
-(BOOL)scrollToIconListAtIndex:(NSInteger)arg1 animate:(BOOL)arg2;
-(NSInteger)currentIconListIndex;
-(NSInteger)currentFolderIconListIndex;
-(void)_runScrollFolderTest:(NSInteger)arg1;
-(_Bool)_presentRightEdgeSpotlight:(_Bool)arg1;
@end

static NSString *const identifier = @"com.dgh0st.defaultpage";
static NSString *const kIsEnabled = @"isEnabled";
static NSString *const kIsFolderPagingEnabled = @"isFolderPagingEnabled";
static NSString *const kIsPageNumberFolderCloseEnabled = @"isPageNumberFolderCloseEnabled";
static NSString *const kIsUnlockResetEnabled = @"isUnlockResetEnabled";
static NSString *const kIsAutoSubtractEnabled = @"isAutoSubtractEnabled";
static NSString *const kIsAppCloseResetEnabled = @"isAppCloseResetEnabled";
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
%end

%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
				    NULL,
				    (CFNotificationCallback)PreferencesChanged,
				    CFSTR("com.dgh0st.defaultpage/settingschanged"),
				    NULL,
				    CFNotificationSuspensionBehaviorDeliverImmediately);
}