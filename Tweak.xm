#import "UIImage+AverageColor.m"
#import <QuartzCore/QuartzCore.h>
#import <LIFXKit/LIFXKit.h>
#include <sys/time.h>
#import <notify.h>

BOOL _isRunning = YES;
int notifyToken;
UIColor *color;
NSTimer *t;

@interface SpringBoard: NSObject

@end

@interface SpringBoard (lifx)

-(void)onTickLIFX:(NSTimer *)timer;
-(void)createLIFX;
-(void)destroyLIFX;

@end

%hook SpringBoard

%new
-(void)onTickLIFX:(NSTimer *)timer {
	UIView *topView = [[[[UIApplication sharedApplication] keyWindow] subviews] lastObject];

	UIGraphicsBeginImageContextWithOptions(topView.bounds.size, topView.opaque, 0.0);
  [topView.layer renderInContext:UIGraphicsGetCurrentContext()];
  UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

	color = [img averageColor];
}

%new
-(void)createLIFX {
	if(_isRunning) {
		t = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(onTick:) userInfo: nil repeats:YES];
	}
}

%new
-(void)destroyLIFX {
	if(!_isRunning) {
		[t invalidate];
		[t release];
	}
}

-(void)applicationDidFinishLaunching:(id)application {
	%orig;
	notify_register_dispatch("com.apple.springboard.hasBlankedScreen", &notifyToken, dispatch_get_main_queue(),
																			^(int t) {
                                          uint64_t state;
                                          int result = notify_get_state(notifyToken, &state);
                                          result = nil;
                                          NSLog(@"lock state change = %llu", state); //1 = locked. 0 = unlocked.
                                          if (state == 1) {
                                          	_isRunning = NO;
																						[self destroyLIFX];
                                          } else {
                                          	_isRunning = YES;
                                          	[self createLIFX];
                                          }
                                      });
}

%end
