@interface SBIconController
-(BOOL)isNewsstandOpen;
-(BOOL)hasOpenFolder;
-(BOOL)_iconListIndexIsValid:(NSInteger)arg1;
-(BOOL)scrollToIconListAtIndex:(NSInteger)arg1 animate:(BOOL)arg2;
-(NSInteger)currentIconListIndex;
-(NSInteger)currentFolderIconListIndex;
-(void)_runScrollFolderTest:(NSInteger)arg1;
-(void)closeFolderAnimated:(BOOL)arg1;
@end

static NSInteger pageNum= 1;

%hook SBIconController
-(void)handleHomeButtonTap{
	if([self isNewsstandOpen]){
		[self closeFolderAnimated:YES];
	} else 	if([self hasOpenFolder]){
		if([self currentFolderIconListIndex] == pageNum){
			[self closeFolderAnimated:YES];
		} else if([self _iconListIndexIsValid:pageNum]){
			[self _runScrollFolderTest:pageNum];
		}
	} else if([self _iconListIndexIsValid: pageNum] && [self currentIconListIndex] != pageNum){
		%orig;
		[self scrollToIconListAtIndex:pageNum animate:YES];
	}
}
-(void)_lockScreenUIWillLock:(id)arg1{
	%orig;
	if([self _iconListIndexIsValid: pageNum] && [self currentIconListIndex] != pageNum){
		[self scrollToIconListAtIndex:pageNum animate:YES];
	}
}
%end
