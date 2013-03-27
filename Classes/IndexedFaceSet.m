#import "IndexedFaceSet.h"


@implementation IndexedFaceSet

@synthesize coord, coordSize, coordIndex, coordIndexSize, colorPerVertex, colorArray, colorSize, normalArray, normalSize;

- (id)init
{
	if((self = [super init])) {
		coordSize = 0;
		coordIndexSize = 0;
		normalSize = 0;
	}
	return self;
}

-(void)setCoordIndex:(NSArray*)a {
	
	coordIndexSize = [a count];
	
	coordIndex = malloc( coordIndexSize * sizeof(GLfloat) );
	
	int i = 0;
	for ( NSNumber *n in a ) {
		coordIndex[i] = (GLfloat)[n floatValue];
		i++;
	}
}

-(void)setCoordinate:(NSArray*)a {
	
	coordSize = [a count];
	
	coord = malloc( coordSize * sizeof(GLfloat) );
	
	int i = 0;
	for ( NSNumber *n in a ) {
		coord[i] = (GLfloat)[n floatValue];
		i++;
	}
}

-(void)setColors:(NSArray*)a {
	
	colorSize = [a count];
	
	colorArray = malloc( colorSize * sizeof(GLfloat) );
	
	int i = 0;
	for ( NSNumber *n in a ) {
		colorArray[i] = (GLfloat)[n floatValue];
		i++;
	}
}

-(void)setNormals:(NSArray*)a {
	
	normalSize = [a count];
	
	normalArray = malloc( normalSize * sizeof(GLfloat) );
	
	int i = 0;
	for ( NSNumber *n in a ) {
		normalArray[i] = (GLfloat)[n floatValue];
		i++;
	}
}


- (void) dealloc {
	
	free(coordIndex);
	free(coord);
	free(colorArray);
	free(normalArray);

	[super dealloc];
}

@end
