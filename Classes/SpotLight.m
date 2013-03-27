#import "SpotLight.h"


@implementation SpotLight

@synthesize location, direction, cutOffAngle, beamWidth, radius, attenuation;


- (id)init
{
	if((self = [super init])) {
		location = malloc( 4 * sizeof(GLfloat) );
		location[0] = location[1] = location[2] = 0.0f;
		location[3] = 1.0f;
		direction = malloc( 3 * sizeof(GLfloat) );
		location[0] = location[1] = 0.0f;
		location[2] = -1.0f;
		cutOffAngle = 3.1415926536/4;// π/4
		beamWidth = 3.1415926536/2;// π/2
		attenuation = malloc( 3 * sizeof(GLfloat) );
		attenuation[0] = 1.0f;
		attenuation[1] = attenuation[2] = 0.0f;
		radius = 100;
		global = YES;
	}
	return self;
}

-(void)setLocation:(float[3])v {
	for (int i = 0 ; i < 3 ; i++ ) {
		location[i] = (GLfloat)v[i];
	}
}

-(void)setDirection:(float[3])v {
	for (int i = 0 ; i < 3 ; i++ ) {
		direction[i] = (GLfloat)v[i];
	}
}

-(void)setAttenuation:(float[3])v {
	for (int i = 0 ; i < 3 ; i++ ) {
		attenuation[i] = (GLfloat)v[i];
	}
}

- (void) dealloc {
	
	free(attenuation);
	free(location);
	
	[super dealloc];
}


@end
