
#import <Foundation/Foundation.h>
#import "iX3DAppDelegate.h"
#import "X3DNode.h"

@interface X3DParser : NSObject {
	
//	NSMutableString *currentElementValue;
	
	iX3DAppDelegate *appDelegate;
	
	int state;
	
	X3DNode *currentNode;
}

- (X3DParser *) initXMLParser;

@end
