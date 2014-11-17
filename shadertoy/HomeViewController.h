//
//  HomeViewController.h
//  shadertoy
//
//  Created by ydf on 13-2-3.
//
//

#import <UIKit/UIKit.h>
#import "SimpleOpenGLView.h"
#import "GalleryView.h"

@interface HomeViewController : UIViewController
{
   UITextView *sourceview;
   SimpleOpenGLView *simpleGLView;
}
@property (weak, nonatomic) IBOutlet UIView *navbar;
- (IBAction)toggleGallery:(id)sender;
- (IBAction)doPrevious:(id)sender;
- (IBAction)doNext:(id)sender;
@property (weak, nonatomic) IBOutlet GalleryView *gallery;
@property (weak, nonatomic) IBOutlet UIView *mGLContainerView;
@property (weak, nonatomic) IBOutlet UISlider *mySlider;
@property (weak, nonatomic) IBOutlet UITextField *statusmessage;
@property (weak, nonatomic) IBOutlet UITextView *sourceTextView;
@property (weak, nonatomic) IBOutlet UIButton *srcButton;
- (IBAction)toggleSrc:(id)sender;
- (IBAction)doFinishSliderChange:(id)sender;
 
- (IBAction)doSliderChange:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *mGLContainerView2;
@property (weak, nonatomic) IBOutlet UITextField *mTitle;
- (IBAction)doCompile:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *doRun;
- (IBAction)runShader:(id)sender;
- (IBAction)stopShader:(id)sender;

-(void) didSelectItem:(NSInteger ) item;
-(void) setSliderRange:(NSInteger) max;


@end
