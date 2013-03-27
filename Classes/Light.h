#import <Foundation/Foundation.h>
#import "X3DNode.h"

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@interface Light : X3DNode {
	GLfloat intensity;
	GLfloat *color;
	BOOL on;
	BOOL global;
	GLfloat ambientIntensity;
}

@property (assign,readonly) GLfloat *color;
@property (assign,readwrite) GLfloat intensity, ambientIntensity;
@property (assign,readwrite) BOOL on;
@property (assign,readwrite) BOOL global;

-(void)setColor:(float[3])v;


@end
