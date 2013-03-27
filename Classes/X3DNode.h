#import <Foundation/Foundation.h>

/* 
 Scene -> Shape -> IndexedFaceSet
                   Lights
                   Transforms -> IndexedFaceSet
                                 Lights
*/


@interface X3DNode : NSObject {
	X3DNode *parent;
	NSMutableArray *sons;
	
	int lights;
}

@property (nonatomic,retain) X3DNode *parent;
@property (nonatomic,retain) NSMutableArray *sons;
@property (assign,readwrite) int lights;

-(NSArray *)brothers;
-(void)addSon:(X3DNode*)node;

@end
