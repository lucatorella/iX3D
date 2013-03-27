#import "Transform.h"


@implementation Transform

@synthesize scale, rotation, translation, scaling, rotating, translating;

- (id)init
{
	if((self = [super init])) {
		scale = malloc( 3 * sizeof(GLfloat) );
		scale[0] = scale[1] = scale[2] = 1.0f;
		rotation = malloc( 4 * sizeof(GLfloat) );
		rotation[0] = rotation[1] = rotation[3] = 0.0f;
		rotation[2] = 1.0f;
		translation = malloc( 3 * sizeof(GLfloat) );
		translation[0] = translation[1] = translation[2] = 0.0f;
		scaling = rotating = translating = NO;
	}
	return self;
}

-(void)setScale:(float[3])v {
	for (int i = 0 ; i < 3 ; i++ ) {
		scale[i] = (GLfloat)v[i];
	}
	scaling = YES;
}

-(void)setRotation:(float[4])v {
	for (int i = 0 ; i < 4 ; i++ ) {
		rotation[i] = (GLfloat)v[i];
	}
	rotating = YES;
}

-(void)setTranslation:(float[3])v {
	for (int i = 0 ; i < 3 ; i++ ) {
		translation[i] = (GLfloat)v[i];
	}
	translating = YES;
}

- (void) dealloc {
	
	free(scale);
	free(rotation);
	free(translation);
	
	[super dealloc];
}

@end
