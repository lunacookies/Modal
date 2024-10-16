@implementation MainViewController

- (instancetype)init {
	self = [super init];
	self.title = @"Modal";
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	NSTextField *label = [NSTextField labelWithString:@"Hello, Cocoa!"];
	[self.view addSubview:label];
	label.translatesAutoresizingMaskIntoConstraints = NO;
	NSLayoutGuide *guide = self.view.layoutMarginsGuide;
	[NSLayoutConstraint activateConstraints:@[
		[label.topAnchor constraintEqualToAnchor:guide.topAnchor],
		[label.bottomAnchor constraintEqualToAnchor:guide.bottomAnchor],
		[label.leadingAnchor constraintEqualToAnchor:guide.leadingAnchor],
		[label.trailingAnchor constraintEqualToAnchor:guide.trailingAnchor],
	]];
}

@end
