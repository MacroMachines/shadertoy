//
//  HomeViewController.m
//  shadertoy
//
//  Created by ydf on 13-2-3.
//
//

#import "HomeViewController.h"
#import "SimpleOpenGLView.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

typedef void (^ReqHandler) (NSURLResponse *response, NSData *data, NSError *connectionError);

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
      //  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        
     //   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        
    }
    return self;
}


-(void) keyboardWillShow:(NSNotification*) notification
{
    self.sourceTextView.frame = CGRectMake(20, 60, 986, 220);
}


-(void) keyboardWillHide:(NSNotification*) notification
{
    self.sourceTextView.frame = CGRectMake(20, 60, 986, 688);
}



- (void)getShader:(NSInteger)item {
    //self.mTitle.text = [NSString stringWithFormat:@"%d" ,(int)self.mySlider.value ];
    //int itemID = (int)self.mySlider.value;
    NSString *path = [NSString stringWithFormat:@"http://glslsandbox.com/item/%d", (int)item ];
    [self toggleGallery:self];
    //ex: http://glsl.heroku.com/item/18868.3
    /*
     {"code":"// Kyle Mac, bitches\n\n#ifdef GL_ES\nprecision mediump float;\n#endif\n\n#define E 2.71828182846\n\nuniform float time;\nuniform vec2 resolution;\n\nvoid main() {\n\tvec2 pos = ( gl_FragCoord.xy / resolution.xy ) + 0.75;\n\tif (pos.y < 0.9 || pos.y > 1.1) {\n\t\tgl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);\n\t\treturn;\n\t}\n\t\n\tfloat r = pow(E, -0.5 * pow((pos.y-1.0) / 0.025, 2.0)) * (cos(time*4.0+pos.x)/4.0+0.25);\n\tfloat g = pow(E, -0.75 * pow((pos.y-1.0) / 0.0075, 2.0)) * (sin(time*2.0+pos.x*4.0)/2.0+1.0);\n\tfloat b = pow(E, -0.25 * pow((pos.y-1.0) / 0.015, 2.0)) * (sin(time*1.5*4.0)/4.0+1.5);\n\t\n\tgl_FragColor = vec4(r, g, b, 1.0);\n}","user":"ae92dc6","parent":null}
     */
    void (^jsonblock) (NSURLResponse *response, NSData *data, NSError *connectionError) = ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if( data ){
            @try {
                dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error=nil;
                __block NSDictionary *dataSet=nil;
                dataSet = [NSJSONSerialization JSONObjectWithData:data
                                                          options:NSJSONReadingMutableLeaves error:&error];
                NSLog(@"%@" ,dataSet);
                NSString *fsh =  dataSet[@"code"];
                NSLog(@"%@" ,fsh);
                    self.sourceTextView.text = dataSet[@"code"];
                });
            }
            @catch(NSException *ex){
                NSLog(@"exception: %@",ex.debugDescription);
            }
            @finally {
               
            }
            NSLog(@"this is : %d" ,(int)self.mySlider.value);
        }
        
    };
    
    NSURL *url = [NSURL URLWithString:path];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler: jsonblock ];
}

/// gallery delegate
-(void) didSelectItem:(NSInteger ) item {
    
    self.mTitle.text = [NSString stringWithFormat:@"%ld" ,item];
    [self.mySlider setValue:(float)item];
    [self getShader:item];
    
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
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mTitle resignFirstResponder];
        int itemID = self.mTitle.text.intValue;
        self.mySlider.value = itemID -1;
        self.mTitle.text = [NSString stringWithFormat:@"%d" ,(int)self.mySlider.value ];
        [self getShader:itemID];
    });
}

- (IBAction)doNext:(id)sender {
    
    [self.mTitle resignFirstResponder];
    
    int itemID = self.mTitle.text.intValue;
    
    self.mySlider.value = itemID +1;
    
    self.mTitle.text = [NSString stringWithFormat:@"%d" ,(int)self.mySlider.value ];
    //int itemID = (int)self.mySlider.value;
    [self getShader:itemID];
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
    dispatch_async(dispatch_get_main_queue(), ^{
    if(self.sourceTextView.hidden == YES){
        self.srcButton.titleLabel.text = @"hide src";
        self.sourceTextView.hidden = NO;
    } else {
        self.srcButton.titleLabel.text = @"show src";
        self.sourceTextView.hidden = YES;
    }
    });
}

- (IBAction)doFinishSliderChange:(id)sender {
    int itemID = self.mTitle.text.intValue;
    [self getShader:itemID];
}

- (IBAction)doSliderChange:(id)sender {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mTitle.text = [NSString stringWithFormat:@"%d" ,(int)self.mySlider.value ];
    });
    
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

-(void) setSliderRange:(NSInteger) max
{
    self.mySlider.maximumValue = max;
}

-(void) dealloc {
 [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
