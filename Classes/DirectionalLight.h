#import <Foundation/Foundation.h>
#import "Light.h"

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@interface DirectionalLight : Light {
	GLfloat *direction;
}

@property (assign,readonly) GLfloat *direction;

-(void)setDirection:(float[3])v;

@end
