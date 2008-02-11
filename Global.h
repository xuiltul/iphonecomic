#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#define UITEXTLEN 1000

#ifdef MOBILE
	#define COMICPATH2 "/var/mobile/Media/Comic/"
#else
	#define COMICPATH2 "/var/root/Media/Comic/"
#endif

#define COMICPATH @COMICPATH2
#define COMICPATHLEN 22
#define MAXPATHLEN 512
#define MAXBOOKS 1000
#define SCSTSBAR 20			//ステータスバーの高さ

#ifdef MOBILE
	#define COMICVER @"iComic v0.8m"
#else
	#define COMICVER @"iComic v0.8r"
#endif

#define SOUND_CLICK if(prefData.SoundOn) AudioServicesPlaySystemSound(1105)

//#define MAKEUITEXT(a) [NSString stringWithCString: UIText[a] encoding:NSUTF8StringEncoding]

//
//iComicに必要な環境定義、コミック情報を保存する
//

//ページデータ。あるZIPファイルを読んだかどうかを保存する
typedef struct PageDataS{
	int crc;	//ファイルを表すCRC
	int page;	//-2:未読、-1:完了、0～:読中
}PageData;

//環境定義を保存する
typedef struct PrefDataS{
	int		Ver;
//v1
	BOOL	IsScroll;			//Bounce
	int		ScrollSpeed;		//Scroll speed
	BOOL	ToScrollRightTop;	//Move to top right
	BOOL	ToKeepScale;		//Keep scale
	BOOL	LBtnIsNext;			//Left button is next
	int		HitRange;			//Button size
	BOOL	ToFitScreen;		//Fit Screen
	BOOL	HideStatusbar;		//Hide status bar
	int		Rotation;			//Rotation
	BOOL	GravitySlide;		//Gravity page slide
	BOOL	ButtonSlide;		//Button page slide
	BOOL	SwipeSlide;			//Swipe page slide
//v2
	BOOL	SoundOn;			//Sound On
	BOOL	SlideRignt;			//Slide to right
}PrefData;

extern PrefData prefData;
extern PageData pageData[];
extern char tmpFile[];
extern int IsViewingComic;

extern PageData GetPageData(char *);
extern void SetPageData(char* fname, int page);

extern void SavePref();
extern void LoadPref();
extern void SavePage();
extern void LoadPage();

extern void debug_log(char *);
