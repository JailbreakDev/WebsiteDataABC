#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTableCell.h>

@interface UIProgressHUD : UIView
-(id)initWithFrame:(CGRect)arg1 ;
-(void)dealloc;
-(void)drawRect:(CGRect)arg1 ;
-(void)layoutSubviews;
-(void)setText:(id)arg1 ;
-(void)setFontSize:(int)arg1 ;
-(void)hide;
-(id)_progressIndicator;
-(void)setShowsText:(BOOL)arg1 ;
-(void)showInView:(id)arg1 ;
-(void)done;
-(id)initWithWindow:(id)arg1 ;
-(void)show:(BOOL)arg1 ;
@end

static NSArray *oldSpecifiers = nil;

@interface SafariStorageSettingsController : PSListController
-(void)addSwitchSpecifier;
-(void)sortAlphabetically;
-(void)sortBySize;
@end

%group SafariHooks
%hook SafariStorageSettingsController

-(void)showAllDomainSpecifiers {

	%orig;

	[self addSwitchSpecifier];

	BOOL sortAlphabetically = [[self readPreferenceValue:[self specifierForID:@"sort_alphabetically"]] boolValue];

	if (sortAlphabetically) {
		[self sortAlphabetically];
	}

}

%new

-(void)addSwitchSpecifier {
	PSSpecifier *switchSpec = [PSSpecifier preferenceSpecifierNamed:@"Sort Alphabetically" target:self set:@selector(setSortAlphabetically:forSpecifier:) get:@selector(readPreferenceValue:) detail:nil cell:[PSTableCell cellTypeFromString:@"PSSwitchCell"] edit:nil];
	[switchSpec setProperty:@"kSortAlphabetically" forKey:@"key"];
	[switchSpec setProperty:@"com.sharedroutine.websitedataabc" forKey:@"defaults"];
	[switchSpec setProperty:[NSNumber numberWithBool:FALSE] forKey:@"default"];
	[switchSpec setIdentifier:@"sort_alphabetically"];
	[self insertSpecifier:switchSpec atIndex:0];
}

%new

-(void)sortAlphabetically {

	UIProgressHUD *HUD = [[UIProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
	[HUD setText:@"Sorting, please wait..."];
	[HUD show:TRUE];

	dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
    	NSArray *specs = [self specifiers];
		NSArray *sortedBySize = [specs filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.cellType == 4"]];

		oldSpecifiers = sortedBySize;

		NSArray *sortedArray = [sortedBySize sortedArrayUsingSelector:@selector(titleCompare:)];
	 	dispatch_async(dispatch_get_main_queue(),^{
	 		[self replaceContiguousSpecifiers:sortedBySize withSpecifiers:sortedArray animated:TRUE];
	 		[HUD hide];
	 	});
	});
}

%new

-(void)sortBySize {

	UIProgressHUD *HUD = [[UIProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
	[HUD setText:@"Sorting, please wait..."];
	[HUD show:TRUE];

	dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
    	NSArray *specs = [self specifiers];
		NSArray *sortedAlphabetically = [specs filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.cellType == 4"]];
	    dispatch_async(dispatch_get_main_queue(),^{
	 		[self replaceContiguousSpecifiers:sortedAlphabetically withSpecifiers:oldSpecifiers animated:TRUE];
	 		[HUD hide];
	 	});
	});
}

%new
-(void)setSortAlphabetically:(NSNumber *)value forSpecifier:(PSSpecifier *)spec {

	[self setPreferenceValue:value specifier:spec];
	[[NSUserDefaults standardUserDefaults] synchronize];

	if ([value integerValue] == 1) { //on, sort alphabetically
		[self sortAlphabetically];
	} else { //sort by size
		[self sortBySize];
	}
}

%end
%end

%hook PSListController
+ (void)initialize {
    if (self == %c(SafariStorageSettingsController)) {
        %init(SafariHooks);
    }
    %orig;
}

%end

%ctor {
	%init;
}
