#include "addsourceRootListController.h"

@implementation addsourceRootListController

#define kPreferencesPath @"/var/mobile/Library/Preferences/com.yuosaf01.addsource.plist"

#define kPreferencesChanged "com.yuosaf01.addsource-preferencesChanged"

#define kBundlePath @"/Library/PreferenceBundles/AddSource.bundle"

- (instancetype)init {
    self = [super init];
    if (self) {
        HBAppearanceSettings *appearanceSettings = [[HBAppearanceSettings alloc] init];
        appearanceSettings.tintColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:1];
        appearanceSettings.tableViewCellSeparatorColor = [UIColor colorWithWhite:0 alpha:0];
        self.hb_appearanceSettings = appearanceSettings;
    }
    
    return self;
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"AddSource" target:self] retain];
	}

	return _specifiers;
}

+ (NSString *)hb_specifierPlist {
    return @"AddSource";
    
}

-(void)loadView {
    [super loadView];
    // Create Button Share Tweak
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(shareTapped)];

}
  // Color Switch
+ (UIColor *)hb_tintColor {
    return [UIColor colorWithRed:0.0/255.0 green:119.0/255.0 blue:190.0/255.0 alpha:1.0];
}
  // Tweet Twitter
- (void)shareTapped {
    SLComposeViewController * composeController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [composeController setInitialText:@"I'm using #addsource, By @yuosaf01 "];
    
    [self.parentController presentViewController:composeController animated:YES completion:nil];
    
}

-(void)Res {
    pid_t pid;
    const char* args[] = {"killall", "Cydia", NULL};
    posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
}

@end
