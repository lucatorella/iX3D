#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

#import "EAGLView.h"

#define USE_DEPTH_BUFFER 1
#define DEGREES_TO_RADIANS(__ANGLE) ((__ANGLE) / 180.0 * M_PI)

// A class extension to declare private methods
@interface EAGLView ()

@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, assign) NSTimer *animationTimer;

- (BOOL) createFramebuffer;
- (void) destroyFramebuffer;

@end


@implementation EAGLView

@synthesize context;
@synthesize animationTimer;
@synthesize animationInterval;
@synthesize root;


// You must implement this method
+ (Class)layerClass {
    return [CAEAGLLayer class];
}


//The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder {
    
    if ((self = [super initWithCoder:coder])) {
        // Get the layer
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
        
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        
        if (!context || ![EAGLContext setCurrentContext:context]) {
            [self release];
            return nil;
        }
        
        animationInterval = 1 / 30.0;
		//rota = 0.0;
		
		nextLightToUse = nextLightToEnable = nextLightToDisable = GL_LIGHT0;
		
		[self setupView];
    }
    return self;
}

#pragma mark drawView
- (void)drawView {
	//NSLog(@"Starting to draw...");
	// provare a spostare da qualche altra parte
	//if (appDelegate == nil)
	//	appDelegate = (iX3DAppDelegate *)[UIApplication sharedApplication].delegate;
	
	// This application only creates a single context which is already set current at this point.
	// This call is redundant, but needed if dealing with multiple contexts.
    [EAGLContext setCurrentContext:context];
    
	// This application only creates a single default framebuffer which is already bound at this point.
	// This call is redundant, but needed if dealing with multiple framebuffers.
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glViewport(0, 0, backingWidth, backingHeight);
	
	glClearColor(0.5, 0.5, 0.5, 1.0);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	glMatrixMode(GL_MODELVIEW); // passo alla modalità per mettere gli oggetti nella scena
	
	/*
	 Inizio codice OpenGL per disegnare
	 */
	glEnable(GL_NORMALIZE);
	glEnable(GL_COLOR_MATERIAL);
	glLoadIdentity();
	
	//glFrontFace(GL_CCW);
	nextLightToUse = nextLightToEnable = GL_LIGHT0;
	
	//glEnable(GL_LIGHTING);
	
	[self drawTree: root]; // inizio a disegnare dalla radice
	
	/*
	 Fine codice OpenGL per disegnare
	 */
	
    // This application only creates a single color renderbuffer which is already bound at this point.
	// This call is redundant, but needed if dealing with multiple renderbuffers.
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewFramebuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
	
	//[self stopAnimation];
}

-(void)drawTree:(X3DNode*)currentNode {
	
	X3DNode *node;
	
	//NSLog(@"starting: %@ che ha %d figli", [currentNode description], [currentNode.sons count]);
	
	if ( currentNode.lights > 0 ) { // i nodi figli devono essere illuminati
		//NSLog(@"i suoi figli hanno luce");
		if ( nextLightToEnable + currentNode.lights <= GL_LIGHT7 ) {
			glEnable(GL_LIGHTING);
			int i;
			for (i=0 ; i<currentNode.lights ; i++) {
				//NSLog(@"GL_LIGHT0: %d - luce enabled: %d", GL_LIGHT0, nextLightToEnable+i);
				//NSLog(@"currentLight: %d - numberOfLights: %d - i: %d", currentLight, numberOfLights, i);
				glEnable(nextLightToEnable+i); // abilito tante luci quante ce ne sono nei figli del currentNode
			}
			nextLightToEnable+=i;
			nextLightToDisable=nextLightToEnable;
		}
		else {
			NSLog(@"troppe luci");
		}
	} 
	/****** vedo che tipo di nodi figli ho e chiamo le varie funzioni che utilizzeranno OpenGL  ******/
	for ( node in currentNode.sons ) {
		if ( [node isMemberOfClass:[Shape class]] ) {
			//NSLog(@"one of the sons is a shape");
			[self drawTree:node];
		}
		else if ( [node isMemberOfClass:[IndexedFaceSet class]] ) {
			//NSLog(@"one of the sons is a indexedf...");
			[self drawIndexedFaceSet:(IndexedFaceSet*)node];
		}
		else if ( [node isKindOfClass:[Light class]] ) { // appartiene ad una sottoclasse di Light
			//NSLog(@"one of the sons is a light...");
			[self setLight:(Light*)node];
		}
		else if ( [node isMemberOfClass:[Transform class]] ) { // appartiene ad una sottoclasse di Light
			//NSLog(@"one of the sons is a transformation...");
			[self setTransformations:(Transform*)node]; // do the transformation
			[self drawTree:node]; // disegno i figli
			[self deleteTransformations];
		}
	}
	if ( currentNode.lights > 0 ) { // finisco il nodo i cui figli devono essere illuminati
		for (int i=currentNode.lights ; i>0 ; i--) {
			//NSLog(@"GL_LIGHT0: %d - luce disabled: %d", GL_LIGHT0, nextLightToDisable-i);
			glDisable(nextLightToDisable-i); // vengono disabilitate le luci che dovevano illuminare i figli di questo nodo.
		}
		if ( nextLightToDisable == nextLightToEnable ) {
			glDisable(GL_LIGHTING);
		}
		nextLightToDisable-=(currentNode.lights-1);
	}
	//NSLog(@"I'm finishing with the node %@", [currentNode description]);
}

#pragma mark Metodi disegno ausiliari
- (void)drawIndexedFaceSet:(IndexedFaceSet *)indexedFaceSet
{
	GLfloat shapeVertices[indexedFaceSet.coordIndexSize*3-1]; // una figura non avrà mai più vetici di così
	GLfloat colorVertices[indexedFaceSet.coordIndexSize*4-1];
	GLfloat normalVertices[indexedFaceSet.coordIndexSize*3-1];
	int faceSize = 0; //Number of vertex in current face
	int currentFace = 0; // numero della faccia corrente
	
	for (int index = 0; index < indexedFaceSet.coordIndexSize; index++)
	{
		if (indexedFaceSet.coordIndex[index] != -1)
		{
			int position = (indexedFaceSet.coordIndex[index]) * 3;
			
			shapeVertices[faceSize*3] = indexedFaceSet.coord[position];
			shapeVertices[faceSize*3+1] = indexedFaceSet.coord[position + 1];
			shapeVertices[faceSize*3+2] = indexedFaceSet.coord[position + 2];
			
			if ( indexedFaceSet.normalSize == indexedFaceSet.coordSize ) { // se abbiamo a disposizione le normali
				normalVertices[faceSize*3] = indexedFaceSet.normalArray[position];
				normalVertices[faceSize*3+1] = indexedFaceSet.normalArray[position + 1];
				normalVertices[faceSize*3+2] = indexedFaceSet.normalArray[position + 2];
			}
			
			if ( indexedFaceSet.colorPerVertex && indexedFaceSet.colorSize == indexedFaceSet.coordSize ) { // un colore diverso per ogni vertice
				colorVertices[faceSize*4] = indexedFaceSet.colorArray[position];
				colorVertices[faceSize*4+1] = indexedFaceSet.colorArray[position + 1];
				colorVertices[faceSize*4+2] = indexedFaceSet.colorArray[position + 2];
				colorVertices[faceSize*4+3] = 0.8f;
			}
			
			faceSize++;
		}
		//End of a face...
		else
		{
			glColor4f(1.0f, 1.0f, 1.0f, 1.0f); // colore default
			// un colore unico per ogni faccia
			if ( !indexedFaceSet.colorPerVertex && currentFace*3+2 < indexedFaceSet.colorSize ) {
				glColor4f(indexedFaceSet.colorArray[currentFace*3],
						  indexedFaceSet.colorArray[currentFace*3+1],
						  indexedFaceSet.colorArray[currentFace*3+2],
						  0.8f);
			}
			else { // un colore diverso per ogni vertice
				glColorPointer(4, GL_FLOAT, 0, colorVertices);
				glEnableClientState(GL_COLOR_ARRAY); // abilito il disegno con i color array
			}
			
			//Draw current face
			glVertexPointer(3, GL_FLOAT, 0, shapeVertices);
			if ( indexedFaceSet.normalSize == indexedFaceSet.coordSize ) { // se abbiamo le normali
				glEnableClientState(GL_NORMAL_ARRAY);
				glNormalPointer(GL_FLOAT, 0, normalVertices);
			}
			glEnableClientState(GL_VERTEX_ARRAY);
			glDrawArrays(GL_TRIANGLE_FAN, 0, faceSize);
			
			//Get ready for next face
			faceSize = 0;
			currentFace++;
			glDisableClientState(GL_VERTEX_ARRAY);
			if ( indexedFaceSet.normalSize == indexedFaceSet.coordSize ) // se abbiamo le normali
				glDisableClientState(GL_NORMAL_ARRAY);
		}
	}
}

-(void)setLight:(Light *)light {
	
	GLfloat LightPosition[4];
	GLfloat LightAmbient[]= { 1.0f, 1.0f, 1.0f, 1.0f }; // luce ambiente (in x3d non si mette)
	GLfloat LightDiffuse[]= { light.color[0], light.color[1], light.color[2], 1.0f }; // Componente diffuse
	
	for ( int i = 0 ; i < 3 ; i++ ) {
		LightAmbient[i] *= light.ambientIntensity;
		LightDiffuse[i] *= light.intensity;
	}
	
	/*** DirectionalLight ***/
	if ( [light isMemberOfClass:[DirectionalLight class]] ) {
		DirectionalLight *dlight = (DirectionalLight *)light;
		for ( int i = 0 ; i < 4 ; i++ )
			LightPosition[i] = dlight.direction[i]; // questa è la direzione della luce, l'elemento di indice 3 è messo a 0.0f
	}
	/*** PointLight ***/
	else if ( [light isMemberOfClass:[PointLight class]] ) {
		PointLight *plight = (PointLight *)light;
		for ( int i = 0 ; i < 4 ; i++ )
			LightPosition[i] = plight.location[i]; // questa è la posizione della luce, l'elemento di indice 3 è messo a 1.0f
		// cutoff è di 180*2
		glLightf(nextLightToUse, GL_SPOT_CUTOFF, 180.0f);
		// attenuation
		glLightf(nextLightToUse, GL_CONSTANT_ATTENUATION, plight.attenuation[0]);
		glLightf(nextLightToUse, GL_LINEAR_ATTENUATION, plight.attenuation[1]);
		glLightf(nextLightToUse, GL_QUADRATIC_ATTENUATION, plight.attenuation[2]);
	}
	/*** SpotLight ***/
	else if ( [light isMemberOfClass:[SpotLight class]] ) {
		SpotLight *slight = (SpotLight *)light;
		GLfloat LightDirection[3];
		for ( int i = 0 ; i < 4 ; i++ ) {
			LightPosition[i] = slight.location[i]; 
			LightDirection[i] = slight.direction[i]; // questa è la direzione della luce, l'elemento di indice 3 è messo a 1.0f
		}
		// cutoff
		glLightf(nextLightToUse, GL_SPOT_CUTOFF, slight.cutOffAngle/3.1415926536*180);
		// direction
		glLightfv(nextLightToUse, GL_SPOT_DIRECTION, LightDirection);
		// attenuation
		glLightf(nextLightToUse, GL_CONSTANT_ATTENUATION, slight.attenuation[0]);
		glLightf(nextLightToUse, GL_LINEAR_ATTENUATION, slight.attenuation[1]);
		glLightf(nextLightToUse, GL_QUADRATIC_ATTENUATION, slight.attenuation[2]);
		// beamwidth
		float ft = 0.5/(slight.beamWidth +0.1);
		if (ft>128.0) ft=128.0;
		if (ft<0.0) ft=0.0;
		glLightf(nextLightToUse, GL_SPOT_EXPONENT,ft);
	}
	
	/*for (int l=0; l<3; l++) {
		NSLog(@"ambient: %f, diffuse: %f, position: %f", LightAmbient[l], LightDiffuse[l], LightPosition[l]);
	}*/
	
	//NSLog(@"ambient: %f, diffuse: %f", LightAmbient[3], LightDiffuse[3]);
	
	
	//NSLog(@"disegno luce: %d",nextLightToUse);
	glLightfv(nextLightToUse, GL_AMBIENT, LightAmbient);	
	glLightfv(nextLightToUse, GL_DIFFUSE, LightDiffuse);				// Setup The Diffuse Light
	glLightfv(nextLightToUse, GL_POSITION, LightPosition);			// Position The Light
	nextLightToUse++;
}

-(void)setTransformations:(Transform *)transform {
	glPushMatrix();
	if ( transform.translating ) {
		glTranslatef(transform.translation[0], transform.translation[1], transform.translation[2]);
	}
	if ( transform.rotating ) {
		glRotatef(transform.rotation[3] / 3.1415926536 * 180.0, transform.rotation[0], transform.rotation[1], transform.rotation[2]);
	}
	if ( transform.scaling ) {
		glScalef(transform.scale[0], transform.scale[1], transform.scale[2]);
	}
}

-(void)deleteTransformations {
	glPopMatrix();
}


#pragma mark Altri metodi di inizializzazione

- (void)layoutSubviews {
    [EAGLContext setCurrentContext:context];
    [self destroyFramebuffer];
    [self createFramebuffer];
    [self drawView];
}


- (BOOL)createFramebuffer {
    
    glGenFramebuffersOES(1, &viewFramebuffer);
    glGenRenderbuffersOES(1, &viewRenderbuffer);
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
    
    if (USE_DEPTH_BUFFER) {
        glGenRenderbuffersOES(1, &depthRenderbuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
        glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
    }
    
    if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
    
    return YES;
}

- (void)setupView {
	
    const GLfloat zNear = 0.1, zFar = 1000.0, fieldOfView = 60.0;
    GLfloat size;
	
    glEnable(GL_DEPTH_TEST);
    glMatrixMode(GL_PROJECTION);
	
    size = zNear * tanf(DEGREES_TO_RADIANS(fieldOfView) / 2.0);
	
	// This give us the size of the iPhone display
    CGRect rect = self.bounds;
    glFrustumf(-size, size, -size / (rect.size.width / rect.size.height), size / (rect.size.width / rect.size.height), zNear, zFar);
    glViewport(0, 0, rect.size.width, rect.size.height);
	
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);	
}

- (void)destroyFramebuffer {
    
    glDeleteFramebuffersOES(1, &viewFramebuffer);
    viewFramebuffer = 0;
    glDeleteRenderbuffersOES(1, &viewRenderbuffer);
    viewRenderbuffer = 0;
    
    if(depthRenderbuffer) {
        glDeleteRenderbuffersOES(1, &depthRenderbuffer);
        depthRenderbuffer = 0;
    }
}

- (void)startAnimation {
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval target:self selector:@selector(drawView) userInfo:nil repeats:YES];
}

- (void)stopAnimation {
    self.animationTimer = nil;
}

- (void)setAnimationTimer:(NSTimer *)newTimer {
    [animationTimer invalidate];
    animationTimer = newTimer;
}

- (void)setAnimationInterval:(NSTimeInterval)interval {
    
    animationInterval = interval;
    if (animationTimer) {
        [self stopAnimation];
        [self startAnimation];
    }
}

- (void)checkGLError:(BOOL)visibleCheck {
    GLenum error = glGetError();
    
    switch (error) {
        case GL_INVALID_ENUM:
            NSLog(@"GL Error: Enum argument is out of range");
            break;
        case GL_INVALID_VALUE:
            NSLog(@"GL Error: Numeric value is out of range");
            break;
        case GL_INVALID_OPERATION:
            NSLog(@"GL Error: Operation illegal in current state");
            break;
        case GL_STACK_OVERFLOW:
            NSLog(@"GL Error: Command would cause a stack overflow");
            break;
        case GL_STACK_UNDERFLOW:
            NSLog(@"GL Error: Command would cause a stack underflow");
            break;
        case GL_OUT_OF_MEMORY:
            NSLog(@"GL Error: Not enough memory to execute command");
            break;
        case GL_NO_ERROR:
            if (visibleCheck) {
                NSLog(@"No GL Error");
            }
            break;
        default:
            NSLog(@"Unknown GL Error");
            break;
    }
}

#pragma mark dealloc

- (void)dealloc {
    
    [self stopAnimation];
    
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    [context release];  
    [super dealloc];
}

@end
