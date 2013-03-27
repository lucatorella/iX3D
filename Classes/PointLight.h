#import <Foundation/Foundation.h>
#import "Light.h"

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@interface PointLight : Light {
	GLfloat *location;
	GLfloat radius;
	GLfloat *attenuation;
}

@property (assign,readonly) GLfloat *attenuation, *location;
@property (assign,readwrite) GLfloat radius;

-(void)setLocation:(float[3])v;
-(void)setAttenuation:(float[3])v;


@end
