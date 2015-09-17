@interface SBIconController
-(BOOL)isNewsstandOpen;
-(BOOL)hasOpenFolder;
-(BOOL)_iconListIndexIsValid:(NSInteger)arg1 ;
-(BOOL)scrollToIconListAtIndex:(NSInteger)arg1 animate:(BOOL)arg2 ;
-(NSInteger)currentIconListIndex;
-(id)firstPageLeafIdentifiers;
@end

static NSInteger pageNum= 1;

%hook SBIconController
-(void)handleHomeButtonTap{
	if([self _iconListIndexIsValid: pageNum] && [self currentIconListIndex] != pageNum){
		%orig;
		[self scrollToIconListAtIndex:pageNum animate:YES];
	} else if([self hasOpenFolder] || [self isNewsstandOpen]){
		%orig;
	}
	NSLog(@"DGh0st-DefaultPage SBIconController handleHomeButtonTap firstPageLeafIdentifiers (class) = %@ (%@)", [self firstPageLeafIdentifiers], [[[self firstPageLeafIdentifiers] class] description]);
}
%end
