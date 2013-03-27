#import <Foundation/Foundation.h>
#import "X3DNode.h"

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@interface Transform : X3DNode {
	GLfloat *scale;
	GLfloat *rotation;
	GLfloat *translation;
	BOOL scaling, rotating, translating;
}

@property (assign,readonly) GLfloat *scale, *rotation, *translation;
@property (assign,readonly) BOOL scaling, rotating, translating;

-(void)setScale:(float[3])v;
-(void)setRotation:(float[4])v;
-(void)setTranslation:(float[3])v;

@end
