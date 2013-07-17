//
//  GalleryView.h
//  shadertoy
//
//  Created by Ralph Seaman on 5/8/13.
//
//

#import <UIKit/UIKit.h>

@interface GalleryView : UIView<NSXMLParserDelegate> {
   NSXMLParser *parser;
   NSMutableArray *anchors;
   NSUInteger numAnchors;
   NSUInteger numImages;
   NSUInteger lastId;
   UILabel *statusmsg;
   UITextField *pageNumTextField;
   CGFloat lastx;
   NSMutableArray *buttons;
   CGFloat lasty;
   CGFloat thumbwidth;
   UIView *containerview;
   CGFloat thumbheight;
   NSData *nextPageCache;
   NSData *prevPageCache;
   int colcounter;
   BOOL inAnchor;
   BOOL inImg;
   NSMutableArray *images;
   BOOL galleryFilter;
   NSMutableString *currentStringValue;
}
@property (nonatomic, weak) id delegate;
@property (nonatomic, assign) int pagenum;
-(void) prevPage:(id)sender;
-(void) nextPage:(id)sender;
-(void) loadPage;
-(void) parseData:(NSData*) data;

@end



@protocol GalleryViewDelegate <NSObject>
@optional

-(void) didSelectItem:(NSInteger) item;

@end