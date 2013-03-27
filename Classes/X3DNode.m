#import "X3DNode.h"
#import "Light.h"


@implementation X3DNode

@synthesize sons, parent, lights;

- (id) init {
	[super init];
	
	lights = 0;
	sons = [[NSMutableArray alloc] initWithCapacity:0];
	
	return self;
}

-(NSArray *)brothers {
	
	NSArray *parentSons = parent.sons;
	NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:[parentSons count]-1];
	
	for ( X3DNode *son in parentSons ) {
		if ( son != self )
			[tmpArray addObject:son];
	}
	
	return [NSArray arrayWithArray:tmpArray];
}

-(void)addSon:(X3DNode *)node {
	if ( [node isKindOfClass:[Light class]] )
		[sons addObject:node];
	else
		[sons insertObject:node atIndex:0];

}

- (void) dealloc {
	[sons release];
	[super dealloc];
}

@end
