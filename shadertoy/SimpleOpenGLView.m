   //  SimpleOpenGLView.m

/*

 usage
 simpleGLView  =  [SimpleOpenGLView alloc]  ;
 simpleGLView = [simpleGLView initWithFrame:_containerView.bounds andShader:@"simple1"]; // assumes such a file exists...
 CGAffineTransform verticalFlip = CGAffineTransformMakeScale(1,-1);
 simpleGLView.transform = verticalFlip;
 _containerView.opaque=  NO;
 _containerView.backgroundColor = [UIColor clearColor];
 [self.view addSubview:simpleGLView];


 */

#import "SimpleOpenGLView.h"
#import <Accelerate/Accelerate.h>

@interface SimpleOpenGLView()
- (const GLchar *)readFile:(NSString *)name;
- (void) setMouseFromTouches:(NSSet*)touches;
@end

@implementation SimpleOpenGLView

@synthesize startTime = startTime;

typedef struct {
   float Position[3];
   float Color[4];
   float TexCoord[2]; // New

} Vertex;

#define TEX_COORD_MAX   1

static const GLfloat squareVertices[] = {
   -1.0f, -1.0f,
   1.0f, -1.0f,
   -1.0f,  1.0f,
   1.0f,  1.0f
};

static const GLfloat texCoords[] = {
   0.0, 1.0,
   1.0, 1.0,
   0.0, 0.0,
   1.0, 0.0
};


const Vertex Vertices[] = {
      // Front
   {{1, -1, 0}, {1, 0, 0, 1}, {TEX_COORD_MAX, 0}},
   {{1, 1, 0}, {0, 1, 0, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
   {{-1, 1, 0}, {0, 0, 1, 1}, {0, TEX_COORD_MAX}},
   {{-1, -1, 0}, {0, 0, 0, 1}, {0, 0}}};


const GLubyte Indices[] = {
   0, 1, 2,
   2, 3, 0
};



- (id)initWithFrame:(CGRect)frame andShader:(NSString*)shaderName {
   self = [super initWithFrame:frame];
   if (self) {
      self.fragmentShaderFilename = shaderName;
      useDisplayLink = YES;
      shaderFromString = NO;
      [self loadShaders];
   }
   return self;
}

- (id)initWithFrame:(CGRect)frame andShaderString:(NSString*)shader {
   self = [super initWithFrame:frame];
   if (self) {
      self.shaderF = shader;
      shaderFromString = YES;
      useDisplayLink = YES;
      [self loadShaders];
   }
   return self;
}

- (id)initWithFrame:(CGRect)frame andShader:(NSString*)shaderName andMovie:(NSString*) moviename{
   self = [super initWithFrame:frame];
   if (self) {
      useDisplayLink = NO;
      NSLog(@"%s",__PRETTY_FUNCTION__);
      self.fragmentShaderFilename = shaderName;
      self.movieFileName = moviename;
      shaderFromString = NO;
      [self loadShaders];
   }
   return self;

}
- (id)initWithFrame:(CGRect)frame andShader:(NSString*)shaderName useDisplayLink:(BOOL) shouldUseDisplayLink{
   self = [super initWithFrame:frame];
   if (self) {
      useDisplayLink = shouldUseDisplayLink;
      self.fragmentShaderFilename = shaderName;
      [self loadShaders];
      shaderFromString = NO;
   }
   return self;

}



-(void) loadShaders {

   self.uniformOverride = -100.0;
   self.backgroundColor =[UIColor clearColor];
   self.opaque = NO;
   self.transform = CGAffineTransformMakeScale(1,-1);
   self.userInteractionEnabled = YES;




   [self initFirst] ;
   [self setupLayer];
   [self setupContext];
   [self setupRenderBuffer];
   [self setupFrameBuffer];
   [self compileShaders];
   [self setupVBOs];

   if(useDisplayLink==YES){
      [self setupDisplayLink];
   }

   if(self.movieFileName!=nil){
      [self playvid];
   }
}

- (void)bindFirstTexture {
   glActiveTexture(GL_TEXTURE0);
      //glBindTexture(GL_TEXTURE_1D, firstTextureID);
}
- (void)bindSecondTexture {
   glActiveTexture(GL_TEXTURE1);
      //glBindTexture(GL_TEXTURE_2D, secondTextureID);
}

/*
 - (id)initWithFrame:(CGRect)frame
 {
 self = [super initWithFrame:frame];
 if (self) {
 [self initFirst] ;
 [self setupLayer];
 [self setupContext];
 [self setupRenderBuffer];
 [self setupFrameBuffer];
 [self compileShaders];
 [self setupVBOs];
 [self setupDisplayLink];
 }
 return self;
 }
 */


+ (Class)layerClass {
   return [CAEAGLLayer class];
}
- (void)setupLayer {
   _eaglLayer = (CAEAGLLayer*) self.layer;
   _eaglLayer.opaque = NO;
   _eaglLayer.backgroundColor = [UIColor clearColor].CGColor;

}
-(void) initFirst {

   self.startTime =[NSDate date];
   screenX = self.frame.size.width;
   screenY = self.frame.size.height;
   self.vertexShaderFilename =@"simple1";

   self.shaderV  = [self loadFile : self.vertexShaderFilename fileExt:@"vsh"];
   displayLink = nil;

   if(shaderFromString){
         // shader string passed in init

   } else {
   if(self.shaderF ==nil || self.shaderF.length <1)
      self.shaderF  = [self loadFile : self.fragmentShaderFilename fileExt:@"fsh"];
   }

}


- (void)setupContext {
   EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
   _context = [[EAGLContext alloc] initWithAPI:api];
   if (!_context) {
      NSLog(@"Failed to initialize OpenGLES 2.0 context");
      exit(1);
   }

   if (![EAGLContext setCurrentContext:_context]) {
      NSLog(@"Failed to set current OpenGL context");
      exit(1);
   }
}
- (void)setupRenderBuffer {
   glGenRenderbuffers(1, &_colorRenderBuffer);
   glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
   [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}
- (void)setupFrameBuffer {
   glGenFramebuffers(1, &framebuffer);
   glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
   glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                             GL_RENDERBUFFER, _colorRenderBuffer);
}


- (void)drawFrame
{


   glClearColor(0.0f, 0.0f, 0.0f, 0.0f );
   glClear(GL_COLOR_BUFFER_BIT);

      // 1
   glViewport(0, 0, self.frame.size.width, self.frame.size.height);

      // 2
   glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE,
                         sizeof(Vertex), 0);
   glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE,
                         sizeof(Vertex), (GLvoid*) (sizeof(float) *3));
   glVertexAttribPointer(_texCoordSlot, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) * 7));

   ftime = -[self.startTime timeIntervalSinceNow];

   if(_uniformOverride > 0 ) {
      ftime = self.uniformOverride;
   }

   glUniform1f(_time, ftime );
   glUniform2f(_mouse, mouseX ,mouseY);
   glUniform2f(_resolution, screenX  ,screenY);


      /// video stff
   glActiveTexture(GL_TEXTURE0);
   glUniform1i(textureUniformLocation, 0); // set texture
   //glUniform1i(textureUniformLocation, 0 + 1); // if two textures will have be this
                                           //glActiveTexture(GL_TEXTURE1); // and activate other texture slots

      /// end video stuff


   glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]),
                  GL_UNSIGNED_BYTE, 0);

   [_context presentRenderbuffer:GL_RENDERBUFFER];

}


- (void)render :(CADisplayLink*)displayLink {

   glClearColor(0.0f, 0.0f, 0.0f, 0.0f );

      // viewport setup
   glViewport(0, 0, self.frame.size.width, self.frame.size.height);

      /// attributes to pass to shader
   glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
   glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) *3));

   ftime = -[self.startTime timeIntervalSinceNow];
   glUniform1f(_time, ftime );
   glUniform2f(_mouse, mouseX ,mouseY);
   glUniform2f(_resolution, screenX  ,screenY);

      // 3
   glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]),
                  GL_UNSIGNED_BYTE, 0);


   [_context presentRenderbuffer:GL_RENDERBUFFER];


      //NSLog(@"ftime: %f", ftime);


}
- (void)setupDisplayLink {
   NSLog(@"%s",__PRETTY_FUNCTION__);
   if(displayLink == nil){
      displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
      displayLink.frameInterval = 1;
      [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
   }
}

-(void) stopDisplayLink {
   [displayLink invalidate];
   displayLink = nil;
}
- (void)dealloc
{
   [self destroyFramebuffer];
   _context = nil;
   self.shaderF =nil;
   self.shaderV =nil;
   if (programHandle) {
      glDeleteProgram(programHandle);
      programHandle = 0;
   }
   _eaglLayer = nil;
}


-(BOOL) canCompileShader:(NSString*)shaderString withType:(GLenum)shaderType  {
      // 2
   GLuint shaderHandle = glCreateShader(shaderType);

      // 3
   const char* shaderStringUTF8 = [shaderString UTF8String];
   int shaderStringLength = [shaderString length];
   glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);

      // 4
   glCompileShader(shaderHandle);

      // 5
   GLint compileSuccess;
   glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
   if (compileSuccess == GL_FALSE) {
      return NO;
   }else{
      return YES;
   }
   return NO;
}


- (GLuint)compileShader:(NSString*)shaderString withType:(GLenum)shaderType  {

      // 2
   GLuint shaderHandle = glCreateShader(shaderType);

      // 3
   const char* shaderStringUTF8 = [shaderString UTF8String];
   int shaderStringLength = [shaderString length];
   glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);

      // 4
   glCompileShader(shaderHandle);

      // 5
   GLint compileSuccess;
   glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
   if (compileSuccess == GL_FALSE) {
      GLchar messages[256];
      glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
      NSString *messageString = [NSString stringWithUTF8String:messages];
      NSLog(@"%@", messageString);
      return -1;
         // exit(1);
   }

   return shaderHandle;

}
- (void)compileShaders {

      // 1
   GLuint vertexShader = [self compileShader:self.shaderV      withType:GL_VERTEX_SHADER]  ;
   GLuint fragmentShader;
   if(![self canCompileShader:self.shaderF withType:GL_FRAGMENT_SHADER]){
      NSLog(@"%s shader does not compile",__PRETTY_FUNCTION__);
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                      message:@"shader does not compile"
                                                     delegate:nil
                                            cancelButtonTitle:@"ok"
                                            otherButtonTitles:nil];
      [alert show];
      return;

   }
   fragmentShader = [self compileShader:self.shaderF     withType:GL_FRAGMENT_SHADER ];


      // 2
   programHandle = glCreateProgram();
   glAttachShader(programHandle, vertexShader);
   glAttachShader(programHandle, fragmentShader);
   glLinkProgram(programHandle);

      // 3
   GLint linkSuccess;
   glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
   if (linkSuccess == GL_FALSE) {
      GLchar messages[256];
      glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
      NSString *messageString = [NSString stringWithUTF8String:messages];
      NSLog(@"%@", messageString);
      exit(1);
   }

      // 4
   glUseProgram(programHandle);

      // 5
   _positionSlot = glGetAttribLocation(programHandle, "Position");
   _colorSlot = glGetAttribLocation(programHandle, "SourceColor");
   _texCoordSlot = glGetAttribLocation(programHandle, "inputTextureCoordinate");

   _time = glGetUniformLocation(programHandle, "time");
   _mouse = glGetUniformLocation(programHandle, "mouse");
   _resolution = glGetUniformLocation(programHandle, "resolution");


   glEnableVertexAttribArray(_positionSlot);
   glEnableVertexAttribArray(_colorSlot);
   glEnableVertexAttribArray(_texCoordSlot);
      //    glEnableVertexAttribArray(_time);
      //    glEnableVertexAttribArray(_mouse);
      //    glEnableVertexAttribArray(_resolution);


}



- (void)setupVBOs {

   GLuint vertexBuffer;
   glGenBuffers(1, &vertexBuffer);
   glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
   glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);

   GLuint indexBuffer;
   glGenBuffers(1, &indexBuffer);
   glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
   glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);

}
#pragma mark - touch  methods
CGPoint originalLocation;
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
   [self setMouseFromTouches:touches];
}

-(void) setMouseFromTouches:(NSSet*)touches {
   UITouch *touch = [touches anyObject];
   originalLocation = [touch locationInView:self];
   mouseX = originalLocation.x/self.bounds.size.width;
   mouseY = 1.0-(originalLocation.y/self.bounds.size.height);
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
   [self setMouseFromTouches:touches];
   /*
    UITouch *touch =  [touches anyObject];
    if(touch.tapCount == 1)
    {
    //  self.backgroundColor = [UIColor redColor];

    }
    */
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{

   [self setMouseFromTouches:touches];
   /*
    UITouch *touch = [touches anyObject];
    CGPoint currentLocation = [touch locationInView:self];
    CGRect frame = self.frame;
    frame.origin.x += currentLocation.x-originalLocation.x;
    frame.origin.y += currentLocation.y-originalLocation.y;
    // self.frame = frame;
    mouseX = currentLocation.x;
    mouseY = currentLocation.y;
    */

}

- (void)destroyFramebuffer;
{
	if (framebuffer)
      {
		glDeleteFramebuffers(1, &framebuffer);
		framebuffer = 0;
      }

	if (_colorRenderBuffer)
      {
		glDeleteRenderbuffers(1, &_colorRenderBuffer);
		_colorRenderBuffer = 0;
      }
}


- (void)createGLTexture:(GLuint *)texName fromCGImage:(CGImageRef)img
{
	GLubyte *spriteData = NULL;
	CGContextRef spriteContext;
	GLuint imgW, imgH, texW, texH;

	imgW = CGImageGetWidth(img);
	imgH = CGImageGetHeight(img);

      // Find smallest possible powers of 2 for our texture dimensions
	for (texW = 1; texW < imgW; texW *= 2) ;
	for (texH = 1; texH < imgH; texH *= 2) ;

      // Allocated memory needed for the bitmap context
	spriteData = (GLubyte *) calloc(texH, texW * 4);
      // Uses the bitmatp creation function provided by the Core Graphics framework.
	spriteContext = CGBitmapContextCreate(spriteData, texW, texH, 8, texW * 4, CGImageGetColorSpace(img), kCGImageAlphaPremultipliedLast);

      // Translate and scale the context to draw the image upside-down (conflict in flipped-ness between GL textures and CG contexts)
      //CGContextTranslateCTM(spriteContext, 0., texH);
   CGContextScaleCTM(spriteContext, 1.0, 1.332);
   	//CGContextTranslateCTM(spriteContext, 0., texH);


      // After you create the context, you can draw the sprite image to the context.
	CGContextDrawImage(spriteContext, CGRectMake(0.0, 0.0, imgW, imgH), img);
      // You don't need the context at this point, so you need to release it to avoid memory leaks.
	CGContextRelease(spriteContext);

      // Use OpenGL ES to generate a name for the texture.
	glGenTextures(1, texName);
      // Bind the texture name.
	glBindTexture(GL_TEXTURE_2D, *texName);
      // Specify a 2D texture image, providing a pointer to the image data in memory
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, texW, texH, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
      // Set the texture parameters to use a minifying filter and a linear filer (weighted average)
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

      // Enable use of the texture
	glEnable(GL_TEXTURE_2D);
      // Set a blending function to use
	glBlendFunc(GL_SRC_ALPHA,GL_ONE);
      //glBlendFunc(GL_SRC_ALPHA,0.7);
      // Enable blending
	glEnable(GL_BLEND);

	free(spriteData);
}


#pragma mark movie reading stuff

- (void) readMovie:(NSURL *)url
{

   startTime = [NSDate date];

   AVURLAsset * asset = [AVURLAsset URLAssetWithURL:url options:nil];
      // create an AVPlayer with your composition
      //AVPlayer* mp = [AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithAsset:asset]];
      //[mp play];

   NSArray *keys = @[@"duration"];
   [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^() {
      NSError *error = nil;
      AVKeyValueStatus tracksStatus = [asset statusOfValueForKey:@"duration" error:&error];
      switch (tracksStatus) {
         case AVKeyValueStatusLoaded:
               //[self updateUserInterfaceForDuration];
            break;
         case AVKeyValueStatusFailed:
               //[self reportError:error forAsset:asset];
            break;
         case AVKeyValueStatusCancelled:
               // Do whatever is appropriate for cancelation.
            break;
      }
   }];



   [asset loadValuesAsynchronouslyForKeys:[NSArray arrayWithObject:@"tracks"] completionHandler:
    ^{
       dispatch_async(dispatch_get_main_queue(),
                      ^{
                         AVAssetTrack * videoTrack = nil;
                         NSArray *audiotracks = [asset tracksWithMediaType:AVMediaTypeAudio];
                         NSLog(@"%s audio tracks = %@",__PRETTY_FUNCTION__,audiotracks);
                         if(audiotracks.count == 1){
                            AVAssetTrack *track = [audiotracks objectAtIndex:0];

                            NSError *error;
                            audiocomposition = [[AVMutableComposition alloc] init];
                            AVMutableCompositionTrack *audioTrack = [audiocomposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
                            [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                                                ofTrack:track
                                                 atTime:kCMTimeZero
                                                  error:&error];
                               //[AudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeAdd(ass.duration, videoAsset2.duration)) ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];

                            audioplayerItem = [AVPlayerItem playerItemWithAsset:audiocomposition];
                            audioplayer = [AVPlayer playerWithPlayerItem:audioplayerItem];
                            [audioplayer play];

                         }
                         NSArray * tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
                         if ([tracks count] == 1) {
                            videoTrack = [tracks objectAtIndex:0];

                            videoDuration = CMTimeGetSeconds([videoTrack timeRange].duration);

                            NSError * error = nil;
                            _movieReader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
                            if (error)
                               NSLog(@"%@", error.localizedDescription);

                            NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
                            NSNumber* value = [NSNumber numberWithUnsignedInt: kCVPixelFormatType_32BGRA];
                            NSDictionary* videoSettings =                                 [NSDictionary dictionaryWithObject:value forKey:key];

                            AVAssetReaderTrackOutput* output = [AVAssetReaderTrackOutput
                                                                assetReaderTrackOutputWithTrack:videoTrack
                                                                outputSettings:videoSettings];
                            output.alwaysCopiesSampleData = NO;

                            [_movieReader addOutput:output];

                            if ([_movieReader startReading])
                               {
                               NSLog(@"reading started");



                               timer = [NSTimer scheduledTimerWithTimeInterval: 1.0/24.0
                                                                        target: self
                                                                      selector: @selector(nextframe:)
                                                                      userInfo: nil
                                                                       repeats: YES];

                               } else {
                                  NSLog(@"reading can't be started");
                               }
                         }
                      });
    }];
}
static int foo = 1;

- (void) readNextMovieFrame {
      //NSLog(@"readNextMovieFrame called");
   foo++;
   if (_movieReader.status == AVAssetReaderStatusReading) {
         //NSLog(@"status is reading");
      AVAssetReaderTrackOutput * output = [_movieReader.outputs objectAtIndex:0];
      CMSampleBufferRef sampleBuffer = [output copyNextSampleBuffer]; // this is the most expensive call



      if (sampleBuffer) {

            //unsigned char *sampleBufferRotated = [self rotateBuffer:sampleBuffer];


         CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
            // Lock the image buffer
         CVPixelBufferLockBaseAddress(imageBuffer,0);
            // Get information of the image
            //uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
            //size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
         size_t width = CVPixelBufferGetWidth(imageBuffer);
         size_t height = CVPixelBufferGetHeight(imageBuffer);
            //printf("width %d height %d\n",(int)width, (int) height);

         /*
          CVPixelBufferRef buffer = NULL;
          CVPixelBufferLockBaseAddress(buffer, 0);

          int status = CVPixelBufferCreateWithBytes(NULL,
          width,
          height,
          kCVPixelFormatType_32BGRA,
          (void*)sampleBufferRotated,
          bytesPerRow,
          NULL,
          0,
          NULL,
          &buffer);
          CVPixelBufferUnlockBaseAddress(buffer, 0);
          */
         int status = 0;

         if(status == 0){


               // Create a new texture from the camera frame data, display that using the shaders
               //glGenTextures(1, &videoFrameTexture);
               //glBindTexture(GL_TEXTURE_2D, videoFrameTexture);



            glActiveTexture(GL_TEXTURE0);
            glEnable(GL_TEXTURE_2D);
               //glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
            glBlendFunc(GL_ONE, GL_SRC_ALPHA );
               //glEnable(GL_BLEND);

            glGenTextures(1, &videoFrameTexture);
            glBindTexture(GL_TEXTURE_2D, videoFrameTexture);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
               // This is necessary for non-power-of-two textures
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

               // Using BGRA extension to pull in video frame data directly
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_BGRA, GL_UNSIGNED_BYTE, CVPixelBufferGetBaseAddress(imageBuffer));

         }

            /////////
         [self drawFrame];

         glDeleteTextures(1, &videoFrameTexture);


            // Unlock the image buffer
         CVPixelBufferUnlockBaseAddress(imageBuffer,0);
         CFRelease(sampleBuffer);
            //NSLog(@"ftime is %f",ftime);
         if(ftime > 28.116690) {
               //
               // move to index

         }


      } else {
         [timer invalidate];
         [self removeFromSuperview];
         NSLog(@"could not copy next sample buffer. status is %d time is %u", _movieReader.status,_time);


         if(self.tag == 100){
            if (self.delegate ) { // && [self.delegate respondsToSelector:@selector(avatarPlaybackFinished:)]) {
               [self.delegate avatarPlaybackFinished:self.tag];
            } //playbackFinished:
         }

      }


   } else {

      NSLog(@"status is now %d", _movieReader.status);
      if(_movieReader.status == 2){
         [timer invalidate];
         timer = nil;
            //[self teardown];
         [self removeFromSuperview];
      }

   }// movie reads

} // method end

-(void) nextframe:(NSTimer *) timer {
      //totalTime +=.01;
   [self readNextMovieFrame];
}

-(void) playvid {
   NSURL *vid1 = nil;
   outputqueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
   vid1 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:_movieFileName ofType:@"mov"]];
   [self readMovie:vid1];
}


-(NSString*) loadFile:(NSString*)fileName  fileExt:(NSString*) ext {

   NSString* shaderPath = [[NSBundle mainBundle] pathForResource:fileName
                                                          ofType:ext];
   NSError* error;
   NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath
                                                      encoding:NSUTF8StringEncoding error:&error];
   if (!shaderString) {
      NSLog(@"Error loading shader: %@ %@", shaderPath,error.localizedDescription);
      return @"";
   }
   return shaderString;
}


- (unsigned char*) rotateBufferF: (CMSampleBufferRef) sampleBuffer
{
   CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
   CVPixelBufferLockBaseAddress(imageBuffer,0);

   size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
   size_t width = CVPixelBufferGetWidth(imageBuffer);
   size_t height = CVPixelBufferGetHeight(imageBuffer);
   size_t currSize = bytesPerRow*height*sizeof(unsigned char);
   size_t bytesPerRowOut = 4*height*sizeof(unsigned char);

   void *srcBuff = CVPixelBufferGetBaseAddress(imageBuffer);

   /*
    * rotationConstant:   0 -- rotate 0 degrees (simply copy the data from src to dest)
    *             1 -- rotate 90 degrees counterclockwise
    *             2 -- rotate 180 degress
    *             3 -- rotate 270 degrees counterclockwise
    */
      //uint8_t rotationConstant = 1;

   unsigned char *outBuff = (unsigned char*)malloc(currSize);

   vImage_Buffer ibuff = { srcBuff, height, width, bytesPerRow};
   vImage_Buffer ubuff = { outBuff, width, height, bytesPerRowOut};
   Pixel_8888 backColour = { (uint8_t)222,(uint8_t)222, (uint8_t)222,(uint8_t)222 };
   vImage_Error err = vImageRotate90_ARGB8888(&ibuff, &ubuff, kRotate180DegreesClockwise, backColour, 0);
      //vImage_Error err= vImageRotate90_ARGB8888 (&ibuff, &ubuff,  rotationConstant, NULL,0);
   if (err != kvImageNoError) NSLog(@"%ld", err);

   return outBuff;
}


- (CVPixelBufferRef) rotateBuffer: (CMSampleBufferRef) sampleBuffer
{
   CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
   CVPixelBufferLockBaseAddress(imageBuffer,0);

   size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
   size_t width = CVPixelBufferGetWidth(imageBuffer);
   size_t height = CVPixelBufferGetHeight(imageBuffer);

   void *src_buff = CVPixelBufferGetBaseAddress(imageBuffer);

   NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                            [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                            nil];

   CVPixelBufferRef pxbuffer = NULL;
      //CVReturn status = CVPixelBufferPoolCreatePixelBuffer (NULL, _pixelWriter.pixelBufferPool, &pxbuffer);
   CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, width,
                                         height, kCVPixelFormatType_32BGRA, (CFDictionaryRef) CFBridgingRetain(options),
                                         &pxbuffer);

   NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);

   CVPixelBufferLockBaseAddress(pxbuffer, 0);
   void *dest_buff = CVPixelBufferGetBaseAddress(pxbuffer);
   NSParameterAssert(dest_buff != NULL);

   int *src = (int*) src_buff ;
   int *dest= (int*) dest_buff ;
   size_t count = (bytesPerRow * height) / 4 ;
   while (count--) {
      *dest++ = *src++;
   }

      //Test straight copy.
      //memcpy(pxdata, baseAddress, width * height * 4) ;
   CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
   CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
   return pxbuffer;
}




- (const GLchar *)readFile:(NSString *)name
{
   NSString *path;
   const GLchar *source;

   path = [[NSBundle mainBundle] pathForResource:name ofType: nil];
   source = (GLchar *)[[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil] UTF8String];

   return source;
}

- (CGRect)textureSamplingRectForCroppingTextureWithAspectRatio:(CGSize)textureAspectRatio toAspectRatio:(CGSize)croppingAspectRatio
{
	CGRect normalizedSamplingRect = CGRectZero;
	CGSize cropScaleAmount = CGSizeMake(croppingAspectRatio.width / textureAspectRatio.width, croppingAspectRatio.height / textureAspectRatio.height);
	CGFloat maxScale = fmax(cropScaleAmount.width, cropScaleAmount.height);
	CGSize scaledTextureSize = CGSizeMake(textureAspectRatio.width * maxScale, textureAspectRatio.height * maxScale);

	if ( cropScaleAmount.height > cropScaleAmount.width ) {
		normalizedSamplingRect.size.width = croppingAspectRatio.width / scaledTextureSize.width;
		normalizedSamplingRect.size.height = 1.0;
	}
	else {
		normalizedSamplingRect.size.height = croppingAspectRatio.height / scaledTextureSize.height;
		normalizedSamplingRect.size.width = 1.0;
	}
      // Center crop
	normalizedSamplingRect.origin.x = (1.0 - normalizedSamplingRect.size.width)/2.0;
	normalizedSamplingRect.origin.y = (1.0 - normalizedSamplingRect.size.height)/2.0;

	return normalizedSamplingRect;
}


-(void) textureCacheFromPixelBuffer:(CVImageBufferRef) pixelBuffer {
   if (videoTextureCache == NULL) {
      return;
   }

      // Create a CVOpenGLESTexture from the CVImageBuffer
	size_t frameWidth = CVPixelBufferGetWidth(pixelBuffer);
	size_t frameHeight = CVPixelBufferGetHeight(pixelBuffer);
   CVOpenGLESTextureRef texture = NULL;
   CVReturn err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                               videoTextureCache,
                                                               pixelBuffer,
                                                               NULL,
                                                               GL_TEXTURE_2D,
                                                               GL_RGBA,
                                                               frameWidth,
                                                               frameHeight,
                                                               GL_BGRA,
                                                               GL_UNSIGNED_BYTE,
                                                               0,
                                                               &texture);


   if (!texture || err) {
      NSLog(@"CVOpenGLESTextureCacheCreateTextureFromImage failed (error: %d)", err);
      return;
   }

	glBindTexture(CVOpenGLESTextureGetTarget(texture), CVOpenGLESTextureGetName(texture));

      // Set texture parameters
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
}


- (void)displayPixelBuffer:(CVImageBufferRef)pixelBuffer

{

   if(framebuffer == 0){
      return;
   }
      // Lock the image buffer
   CVPixelBufferLockBaseAddress(pixelBuffer,0);
      // Get information of the image
      //uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
      //size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
   size_t width = CVPixelBufferGetWidth(pixelBuffer);
   size_t height = CVPixelBufferGetHeight(pixelBuffer);
      //printf("width %d height %d\n",(int)width, (int) height);

   /*
    CVPixelBufferRef buffer = NULL;
    CVPixelBufferLockBaseAddress(buffer, 0);

    int status = CVPixelBufferCreateWithBytes(NULL,
    width,
    height,
    kCVPixelFormatType_32BGRA,
    (void*)sampleBufferRotated,
    bytesPerRow,
    NULL,
    0,
    NULL,
    &buffer);
    CVPixelBufferUnlockBaseAddress(buffer, 0);
    */
   int status = 0;

   if(status == 0){


         // Create a new texture from the camera frame data, display that using the shaders
         //glGenTextures(1, &videoFrameTexture);
         //glBindTexture(GL_TEXTURE_2D, videoFrameTexture);



      glActiveTexture(GL_TEXTURE0);
      glEnable(GL_TEXTURE_2D);
         //glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
      glBlendFunc(GL_ONE, GL_SRC_ALPHA );
         //glEnable(GL_BLEND);

      glGenTextures(1, &videoFrameTexture);
      glBindTexture(GL_TEXTURE_2D, videoFrameTexture);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
         // This is necessary for non-power-of-two textures
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

         // Using BGRA extension to pull in video frame data directly
      glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_BGRA, GL_UNSIGNED_BYTE, CVPixelBufferGetBaseAddress(pixelBuffer));

   }

      /////////
   [self drawFrame];

   glDeleteTextures(1, &videoFrameTexture);
   
   
      // Unlock the image buffer
   CVPixelBufferUnlockBaseAddress(pixelBuffer,0);
      //CFRelease(imageBuffer);
   
   
}

#pragma mark audio 

/*
 - (void)readNextAudioSampleFromOutput:(AVAssetReaderTrackOutput *)readerAudioTrackOutput;
 {
 if (audioEncodingIsFinished)
 {
 return;
 }
 
 CMSampleBufferRef audioSampleBufferRef = [readerAudioTrackOutput copyNextSampleBuffer];
 
 if (audioSampleBufferRef)
 {
 runSynchronouslyOnVideoProcessingQueue(^{
 [self.audioEncodingTarget processAudioBuffer:audioSampleBufferRef];
 
 CMSampleBufferInvalidate(audioSampleBufferRef);
 CFRelease(audioSampleBufferRef);
 });
 }
 else
 {
 audioEncodingIsFinished = YES;
 }
 }
 
 */

-(void) teardown {
   
      //glClearColor(0.5f, 0.5f, 0.5f, 1);
      //glClear(GL_COLOR_BUFFER_BIT);
   
   if ([EAGLContext currentContext] == _context )
      [EAGLContext setCurrentContext:nil];
   
   
}



@end
