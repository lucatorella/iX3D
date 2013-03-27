#import "DirectionalLight.h"


@implementation DirectionalLight

@synthesize direction;

- (id)init
{
	if((self = [super init])) {
		direction = malloc( 4 * sizeof(GLfloat) );
		direction[0] = direction[1] = direction[3] = 0.0f;
		direction[2] = -1.0f;
		global = NO;
	}
	return self;
}

-(void)setDirection:(float[3])v {
	for (int i = 0 ; i < 3 ; i++ ) {
		direction[i] = (GLfloat)v[i];
	}
}

- (void) dealloc {
	
	free(direction);
	
	[super dealloc];
}

@end
