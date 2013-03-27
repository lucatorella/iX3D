#import <Foundation/Foundation.h>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "X3DNode.h"


@interface IndexedFaceSet : X3DNode {
	GLfloat *coord;
	int coordSize;
	
	GLfloat *coordIndex;
	int coordIndexSize;
	
	BOOL colorPerVertex;
	GLfloat *colorArray;
	int colorSize;
	
	GLfloat *normalArray;
	int normalSize;
}

@property (assign,readonly) GLfloat *coord, *coordIndex, *colorArray, *normalArray;
@property (assign,readonly) int coordSize, coordIndexSize, colorSize, normalSize;
@property (assign,readwrite) BOOL colorPerVertex;

-(void)setCoordIndex:(NSArray*)a;
-(void)setCoordinate:(NSArray*)a;
-(void)setColors:(NSArray*)a;
-(void)setNormals:(NSArray*)a;

@end
