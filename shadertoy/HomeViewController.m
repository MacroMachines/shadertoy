//
//  HomeViewController.m
//  shadertoy
//
//  Created by ydf on 13-2-3.
//
//

#import "HomeViewController.h"
#import "ViewController.h"
#import "SimpleOpenGLView.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

   /// gallery delegate
-(void) didSelectItem:(NSInteger ) item{

   self.mTitle.text = [NSString stringWithFormat:@"%d" ,item];
   [self.mySlider setValue:(float)item];
      //self.mTitle.text = [NSString stringWithFormat:@"%d" ,(int)self.mySlider.value ];
      //int itemID = (int)self.mySlider.value;
   NSString *path = [NSString stringWithFormat:@"%@%d" , GLSL_FRAGMENT_JSON, item ];
   [self toggleGallery:self];

   [ApplicationDelegate.netDataPost postGetDataWithRequestData: path  usingBlockObject:^(NSDictionary *dataSet) {
      NSLog(@"%@" ,dataSet);
      NSString *fsh =  dataSet[@"code"];
      NSLog(@"%@" ,fsh);
      NSLog(@"this is : %d" ,(int)self.mySlider.value);
      self.sourceTextView.text = fsh;
   }];


}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mTitle.text =@"1";
   sourceview = [[UITextView alloc]initWithFrame:CGRectInset(self.view.bounds, 40., 40.)];
   self.gallery.delegate = self;
      //sourceview.text = @"hi there";
   self.sourceTextView.text = @"";
   self.sourceTextView.backgroundColor = [UIColor darkGrayColor];
   self.sourceTextView.textColor = [UIColor whiteColor];
      //[self.view addSubview: sourceview];
   self.navbar.layer.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8].CGColor;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)shader1:(id)sender {
    
    ViewController *v  = [[ViewController alloc] init];
    
    [self.navigationController pushViewController:v animated:YES];
    
}
- (IBAction)shader2:(id)sender {
    
    ViewController *v  = [[ViewController alloc] init];
    
    [self.navigationController pushViewController:v animated:YES];
    
}
- (IBAction)shader3:(id)sender {
}
- (IBAction)stopShader:(id)sender {

   [simpleGLView stopDisplayLink];
   [simpleGLView removeFromSuperview];
      //self.sourceTextView.text = @" void main() { gl_FragColor= vec4(0.0); } ";
      //[self runShader:self];


}


- (IBAction)toggleGallery:(id)sender {
   if(self.gallery.hidden == YES){
      self.gallery.hidden = NO;

   } else {
      self.gallery.hidden = YES;
   }
}

- (IBAction)doPrevious:(id)sender {
   [self.mTitle resignFirstResponder];


   int itemID = self.mTitle.text.intValue;

   self.mySlider.value = itemID -1;

   self.mTitle.text = [NSString stringWithFormat:@"%d" ,(int)self.mySlider.value ];
      //int itemID = (int)self.mySlider.value;
   NSString *path = [NSString stringWithFormat:@"%@%d" , GLSL_FRAGMENT_JSON, itemID ];

   [ApplicationDelegate.netDataPost postGetDataWithRequestData: path  usingBlockObject:^(NSDictionary *dataSet) {
      NSLog(@"%@" ,dataSet);
      NSString *fsh =  dataSet[@"code"];
      NSLog(@"%@" ,fsh);
      NSLog(@"this is : %d" ,(int)self.mySlider.value);
      self.sourceTextView.text = fsh;
   }];

}

- (IBAction)doNext:(id)sender {
    
    [self.mTitle resignFirstResponder];
    
    int itemID = self.mTitle.text.intValue;
     
    self.mySlider.value = itemID +1;
    
    self.mTitle.text = [NSString stringWithFormat:@"%d" ,(int)self.mySlider.value ];
    //int itemID = (int)self.mySlider.value;
    NSString *path = [NSString stringWithFormat:@"%@%d" , GLSL_FRAGMENT_JSON, itemID ];
    
    [ApplicationDelegate.netDataPost postGetDataWithRequestData: path  usingBlockObject:^(NSDictionary *dataSet) {
        NSLog(@"%@" ,dataSet);
        NSString *fsh =  dataSet[@"code"]  ;
        NSLog(@"%@" ,fsh);
        NSLog(@"this is : %d" ,(int)self.mySlider.value);
       self.sourceTextView.text = fsh;
    }];

}



- (void)viewDidUnload {
    [self setMGLContainerView:nil];
    [self setMySlider:nil];
    [self setMTitle:nil];
    [self setMGLContainerView2:nil];
    [self setMTitle:nil];
   [self setDoRun:nil];
   [self setStatusmessage:nil];
   [self setSourceTextView:nil];
    [self setGallery:nil];
   [self setNavbar:nil];
   [self setSrcButton:nil];
    [super viewDidUnload];
}
- (IBAction)toggleSrc:(id)sender {
   if(self.sourceTextView.hidden == YES){
      self.srcButton.titleLabel.text = @"hide src";
      self.sourceTextView.hidden = NO;
   } else {
      self.srcButton.titleLabel.text = @"show src";
      self.sourceTextView.hidden = YES;
   }
}

- (IBAction)doFinishSliderChange:(id)sender {
   int itemID = self.mTitle.text.intValue;

      //int itemID = (int)self.mySlider.value;
   NSString *path = [NSString stringWithFormat:@"%@%d" , GLSL_FRAGMENT_JSON, itemID ];

   [ApplicationDelegate.netDataPost postGetDataWithRequestData: path  usingBlockObject:^(NSDictionary *dataSet) {
      NSLog(@"%@" ,dataSet);
      NSString *fsh =  dataSet[@"code"]  ;
      NSLog(@"%@" ,fsh);
      NSLog(@"this is : %d" ,(int)self.mySlider.value);
      self.sourceTextView.text = fsh;
   }];


}

- (IBAction)doSliderChange:(id)sender {
    
    self.mTitle.text = [NSString stringWithFormat:@"%d" ,(int)self.mySlider.value ];
 
}
- (IBAction)doCompile:(id)sender {
}
- (IBAction)runShader:(id)sender {
   if(simpleGLView!=nil)
      {
      [simpleGLView removeFromSuperview];
      simpleGLView =nil;
      }
   CGRect screenBounds  = self.mGLContainerView.bounds;
   simpleGLView  =  [SimpleOpenGLView alloc]  ;
      //simpleGLView.shaderF = self.sourceTextView.text;
   simpleGLView = [simpleGLView initWithFrame:screenBounds andShaderString:self.sourceTextView.text];
   [self.mGLContainerView addSubview:simpleGLView];
   [self.mGLContainerView bringSubviewToFront:simpleGLView];

}
@end
