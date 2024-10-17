@implementation OnboardingWindowController {
	id target;
	SEL action;
}

+ (instancetype)controllerWithTarget:(id)target_ action:(SEL)action_ {
	OnboardingWindowController *result = [[OnboardingWindowController alloc] initWithWindowNibName:@""];
	result->target = target_;
	result->action = action_;
	return result;
}

- (void)loadWindow {
	self.window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 0, 0)
	                                          styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskFullSizeContentView
	                                            backing:NSBackingStoreBuffered
	                                              defer:NO];
	self.window.titlebarAppearsTransparent = YES;
	self.window.movableByWindowBackground = YES;
	self.window.animationBehavior = NSWindowAnimationBehaviorAlertPanel;
	[self.window center];
}

- (void)windowDidLoad {
	NSTextField *heading = [NSTextField labelWithString:@"Choose A Library Folder"];
	heading.font = [NSFont systemFontOfSize:24];

	NSTextField *label = [NSTextField wrappingLabelWithString:
	                @"Before you can use Modal, you must first pick a folder to use as your music library."];
	label.alignment = NSTextAlignmentCenter;
	label.textColor = NSColor.secondaryLabelColor;
	label.selectable = NO;

	NSButton *button = [NSButton buttonWithTitle:@"Choose…" target:self action:@selector(chooseLibrary:)];

	NSStackView *stackView = [[NSStackView alloc] init];
	stackView.orientation = NSUserInterfaceLayoutOrientationVertical;
	stackView.spacing = 24;
	[stackView addView:heading inGravity:NSStackViewGravityCenter];
	[stackView addView:label inGravity:NSStackViewGravityCenter];
	[stackView addView:button inGravity:NSStackViewGravityCenter];

	NSVisualEffectView *effectView = [[NSVisualEffectView alloc] init];
	effectView.material = NSVisualEffectMaterialHUDWindow;
	[effectView addSubview:stackView];
	stackView.translatesAutoresizingMaskIntoConstraints = NO;
	[NSLayoutConstraint activateConstraints:@[
		[stackView.topAnchor constraintEqualToAnchor:effectView.topAnchor constant:36],
		[stackView.bottomAnchor constraintEqualToAnchor:effectView.bottomAnchor constant:-36],
		[stackView.leadingAnchor constraintEqualToAnchor:effectView.leadingAnchor constant:48],
		[stackView.trailingAnchor constraintEqualToAnchor:effectView.trailingAnchor constant:-48],
		[label.widthAnchor constraintLessThanOrEqualToAnchor:heading.widthAnchor],
	]];

	NSView *contentView = self.window.contentView;
	[contentView addSubview:effectView];
	effectView.translatesAutoresizingMaskIntoConstraints = NO;
	[NSLayoutConstraint activateConstraints:@[
		[effectView.topAnchor constraintEqualToAnchor:contentView.topAnchor],
		[effectView.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor],
		[effectView.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor],
		[effectView.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor],
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

	[openPanel beginSheetModalForWindow:self.window
	                  completionHandler:^(NSModalResponse result) {
		                  if (result == NSModalResponseOK) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
			                  [target performSelector:action];
#pragma clang diagnostic pop
			                  [NSNotificationCenter.defaultCenter
			                          postNotificationName:LibraryURLDidChangeNotificationName
			                                        object:openPanel.URL];
			                  [self close];
		                  }
	                  }];
}

@end
