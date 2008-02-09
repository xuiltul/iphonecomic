#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIProgressIndicator.h>
#import "zlib/unzip.h"
#import "ScrollImage.h"

@interface ImageView : UIView
{
	ScrollImage*	_scroller1;
	ScrollImage*	_scroller2;
	ScrollImage*	_currentscroll;
	unzFile			zipfile;			// pointer
	NSMutableArray*	filenamelist;		//ZIP内のファイル名一覧
	unsigned int	_currentpos;		//表示イメージのページ番号
	float			_currentsize;		//ズーム倍率
	CGSize			_imagesize;			//イメージサイズ
	UIImage*		_nowimage;			//表示イメージ
	UITransitionView*	_transition;	//アニメーション？
	char			_filenamebuf[512];	//ZIPファイルパス
	id				_fileDelegate;		//
	int				_orient;			//回転角度
	bool			toResize;			//リサイズON/OFF
//	UIProgressIndicator * _progressIndicator;
}


-(void) setFile : (NSString*) fname;
-(void) nextFile;
-(void) prevFile;
-(void) dofileEnd;
-(int)  reloadFile;
-(void) setPage : (int) page;
-(void) setImageDelegate: (id) dele;
-(void) fitImage;
-(void) setOrientation: (int) orientation;
-(void) setScroll:(BOOL) flag decelerationFactor:(float)dec;
-(void) gravity: (float)x  gy:(float) y gz:(float)z;

@end

