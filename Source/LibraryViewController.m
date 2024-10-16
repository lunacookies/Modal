@interface Track : NSObject
@property(nonatomic) NSURL *url;
@property(nonatomic) NSString *title;
@property(nonatomic) NSString *albumTitle;
@property(nonatomic) NSData *artworkData;
@end

@interface Album : NSObject
@property(nonatomic) NSString *title;
@property(nonatomic) NSMutableArray<Track *> *tracks;
@property(readonly) NSData *artworkData;
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
	NSMutableArray<Album *> *albums;
	NSMutableDictionary<NSString *, NSNumber *> *albumIndexes;
}

- (instancetype)init {
	self = [super init];

	import_queue = dispatch_queue_create("org.xoria.Modal.LibraryViewController.ImportQueue", DISPATCH_QUEUE_SERIAL);
	albums = [[NSMutableArray alloc] init];
	albumIndexes = [[NSMutableDictionary alloc] init];

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
	return (NSInteger)albums.count;
}

- (id)tableView:(NSTableView *)_ objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	return albums[(NSUInteger)row];
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

			track.albumTitle = [AVMetadataItem metadataItemsFromArray:asset.commonMetadata
			                                     filteredByIdentifier:AVMetadataCommonIdentifierAlbumName]
			                           .firstObject.stringValue;

			track.artworkData = [AVMetadataItem metadataItemsFromArray:asset.commonMetadata
			                                      filteredByIdentifier:AVMetadataCommonIdentifierArtwork]
			                            .firstObject.dataValue;

			if (track.title == nil || track.albumTitle == nil || track.artworkData == nil) {
				continue;
			}

			dispatch_sync(dispatch_get_main_queue(), ^{
				NSNumber *albumIndex = albumIndexes[track.albumTitle];
				Album *album = nil;
				if (albumIndex == nil) {
					album = [[Album alloc] init];
					album.title = track.albumTitle;
					album.tracks = [[NSMutableArray alloc] init];
					[album.tracks addObject:track];

					albumIndex = [NSNumber numberWithUnsignedInteger:albums.count];
					[albums addObject:album];
					[albumIndexes setObject:albumIndex forKey:album.title];
					NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:albumIndex.unsignedIntegerValue];
					[tableView insertRowsAtIndexes:indexSet
					                 withAnimation:NSTableViewAnimationEffectFade | NSTableViewAnimationSlideDown];
				} else {
					album = albums[albumIndex.unsignedIntegerValue];
				}
				[album.tracks addObject:track];
			});
		}
	});
}

@end

@implementation LibraryCellView {
	Album *album;
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
	return album;
}

- (void)setObjectValue:(id)objectValue {
	NSAssert([objectValue isKindOfClass:[Album class]], @"LibraryCellView objectValue must be Album");
	album = objectValue;
	label.stringValue = album.title;
	imageView.image = [[NSImage alloc] initWithData:album.artworkData];
}

@end

@implementation Track
@end

@implementation Album

- (NSData *)artworkData {
	return self.tracks[0].artworkData;
}

@end
