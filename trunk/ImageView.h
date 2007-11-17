
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIProgressIndicator.h>
#import "zlib/unzip.h"
#import "ScrollImage.h"

@interface ImageView : UIView
{
	ScrollImage* _scroller1;
	ScrollImage* _scroller2;
	ScrollImage* _currentscroll;
	unzFile zipfile; // pointer
	NSMutableArray *filenamelist;
	unsigned int _currentpos;
	float _currentsize;
	CGSize _imagesize;
	UITransitionView *_transition;
	char _filenamebuf[512];
	id _fileDelegate;
	int _orient;
	bool toResize;
//	UIProgressIndicator * _progressIndicator;
}


-(void) setFile : (NSString*) fname;
-(void) nextFile;
-(void) prevFile;
-(void) dofileEnd;
-(int) reloadFile;
-(void) setPage : (int) page;
-(void) setFileDelegate: (id) dele;
-(void) fitImage;
-(void) setOrientation: (int) orientation;
-(void) setScroll:(BOOL) flag decelerationFactor:(float)dec;
@end

