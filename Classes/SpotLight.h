#import <Foundation/Foundation.h>
#import "Light.h"

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@interface SpotLight : Light {
	GLfloat *location, *direction;
	GLfloat radius, cutOffAngle, beamWidth;
	GLfloat *attenuation;
}

@property (assign,readonly) GLfloat *attenuation, *direction, *location;
@property (assign,readwrite) GLfloat radius, cutOffAngle, beamWidth;

-(void)setLocation:(float[3])v;
-(void)setDirection:(float[3])v;
-(void)setAttenuation:(float[3])v;


@end
