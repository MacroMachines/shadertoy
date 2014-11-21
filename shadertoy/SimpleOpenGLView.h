   //
   //  SimpleOpenGLView.h
   //  shadertoy
   //
   //  Created by ydf on 13-2-3.
   //
   //


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#import <AVFoundation/AVFoundation.h>

@interface SimpleOpenGLView : UIView {
   AVAssetReader *_movieReader;
   AVMutableComposition* audiocomposition;
   AVPlayerItem *audioplayerItem;
   AVPlayer *audioplayer;
   UIImage *backgroundImage;
   dispatch_queue_t outputqueue;
   GLuint videoFrameTexture;
   GLuint backgroundTexture;
   CVOpenGLESTextureCacheRef videoTextureCache;
   GLuint programHandle;

   GLuint framebuffer;
   CAEAGLLayer* _eaglLayer;
   EAGLContext* _context;
   GLuint _colorRenderBuffer;
   GLuint _positionSlot;
   GLuint _surfacePositionSlot;
   GLuint _colorSlot;
   GLuint _texCoordSlot;
   GLuint _texCoordSlot2;
   GLuint _textureUniform;
   GLuint _textureUniform2;

   CADisplayLink* displayLink;

      // more video vars
   Float64 videoDuration;
   NSTimer *timer;

   GLuint timeUniformLocation;
   GLuint textureUniformLocation;
   GLuint texture2UniformLocation;
   GLuint backgroundtextureUniformLocation;
   GLuint videoFrameTextureLocation;

   GLchar *vertSrc;
   GLchar *fragSrc;
   BOOL useDisplayLink;


   GLfloat screenX, screenY;
   GLfloat mouseX, mouseY;
   GLfloat ftime;
   GLuint _mouse;
   GLuint _time;
   GLuint _resolution;

   BOOL shaderFromString;



}
@property(strong ,nonatomic) NSString  *vertexShaderFilename;
@property(strong ,nonatomic) NSString  *fragmentShaderFilename;
@property(strong ,nonatomic) NSString  *movieFileName;
@property(strong ,nonatomic) NSDate    *startTime;
@property (readwrite,assign) GLfloat   uniformOverride;
@property(strong ,nonatomic) NSString  *shaderV;
@property(strong ,nonatomic) NSString  *shaderF;
@property (nonatomic, weak) id delegate;
-(void) stopDisplayLink;
- (id)initWithFrame:(CGRect)frame andShader:(NSString*)shaderName;
- (id)initWithFrame:(CGRect)frame andShaderString:(NSString*)shader;
- (id)initWithFrame:(CGRect)frame andShader:(NSString*)shaderName andMovie:(NSString*) moviename;
- (id)initWithFrame:(CGRect)frame andShader:(NSString*)shaderName useDisplayLink:(BOOL) shouldUseDisplayLink;
- (void)displayPixelBuffer:(CVImageBufferRef)pixelBuffer;
@end


@protocol SimpleOpenGLViewDelegate <NSObject>
-(void) avatarPlaybackFinished:(int) tag;
@end