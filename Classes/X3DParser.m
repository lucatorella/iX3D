#import "X3DParser.h"
#import "IndexedFaceSet.h"
#import "Scene.h"
#import "Shape.h"
#import "DirectionalLight.h"
#import "Light.h"
#import "PointLight.h"
#import "SpotLight.h"
#import "Transform.h"

#import "EAGLView.h"

#define kScene -1
#define kShape 0
#define kIndexedFaceSet 1
#define kIndexedFaceSetElement 2

@implementation X3DParser

- (X3DParser *) initXMLParser {
	
	[super init];
	
	appDelegate = (iX3DAppDelegate *)[UIApplication sharedApplication].delegate;
	
	state = -2;
	
	return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
	attributes:(NSDictionary *)attributeDict {
	
	//************************ Scene
	if([elementName isEqualToString:@"Scene"]) {
		
		NSLog(@"start scene");
		
		state = kScene;
		
		currentNode = [[Scene alloc] init];
		currentNode.parent = nil;
		appDelegate.glView.root = (Scene*)currentNode;
	}//************************ Shape
	if([elementName isEqualToString:@"Shape"] && state == kScene) {
		
		NSLog(@"start shape");
		
		state = kShape;
		
		Shape *shape = [[Shape alloc] init];
		shape.parent = currentNode;
		[currentNode addSon: shape];
		currentNode = shape;
		[shape release];
	}
#pragma mark IndexedFaceSet
	//************************ IndexedFaceSet
	else if ([elementName isEqualToString:@"IndexedFaceSet"] && state == kShape) {
		
		NSLog(@"start IndexedFaceSet");
				
		state = kIndexedFaceSet;
		
		// Initialize the indexFaceSet
		IndexedFaceSet *aIndexedFaceSet = [[IndexedFaceSet alloc] init];
		aIndexedFaceSet.parent = currentNode;
		[currentNode addSon: aIndexedFaceSet];
		currentNode = aIndexedFaceSet;
		
		//NSLog(@"nodo padre %@ con %d figli. Nodo attuale %@",[currentNode.parent description], [currentNode.parent.sons count], [currentNode description]);

				
		// colorPerVertex
		NSString *s = [attributeDict objectForKey:@"colorPerVertex"];
		aIndexedFaceSet.colorPerVertex = [s isEqualToString:@"true"];
		
		// coordIndex
		s = [attributeDict objectForKey:@"coordIndex"];
		if ( s != nil ) {
			NSScanner *scanner = [NSScanner scannerWithString: s];
			float val;
			NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
			while ( ![scanner isAtEnd] ) {
				
				[scanner scanFloat:&val];
				
				[tmpArray addObject: [NSNumber numberWithFloat:val]];
			}
			[aIndexedFaceSet setCoordIndex: tmpArray];
			[tmpArray release];
			[aIndexedFaceSet release];
		}
	}
	//************************ IndexedFaceSet -> Coordinate
	else if ( [elementName isEqualToString:@"Coordinate"] && state == kIndexedFaceSet ) {
		NSLog(@"start Coordinate");
		
		state = kIndexedFaceSetElement;
		
		NSString *s = [NSString stringWithString: [attributeDict objectForKey:@"point"] ];
		if ( s != nil ) {
			NSScanner *scanner = [NSScanner scannerWithString: s];
			float val;
			NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
			while ( ![scanner isAtEnd] ) {
			
				[scanner scanFloat:&val];
				
				[tmpArray addObject: [NSNumber numberWithFloat:val]];
			}
			[(IndexedFaceSet*)currentNode setCoordinate: tmpArray];
			[tmpArray release];
		}
	}
	//************************ IndexedFaceSet -> Normals
	else if ( [elementName isEqualToString:@"Normal"] && state == kIndexedFaceSet ) {
		NSLog(@"start Normal");
		
		state = kIndexedFaceSetElement;
		
		NSString *s = [NSString stringWithString: [attributeDict objectForKey:@"vector"] ];
		
		if ( s != nil ) {
			NSScanner *scanner = [NSScanner scannerWithString: s];
			float val;
			NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
			while ( ![scanner isAtEnd] ) {
				
				[scanner scanFloat:&val];
				
				[tmpArray addObject: [NSNumber numberWithFloat:val]];
			}
			if ( s != nil )
				[(IndexedFaceSet*)currentNode setNormals: tmpArray];
			[tmpArray release];
		}
	}
	//************************ IndexedFaceSet -> Color
	else if ( [elementName isEqualToString:@"Color"] && state == kIndexedFaceSet ) {
		NSLog(@"start Color");
		
		state = kIndexedFaceSetElement;
		
		NSString *s = [NSString stringWithString: [attributeDict objectForKey:@"color"] ];
		
		if ( s != nil ) {
			NSScanner *scanner = [NSScanner scannerWithString: s];
			float val;
			NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
			while ( ![scanner isAtEnd] ) {
				[scanner scanFloat:&val];
				
				[tmpArray addObject: [NSNumber numberWithFloat:val]];
			}
			[(IndexedFaceSet*)currentNode setColors: tmpArray];
			[tmpArray release];
		}
	}
#pragma mark DirectionalLight
	//************************ Directional Light
	else if ( [elementName isEqualToString:@"DirectionalLight"] && state == kShape ) {
		NSLog(@"start DirectionalLight");
		
		DirectionalLight *light = [[DirectionalLight alloc] init];
		
		//NSLog(@"nodo padre %@ con %d figli. Nodo attuale %@",[currentNode.parent description], [currentNode.parent.sons count], [currentNode description]);

		
		// Direction
		NSString *s = [attributeDict objectForKey:@"direction"];
		NSScanner *scanner;		
		
		float vec[3];	
		if ( s != nil ) {
			scanner = [NSScanner scannerWithString: s];
			for ( int i = 0 ; i < 3 ; i++ ) {
				[scanner scanFloat:&vec[i]];
			}
			[light setDirection: vec];
		}
		
		
		// Global
		if ([(NSString *)[attributeDict objectForKey:@"global"] isEqualToString:@"true"]) {
			// luce globale, la aggiungo come figlio della radice
			light.parent = appDelegate.glView.root; // il padre è la radice
			[appDelegate.glView.root addSon: light]; // lo aggiungo ai figli della radice
			appDelegate.glView.root.lights++; // incremento luci radice
			light.global = YES;
		} 		
		else {
			// luce locale
			currentNode.lights++; // aumento le luci del padre
			[currentNode addSon:light]; // aggiungo la luce come figlio del padre
			light.parent = currentNode; // imposto il padre della luce
			light.global = NO;
		}
		
		// Intensity
		s = [attributeDict objectForKey:@"intensity"];
		if ( s != nil ) {
			light.intensity = [s floatValue];
		}
		
		// ambientIntensity
		s = [attributeDict objectForKey:@"ambientIntensity"];
		if ( s != nil ) {
			light.ambientIntensity = [s floatValue];
		}
		
		// Color
		s = [attributeDict objectForKey:@"color"];
		if ( s != nil ) {
			scanner = [NSScanner scannerWithString: s];
			for ( int i = 0 ; i < 3 ; i++ ) {
				[scanner scanFloat:&vec[i]];
			}
			[light setColor:vec];
		}
		
		// -- release
		[light release];
	}
#pragma mark PointLight
	//************************ Point Light
	else if ( [elementName isEqualToString:@"PointLight"] && state == kShape ) {
		NSLog(@"start PointLight");
		
		PointLight *light = [[PointLight alloc] init];
		
		// Location
		NSString *s = [attributeDict objectForKey:@"location"];
		NSScanner *scanner;		
		
		float vec[3];	
		if ( s != nil ) {
			scanner = [NSScanner scannerWithString: s];
			for ( int i = 0 ; i < 3 ; i++ ) {
				[scanner scanFloat:&vec[i]];
			}
			[light setLocation: vec];
		}
		
		// Global
		if ([(NSString *)[attributeDict objectForKey:@"global"] isEqualToString:@"false"]) { // tutti i figli del padre sono soggetti a questa luce
			// luce locale
			currentNode.lights++; // aumento le luci del padre
			[currentNode addSon:light]; // aggiungo la luce come figlio del padre
			light.parent = currentNode; // imposto il padre della luce
			light.global = NO;
		} 		
		else { 
			// luce globale, la aggiungo come figlio della radice
			light.parent = appDelegate.glView.root; // il padre è la radice
			[appDelegate.glView.root addSon: light]; // lo aggiungo ai figli della radice
			appDelegate.glView.root.lights++; // incremento luci radice
			light.global = YES;
		}
		
		// Radius
		s = [attributeDict objectForKey:@"radius"];
		if ( s != nil ) {
			light.radius = [s floatValue];
		}
		
		// Attenuation
		s = [attributeDict objectForKey:@"attenuation"];
		
		if ( s != nil ) {
			scanner = [NSScanner scannerWithString: s];
			for ( int i = 0 ; i < 3 ; i++ ) {
				[scanner scanFloat:&vec[i]];
			}
			[light setAttenuation: vec];
		}
		
		
		// color
		s = [attributeDict objectForKey:@"color"];
		if ( s != nil ) {
			scanner = [NSScanner scannerWithString: s];
			for ( int i = 0 ; i < 3 ; i++ ) {
				[scanner scanFloat:&vec[i]];
			}
			[light setColor:vec];
		}
		
		// -- release
		[light release];
	}
#pragma mark SpotLight
	//************************ Spot Light
	else if ( [elementName isEqualToString:@"SpotLight"] && state == kShape ) {
		NSLog(@"start SpotLight");
		
		SpotLight *light = [[SpotLight alloc] init];
		
		// Location
		NSString *s = [attributeDict objectForKey:@"location"];
		NSScanner *scanner;		
		
		float vec[3];		
		if ( s != nil ) {
			scanner = [NSScanner scannerWithString: s];
			for ( int i = 0 ; i < 3 ; i++ ) {
				[scanner scanFloat:&vec[i]];
			}
			[light setLocation: vec];
		}
		
		
		// Direction
		s = [attributeDict objectForKey:@"direction"];
		if ( s != nil ) {
			scanner = [NSScanner scannerWithString: s];
			for ( int i = 0 ; i < 3 ; i++ ) {
				[scanner scanFloat:&vec[i]];
			}
			[light setDirection: vec];
		}
		
		
		// Global
		if ([(NSString *)[attributeDict objectForKey:@"global"] isEqualToString:@"false"]) { // tutti i figli del padre sono soggetti a questa luce
			// luce locale
			currentNode.lights++; // aumento le luci del padre
			[currentNode addSon:light]; // aggiungo la luce come figlio del padre
			light.parent = currentNode; // imposto il padre della luce
			light.global = NO;
		} 		
		else { 
			// luce globale, la aggiungo come figlio della radice
			light.parent = appDelegate.glView.root; // il padre è la radice
			[appDelegate.glView.root addSon: light]; // lo aggiungo ai figli della radice
			appDelegate.glView.root.lights++; // incremento luci radice
			light.global = YES;
		}
		
		// Radius
		s = [attributeDict objectForKey:@"radius"];
		if ( s != nil ) {
			light.radius = [s floatValue];
		}
		
		// CutOffAngle
		s = [attributeDict objectForKey:@"cutOffAngle"];
		if ( s != nil ) {
			light.cutOffAngle = [s floatValue];
		}
		
		// BeamWidth
		s = [attributeDict objectForKey:@"beamWidth"];
		if ( s != nil ) {
			light.beamWidth = [s floatValue];
		}
		
		// Attenuation
		s = [attributeDict objectForKey:@"attenuation"];
		
		if ( s != nil ) {
			scanner = [NSScanner scannerWithString: s];
			for ( int i = 0 ; i < 3 ; i++ ) {
				[scanner scanFloat:&vec[i]];
			}
			[light setAttenuation: vec];
		}
		
		
		// color
		s = [attributeDict objectForKey:@"color"];
		if ( s != nil ) {
			scanner = [NSScanner scannerWithString: s];
			for ( int i = 0 ; i < 3 ; i++ ) {
				[scanner scanFloat:&vec[i]];
			}
			[light setColor:vec];
		}
		
		// -- release
		[light release];
	}
#pragma mark Transform
	//************************ Transformation
	else if ( [elementName isEqualToString:@"Transform"] && state == kShape ) {
		NSLog(@"start Transform");
		
		state = kScene;
		
		Transform *transform = [[Transform alloc] init];
		transform.parent = currentNode;
		[currentNode addSon: transform];
		currentNode = transform;
		
		//NSLog(@"nodo padre %@ con %d figli. Nodo attuale %@",[currentNode.parent description], [currentNode.parent.sons count], [currentNode description]);
				
		// Scale
		NSString *s = [attributeDict objectForKey:@"scale"];
		NSScanner *scanner;		
		
		float vec[3];
		
		if ( s != nil ) {
			scanner = [NSScanner scannerWithString: s];
			for ( int i = 0 ; i < 3 ; i++ ) {
				[scanner scanFloat:&vec[i]];
			}
			[transform setScale: vec];
		}
		
		
		// Rotation
		s = [attributeDict objectForKey:@"rotation"];
		if ( s != nil ) {
			scanner = [NSScanner scannerWithString: s];
			for ( int i = 0 ; i < 4 ; i++ ) {
				[scanner scanFloat:&vec[i]];
			}
			[transform setRotation: vec];
		}
		
		
		// Translation
		s = [attributeDict objectForKey:@"translation"];
		if ( s != nil ) {
			scanner = [NSScanner scannerWithString: s];
			for ( int i = 0 ; i < 3 ; i++ ) {
				[scanner scanFloat:&vec[i]];
			}
			[transform setTranslation: vec];
		}
		
		
		// -- release
		[transform release];
	}
	
	
	//NSLog(@"just created node: %@", [currentNode description]);
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	
	//************************ fine Scene
	if([elementName isEqualToString:@"Scene"]) {
		state = -2; // fine di tutto
		currentNode = nil;
		return;
	}
	//************************ fine Shape
	if([elementName isEqualToString:@"Shape"]) {
		state = kScene;
		currentNode = currentNode.parent;
		return;
	}
	
	//************************ fine IndexedFaceSet
	if([elementName isEqualToString:@"IndexedFaceSet"]) {
		state = kShape;
		currentNode = currentNode.parent;
		return;
	}
	if([elementName isEqualToString:@"Coordinate"] || [elementName isEqualToString:@"Color"] || [elementName isEqualToString:@"Normal"]) {
		state = kIndexedFaceSet;
		return;
	}
	
	//************************ fine Transform
	if([elementName isEqualToString:@"Transform"]) {
		state = kShape;
		currentNode = currentNode.parent;
		return;
	}
}

-(void)dealloc {
	[currentNode release];
	[super dealloc];
}


@end
