@interface TrackCellView : NSView
@property id objectValue;
@end

const NSUserInterfaceItemIdentifier TrackCellViewIdentifier = @"org.xoria.Modal.TrackCellViewIdentifier";

@interface AlbumWindowController () <NSTableViewDelegate, NSTableViewDataSource>
@end

@implementation AlbumWindowController {
	NSTableView *tableView;
	Album *album;
}

+ (instancetype)controllerWithAlbum:(Album *)album {
	AlbumWindowController *result = [[AlbumWindowController alloc] initWithWindowNibName:@""];
	result->album = album;
	return result;
}

- (void)loadWindow {
	self.window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 500, 500)
	                                          styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable |
	                                                    NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable
	                                            backing:NSBackingStoreBuffered
	                                              defer:NO];
	[self.window center];
}

- (void)windowDidLoad {
	tableView = [[NSTableView alloc] init];
	tableView.dataSource = self;
	tableView.delegate = self;

	NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:@"column"];
	[tableView addTableColumn:column];

	NSScrollView *scrollView = [[NSScrollView alloc] init];
	scrollView.documentView = tableView;
	scrollView.hasVerticalScroller = YES;

	NSView *contentView = self.window.contentView;
	scrollView.translatesAutoresizingMaskIntoConstraints = NO;
	[contentView addSubview:scrollView];
	[NSLayoutConstraint activateConstraints:@[
		[scrollView.topAnchor constraintEqualToAnchor:contentView.topAnchor],
		[scrollView.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor],
		[scrollView.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor],
		[scrollView.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor],
	]];
}

- (NSView *)tableView:(NSTableView *)_ viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	TrackCellView *view = [tableView makeViewWithIdentifier:TrackCellViewIdentifier owner:nil];
	if (view == nil) {
		view = [[TrackCellView alloc] init];
	}
	return view;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)_ {
	return (NSInteger)album.tracks.count;
}

- (id)tableView:(NSTableView *)_ objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	return album.tracks[(NSUInteger)row];
}

@end

@implementation TrackCellView {
	Track *track;
	NSTextField *label;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
	self = [super initWithFrame:frameRect];
	self.identifier = TrackCellViewIdentifier;

	label = [NSTextField labelWithString:@""];
	label.translatesAutoresizingMaskIntoConstraints = NO;
	[self addSubview:label];
	[NSLayoutConstraint activateConstraints:@[
		[label.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
		[label.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
		[label.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
	]];

	return self;
}

- (id)objectValue {
	return track;
}

- (void)setObjectValue:(id)objectValue {
	NSAssert([objectValue isKindOfClass:[Track class]], @"TrackCellView objectValue must be Track");
	track = objectValue;
	label.stringValue = track.title;
}

@end
