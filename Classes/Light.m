#import "Light.h"


@implementation Light

@synthesize color, intensity, ambientIntensity, on, global;


- (id)init
{
	if((self = [super init]))
	{
		on = YES;
		intensity = 1;
		ambientIntensity = 0;
		color = malloc( 3 * sizeof(GLfloat) );
		color[0] = color[1] = color[2] = 1.0f;
	}
	return self;
}

-(void)setColor:(float[3])v {
	for (int i = 0 ; i < 3 ; i++ ) {
		color[i] = (GLfloat)v[i];
	}
}


- (void) dealloc {
	
	free(color);
	
	[super dealloc];
}

@end
