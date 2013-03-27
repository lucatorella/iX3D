#import "iX3DAppDelegate.h"
#import "EAGLView.h"
#import "X3DParser.h"

@implementation iX3DAppDelegate

@synthesize window;
@synthesize glView;
//@synthesize root;

- (void) applicationDidFinishLaunching:(UIApplication *)application
{
	// ***
	// parser xml
	// ***
	NSBundle *bundle = [NSBundle mainBundle];
		
	NSXMLParser *xmlParser = 
	[[NSXMLParser alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[bundle pathForResource:@"esempioE" ofType:@"x3d"]] ];
			
	//Initialize the delegate.
	X3DParser *parser = [[X3DParser alloc] initXMLParser];
	
	//Set delegate
	[xmlParser setDelegate:parser];
	
	//Start parsing the XML file.
	BOOL success = [xmlParser parse];
		
	if(success)
		NSLog(@"No Errors :D");
	else
		NSLog(@"Error Error Error!!!");
	
	[parser release];
	
	// ***
	// fine parsing
	// ***
	
	// start animation
	
	[glView startAnimation];
}

- (void) applicationWillResignActive:(UIApplication *)application
{
	[glView stopAnimation];
}

- (void) applicationDidBecomeActive:(UIApplication *)application
{
	[glView startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	[glView stopAnimation];
}

- (void) dealloc
{
	[window release];
	[glView release];
	
	[super dealloc];
}

@end
