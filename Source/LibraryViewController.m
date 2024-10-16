@interface Track : NSObject
@property(nonatomic) NSURL *url;
@property(nonatomic) NSString *title;
@property(nonatomic) NSString *album;
@property(nonatomic) NSData *artworkData;
@end

@implementation Track
@end

@interface LibraryCellView : NSView
@property id objectValue;
@end

const NSUserInterfaceItemIdentifier LibraryCellViewIdentifier = @"org.xoria.Modal.LibraryCellViewIdentifier";

@interface LibraryViewController () <NSTableViewDelegate, NSTableViewDataSource>
@end

@implementation LibraryViewController {
	dispatch_queue_t import_queue;
	NSTableView *tableView;
	NSMutableArray<Track *> *tracks;
}

- (instancetype)init {
	self = [super init];

	import_queue = dispatch_queue_create("org.xoria.Modal.LibraryViewController.ImportQueue", DISPATCH_QUEUE_SERIAL);
	tracks = [[NSMutableArray alloc] init];

	[NSNotificationCenter.defaultCenter addObserver:self
	                                       selector:@selector(libraryURLDidChange:)
	                                           name:LibraryURLDidChangeNotificationName
	                                         object:nil];

	return self;
}

- (void)viewDidLoad {
	tableView = [[NSTableView alloc] init];
	tableView.dataSource = self;
	tableView.delegate = self;

	NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:@"column"];
	[tableView addTableColumn:column];

	NSScrollView *scrollView = [[NSScrollView alloc] init];
	scrollView.documentView = tableView;
	scrollView.hasVerticalScroller = YES;

	scrollView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:scrollView];
	[NSLayoutConstraint activateConstraints:@[
		[scrollView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
		[scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
		[scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
		[scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
	]];
}

- (NSView *)tableView:(NSTableView *)_ viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	LibraryCellView *view = [tableView makeViewWithIdentifier:LibraryCellViewIdentifier owner:nil];
	if (view == nil) {
		view = [[LibraryCellView alloc] init];
	}
	return view;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)_ {
	return (NSInteger)tracks.count;
}

- (id)tableView:(NSTableView *)_ objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	return tracks[(NSUInteger)row];
}

- (void)libraryURLDidChange:(NSNotification *)notification {
	NSURL *libraryURL = notification.object;

	dispatch_async(import_queue, ^{
		NSDirectoryEnumerator<NSURL *> *enumerator =
		        [NSFileManager.defaultManager enumeratorAtURL:libraryURL
		                           includingPropertiesForKeys:@[ NSURLContentTypeKey ]
		                                              options:0
		                                         errorHandler:nil];

		for (NSURL *url in enumerator) {
			UTType *type = nil;
			BOOL ok = [url getResourceValue:&type forKey:NSURLContentTypeKey error:nil];
			if (!ok) {
				continue;
			}

			if (![type conformsToType:UTTypeAudio]) {
				continue;
			}

			Track *track = [[Track alloc] init];
			track.url = url;

			AVAsset *asset = [AVAsset assetWithURL:url];

			track.title = [AVMetadataItem metadataItemsFromArray:asset.commonMetadata
			                                filteredByIdentifier:AVMetadataCommonIdentifierTitle]
			                      .firstObject.stringValue;

			track.album = [AVMetadataItem metadataItemsFromArray:asset.commonMetadata
			                                filteredByIdentifier:AVMetadataCommonIdentifierAlbumName]
			                      .firstObject.stringValue;

			track.artworkData = [AVMetadataItem metadataItemsFromArray:asset.commonMetadata
			                                      filteredByIdentifier:AVMetadataCommonIdentifierArtwork]
			                            .firstObject.dataValue;

			if (track.title == nil || track.album == nil || track.artworkData == nil) {
				continue;
			}

			dispatch_sync(dispatch_get_main_queue(), ^{
				[tracks addObject:track];
				NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:tracks.count - 1];
				[tableView insertRowsAtIndexes:indexSet
				                 withAnimation:NSTableViewAnimationEffectFade | NSTableViewAnimationSlideDown];
			});
		}
	});
}

@end

@implementation LibraryCellView {
	Track *track;
	NSImageView *imageView;
	NSTextField *label;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
	self = [super initWithFrame:frameRect];
	self.identifier = LibraryCellViewIdentifier;

	imageView = [[NSImageView alloc] init];
	imageView.translatesAutoresizingMaskIntoConstraints = NO;
	[self addSubview:imageView];

	label = [NSTextField labelWithString:@""];
	label.translatesAutoresizingMaskIntoConstraints = NO;
	[self addSubview:label];

	[label setContentHuggingPriority:NSLayoutPriorityRequired forOrientation:NSLayoutConstraintOrientationVertical];
	[NSLayoutConstraint activateConstraints:@[
		[imageView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
		[label.centerYAnchor constraintEqualToAnchor:imageView.centerYAnchor],

		[imageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
		[label.leadingAnchor constraintEqualToAnchor:imageView.trailingAnchor constant:8],
		[label.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],

		[imageView.widthAnchor constraintEqualToAnchor:imageView.heightAnchor],
		[imageView.heightAnchor constraintEqualToAnchor:label.heightAnchor],
	]];

	return self;
}

- (id)objectValue {
	return track;
}

- (void)setObjectValue:(id)objectValue {
	track = objectValue;
	label.stringValue = track.title;
	imageView.image = [[NSImage alloc] initWithData:track.artworkData];
}

@end
