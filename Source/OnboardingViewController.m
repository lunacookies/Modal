@implementation OnboardingViewController {
	id target;
	SEL action;
}

+ (instancetype)controllerWithTarget:(id)target_ action:(SEL)action_ {
	OnboardingViewController *result = [[OnboardingViewController alloc] init];
	result->target = target_;
	result->action = action_;
	return result;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	NSTextField *heading = [NSTextField labelWithString:@"Choose A Library Folder"];
	heading.font = [NSFont systemFontOfSize:24];

	NSTextField *label = [NSTextField wrappingLabelWithString:
	                @"Before you can use Modal, you must first pick a folder to use as your music library."];
	label.alignment = NSTextAlignmentCenter;
	label.textColor = NSColor.secondaryLabelColor;

	NSButton *button = [NSButton buttonWithTitle:@"Choose…" target:self action:@selector(chooseLibrary:)];

	NSStackView *stackView = [[NSStackView alloc] init];
	stackView.orientation = NSUserInterfaceLayoutOrientationVertical;
	stackView.spacing = 20;
	[stackView addView:heading inGravity:NSStackViewGravityCenter];
	[stackView addView:label inGravity:NSStackViewGravityCenter];
	[stackView addView:button inGravity:NSStackViewGravityCenter];

	[self.view addSubview:stackView];
	stackView.translatesAutoresizingMaskIntoConstraints = NO;
	NSLayoutGuide *guide = self.view.layoutMarginsGuide;
	[NSLayoutConstraint activateConstraints:@[
		[stackView.topAnchor constraintEqualToAnchor:guide.topAnchor],
		[stackView.bottomAnchor constraintEqualToAnchor:guide.bottomAnchor],
		[stackView.leadingAnchor constraintEqualToAnchor:guide.leadingAnchor],
		[stackView.trailingAnchor constraintEqualToAnchor:guide.trailingAnchor],
		[label.widthAnchor constraintLessThanOrEqualToAnchor:heading.widthAnchor],
	]];
}

- (void)chooseLibrary:(NSButton *)button {
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	openPanel.canChooseFiles = NO;
	openPanel.canChooseDirectories = YES;
	openPanel.prompt = @"Choose";
	openPanel.message = @"Choose a folder to use as your music library.";

	NSArray<NSURL *> *musicDirectoryURLs = [NSFileManager.defaultManager URLsForDirectory:NSMusicDirectory
	                                                                            inDomains:NSUserDomainMask];
	openPanel.directoryURL = musicDirectoryURLs.firstObject;

	[openPanel beginSheetModalForWindow:self.view.window
	                  completionHandler:^(NSModalResponse result) {
		                  if (result == NSModalResponseOK) {
			                  [NSNotificationCenter.defaultCenter
			                          postNotificationName:LibraryURLDidChangeNotificationName
			                                        object:openPanel.URL];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
			                  [target performSelector:action];
#pragma clang diagnostic pop
		                  }
	                  }];
}

@end
