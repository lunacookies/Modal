@implementation LibraryViewController

- (void)viewDidLoad {
	NSTextField *label = [NSTextField labelWithString:@"library"];
	NSStackView *stackView = [NSStackView stackViewWithViews:@[ label ]];

	stackView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:stackView];
	[NSLayoutConstraint activateConstraints:@[
		[stackView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
		[stackView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
		[stackView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
		[stackView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
	]];
}

@end
