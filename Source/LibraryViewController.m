@implementation LibraryViewController

- (instancetype)init {
	self = [super init];
	[NSNotificationCenter.defaultCenter addObserver:self
	                                       selector:@selector(libraryURLDidChange:)
	                                           name:LibraryURLDidChangeNotificationName
	                                         object:nil];
	return self;
}

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

- (void)libraryURLDidChange:(NSNotification *)notification {
	NSURL *libraryURL = notification.object;
	NSLog(@"%@", libraryURL);
}

@end
