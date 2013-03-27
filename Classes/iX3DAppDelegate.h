#import <UIKit/UIKit.h>

@class EAGLView;

@interface iX3DAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    EAGLView *glView;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet EAGLView *glView;

//@property (nonatomic, retain) X3DNode *root;

@end

