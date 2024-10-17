@implementation Track
@end

@implementation Album

- (NSData *)artworkData {
	return self.tracks[0].artworkData;
}

@end
