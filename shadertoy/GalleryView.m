//
//  GalleryView.m
//  shadertoy
//
//  Created by Ralph Seaman on 5/8/13.
//
//

#import "GalleryView.h"

@interface GalleryView()
-(void) savePageNum:(NSInteger) pageNum;
@end

@implementation GalleryView
@synthesize pagenum=_pagenum;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
       self.backgroundColor = [UIColor darkGrayColor];
        // Initialization code
       [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   if (self) {
      [self setup];
   }
   return self;
}

-(void) setup {

   containerview = [[UIScrollView alloc]initWithFrame:self.bounds];
   containerview.backgroundColor = [UIColor clearColor];
   [self addSubview:containerview];

   CGFloat scalefactor = .7;
   thumbheight = 100 * scalefactor;
   thumbwidth = 200 * scalefactor;
   self.backgroundColor = [UIColor darkGrayColor];

   NSInteger pn = [[NSUserDefaults standardUserDefaults] integerForKey:@"pagenum"];
   NSLog(@"%s pagenum = %d",__PRETTY_FUNCTION__,pn);
   self.pagenum = pn;

   galleryFilter = NO;
   inAnchor = NO;
   inImg = NO;

   lastx = 0.0f;
   lasty = 60.0f;
   colcounter = 0;
   buttons = [NSMutableArray array];

   [self addPager];
   statusmsg = [[UILabel alloc]initWithFrame:CGRectMake(0.,0.,300.,30.)];
   statusmsg.text = @"hello";
   statusmsg.textColor = [UIColor greenColor];
   statusmsg.backgroundColor = [UIColor clearColor];
   [self addSubview:statusmsg];
   [self loadPage];

}

-(void) prevPages:(id)sender {
   NSInteger ptmp = pageNumTextField.text.integerValue;
   _pagenum = ptmp;
   _pagenum--;
   pageNumTextField.text = [NSString stringWithFormat:@"%d",_pagenum];
   [self loadPage];
}
-(void) nextPages:(id)sender {
   NSInteger ptmp = pageNumTextField.text.integerValue;
   _pagenum = ptmp;
   _pagenum++;
   pageNumTextField.text = [NSString stringWithFormat:@"%d",_pagenum];
   [self loadPage];
}


-(void) prevPage:(id)sender {
   NSInteger ptmp = pageNumTextField.text.integerValue;
   _pagenum = ptmp;
   _pagenum--;
   pageNumTextField.text = [NSString stringWithFormat:@"%d",_pagenum];
   [self loadPage];
}
-(void) nextPage:(id)sender {
   NSInteger ptmp = pageNumTextField.text.integerValue;
   _pagenum = ptmp;
   _pagenum++;
   pageNumTextField.text = [NSString stringWithFormat:@"%d",_pagenum];
   [self loadPage];
}

-(void) parseData:(NSData*) data {
   parser = [[NSXMLParser alloc] initWithData:data];
   [parser setDelegate:self];
   [parser parse];

}



-(void) addPager {
   CGFloat buttonwidth = 80.0;
   CGFloat buttonheight = 40.0;
   UIButton *nextbutton = [UIButton buttonWithType:UIButtonTypeCustom];
   nextbutton.tag = 0;
   nextbutton.frame = CGRectMake(self.bounds.size.width-buttonwidth,0,buttonwidth,buttonheight);
   [nextbutton setBackgroundImage:[UIImage imageNamed:@"blankbutton"] forState:UIControlStateNormal];
   [nextbutton setImage:[UIImage imageNamed:@"goForwardItem"] forState:UIControlStateNormal];
   nextbutton.contentMode = UIViewContentModeScaleAspectFill;
   nextbutton.titleLabel.text = @"next";
   nextbutton.enabled = YES;
   [self addSubview:nextbutton];
   [nextbutton addTarget:self action:@selector(nextPage:) forControlEvents:UIControlEventTouchUpInside];
   [nextbutton addTarget:self action:@selector(nextPages:) forControlEvents:UIControlEventTouchDownRepeat];

      // assume 10 is ok
   CGFloat tfwidth = 40.0;
   CGFloat spacer = 2.0;
   pageNumTextField = [[UITextField alloc]initWithFrame:CGRectMake(nextbutton.frame.origin.x-tfwidth-spacer,7,tfwidth,buttonheight)];

   pageNumTextField.enabled = YES;
   pageNumTextField.textAlignment = NSTextAlignmentCenter;
   pageNumTextField.text = [NSString stringWithFormat:@"%d",_pagenum];
   pageNumTextField.textColor = [UIColor greenColor];
   [self addSubview:pageNumTextField];


   UIButton *prevbutton = [UIButton buttonWithType:UIButtonTypeCustom];
   prevbutton.frame = CGRectMake(pageNumTextField.frame.origin.x - spacer-buttonwidth,0,buttonwidth,buttonheight);
   [prevbutton setBackgroundImage:[UIImage imageNamed:@"blankbutton"] forState:UIControlStateNormal];
   [prevbutton setImage:[UIImage imageNamed:@"goBackItem"] forState:UIControlStateNormal];
   prevbutton.titleLabel.text = @"prev";
   prevbutton.enabled = YES;
   prevbutton.tag = 0;
   [self addSubview:prevbutton];
   [prevbutton addTarget:self action:@selector(prevPage:) forControlEvents:UIControlEventTouchUpInside];
   [prevbutton addTarget:self action:@selector(prevPages:) forControlEvents:UIControlEventTouchDownRepeat];
   prevbutton.contentMode = UIViewContentModeScaleAspectFill;

}

-(void) scrollPage:(id)sender {

}

- (void) retrievePage {

   BOOL success;

   NSURL *xmlURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://glsl.heroku.com/?page=%d",self.pagenum]];

         parser = [[NSXMLParser alloc] initWithContentsOfURL:xmlURL];
      //parser = [NSXMLParser alloc] initWithData:[NSData dataWithContentsOfURL:xmlURL];

   [parser setDelegate:self];

   [parser setShouldResolveExternalEntities:NO];

   success = [parser parse]; // return value not used

      // if not successful, delegate is informed of error
   
}

-(void) savePageNum:(NSInteger) pageNum {
   [[NSUserDefaults standardUserDefaults] setInteger:_pagenum forKey:@"pagenum"];
}

-(void) loadPage {

   [self savePageNum:self.pagenum];

   statusmsg.text = @"Loading...";
   colcounter = 0;
   anchors = nil;
   images = nil;
   anchors = [NSMutableArray array];
   images = [NSMutableArray array];
   numImages = 0;
   numAnchors = 0;
   lastx = 0.0f;
   lasty = 60.0f;

   for(UIView *view in containerview.subviews){
      if ([view isKindOfClass:[UIButton class]]){
         if(view.tag > 10){
         [view removeFromSuperview];
         }
      }
   }



   NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://glsl.heroku.com/?page=%d",self.pagenum]];
   NSMutableURLRequest *request = [NSMutableURLRequest  requestWithURL:url];
   [NSURLConnection sendAsynchronousRequest:request
                                      queue:[NSOperationQueue mainQueue]
                          completionHandler:^(NSURLResponse *_response, NSData *_responseData, NSError *_error) {

           NSString *responsetext = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];

                             @try {

           NSString *gallery = [responsetext substringFromIndex:[responsetext rangeOfString:@"<div id=\"gallery\">"].location];

                             gallery = [gallery substringToIndex:[gallery rangeOfString:@"</div>"].location+6];

        NSString *newString = [gallery stringByReplacingOccurrencesOfString:@"</a>" withString:@"</img></a>"];
                             NSData* data = [newString dataUsingEncoding:NSUTF8StringEncoding];
                             [self parseData:data];

                             }
                             @catch (NSException *exception) {
                                   NSLog(@"%s %@",__PRETTY_FUNCTION__,exception.debugDescription);
                             }
                             @finally {
                             }

                          }];

}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {


   if ( [[elementName lowercaseString] isEqualToString:@"a"]) {
      numAnchors++;
           NSString *href = [attributeDict objectForKey:@"href"];
      [anchors addObject:href];
      NSString *cleanone = [href substringFromIndex:[href rangeOfString:@"#"].location+1];
      lastId = cleanone.integerValue;
      inAnchor = YES;
   }

   if ( [[elementName lowercaseString] isEqualToString:@"img"]) {
      NSString *src = [attributeDict objectForKey:@"src"];
      [self createImage:src];
      inImg = YES;
   }

}

-(void) createImage:(NSString*) src {
   NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:src]];
   UIImage *img = [UIImage imageWithData:data];
      //UIImageView *animage = [[UIImageView alloc]initWithImage:[UIImage imageWithData:data]];
      //[self addSubview:animage];
   lastx = lastx + thumbwidth;
   colcounter++;
   int cols = (int) self.bounds.size.width/thumbwidth;
      // int rows = (int) self.bounds.size.height/thumbheight;
   if(colcounter % cols == 0){
      lastx = 0.0;
      lasty += thumbheight;
   }


      // this is a galleyr image button
   UIButton *defaultbutton = [UIButton buttonWithType:UIButtonTypeCustom];
   [defaultbutton setImage:img forState:UIControlStateNormal];
   defaultbutton.frame = CGRectMake(lastx,lasty , thumbwidth, thumbheight);
   defaultbutton.tag = lastId;  // appears right but async could fuck it up
   defaultbutton.enabled = YES;
   [defaultbutton addTarget:self action:@selector(handleOk:) forControlEvents:UIControlEventTouchUpInside];
   [containerview addSubview:defaultbutton];
   [buttons addObject:defaultbutton];

}

-(void) drawImages:(int) startNum {
   colcounter = 0.0;
   lastx = lasty = 0.0;

   int pagelimit = 200;
   for(int i=startNum;i<pagelimit;i++){

      lastx = lastx + thumbwidth;
      colcounter++;
      int cols = (int) self.bounds.size.width/thumbwidth;
         //int rows = (int) self.bounds.size.height/thumbheight;
      if(colcounter % cols == 0){
         lastx = 0.0;
         lasty += thumbheight;
      }
      UIButton *defaultbutton = [buttons objectAtIndex:i];
      defaultbutton.frame = CGRectMake(lastx,lasty , thumbwidth, thumbheight);
      defaultbutton.enabled = YES;
      [defaultbutton addTarget:self action:@selector(handleOk:) forControlEvents:UIControlEventTouchUpInside];
      [containerview addSubview:defaultbutton];

   }
}

- (void)handleOk:(UIButton*)sender {
   if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectItem:)]) {
      [self.delegate didSelectItem:sender.tag];
   } //didSelectItem:
   

}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {

   if (!currentStringValue) {
         // currentStringValue is an NSMutableString instance variable
      currentStringValue = [[NSMutableString alloc] init];
   }

   [currentStringValue appendString:string];
   
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {

      // ignore root and empty elements
   if ( [[elementName lowercaseString] isEqualToString:@"a"]) {
      inAnchor = NO;
   }

   if ( [[elementName lowercaseString] isEqualToString:@"img"]) {
      inImg = NO;
   }

   if ( [[elementName lowercaseString] isEqualToString:@"div"]) {
         // we are done

   statusmsg.text = @"done. ";


      inImg = NO;
   }


   currentStringValue = nil;
      return;

}


-(void) createAllImages {
   CGFloat foo=0.0;
   int bar = 0;
   for(NSString *str in images){
      if(bar == 0){
         bar = 1;
      }
      foo += 100.0;

     //NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
      NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:str]];
         //UIImage *img = [UIImage imageWithData:data];
      UIImageView *animage = [[UIImageView alloc]initWithImage:[UIImage imageWithData:data]];
      animage.center = CGPointMake(0,foo);
      [containerview addSubview:animage];


   }


}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

/*
-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
   _pagenum++;
   [self loadPage];
}
 */

@end
