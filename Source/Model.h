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
