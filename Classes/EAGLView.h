#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "iX3DAppDelegate.h"

#import "X3DNode.h"
#import "Scene.h"
#import "Shape.h"
#import "IndexedFaceSet.h"
#import "DirectionalLight.h"
#import "PointLight.h"
#import "SpotLight.h"
#import "Transform.h"

#import "Utils.h"

/*
 This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass.
 The view content is basically an EAGL surface you render your OpenGL scene into.
 Note that setting the view non-opaque will only work if the EAGL surface has an alpha channel.
 */
@interface EAGLView : UIView {
    
@private
    /* The pixel dimensions of the backbuffer */
    GLint backingWidth;
    GLint backingHeight;
    
    EAGLContext *context;
    
    /* OpenGL names for the renderbuffer and framebuffers used to render to this view */
    GLuint viewRenderbuffer, viewFramebuffer;
    
    /* OpenGL name for the depth buffer that is attached to viewFramebuffer, if it exists (0 if it does not exist) */
    GLuint depthRenderbuffer;
    
    NSTimer *animationTimer;
    NSTimeInterval animationInterval;
	
	// app delegate
	iX3DAppDelegate *appDelegate;
	
	// root
	Scene *root;
	
	// current light
	int nextLightToUse, nextLightToEnable, nextLightToDisable;  // GL_LIGHT0,1...
}

@property NSTimeInterval animationInterval;
@property (nonatomic, retain) Scene *root;

- (void)startAnimation;
- (void)stopAnimation;
- (void)drawView;

- (void)setupView;
- (void)checkGLError:(BOOL)visibleCheck;

// metodi per disegnare i vari nodi
-(void)drawTree:(X3DNode*)currentNode;
-(void)drawIndexedFaceSet:(IndexedFaceSet *)indexedFaceSet;
-(void)setLight:(Light *)light;
-(void)setTransformations:(Transform *)transform;
-(void)deleteTransformations;



@end

