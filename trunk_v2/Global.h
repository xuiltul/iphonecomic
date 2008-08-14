#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
//#define UITEXTLEN 1000
#define COMICVER @"iComic"

#ifdef MOBILE
	#define COMICPATH2 "/var/mobile/Media/Comic/"
	#define COMICPATHLEN 24
#else
	#define COMICPATH2 "/var/root/Media/Comic/"
	#define COMICPATHLEN 22
#endif

#define COMICPATH @COMICPATH2
#define MAXPATHLEN 512
#define MAXBOOKS 1000
//#define MAXLIST	30
#define STSBAR	20			//ステータスバーの高さ
#define NAVBAR	44
#define BTNBAR	49

#define SOUND_CLICK if(prefData.SoundOn) AudioServicesPlaySystemSound(1105)

#define NEXT_PAGE 1
#define PREV_PAGE 2
#define RELD_PAGE 3
#define EXIT_PAGE 4

//#define MAKEUITEXT(a) [NSString stringWithCString: UIText[a] encoding:NSUTF8StringEncoding]

//
//iComicに必要な環境定義、コミック情報を保存する
//

typedef enum ViewTypeE{
	MAIN_VIEW = 0,
	BWZ_VIEW,	//1
	ZIP_VIEW,	//2
	IMG_VIEW,	//3
	PAG_VIEW	//4
}ViewType;

//ページデータ。あるZIPファイルを読んだかどうかを保存する
typedef struct PageDataS{
	int crc;	//ファイルを表すCRC
	int page;	//-2:未読、-1:完了、0～:読中
}PageData;

//環境定義を保存する
typedef struct PrefDataS{
	int		Ver;
//v1
	BOOL	IsNextZip;			//Next Zip
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
	BOOL	SlideRight;			//Slide to right
//v3
	int		MaxScale;			//Max Scale
	int		ButtonIgnore;		//Button Ignore
//v4
	BOOL	ReloadScreen;		//Reload Screen
//v5
//	isNextZip;
}PrefData;

//最後の状態を保存する
typedef struct StatDataS{
	int			Ver;
//v1
	int			ReadFile;
	ViewType	ShowView;
//v2
	ViewType	BefView;
	float		ZoomRate;
//v3
	CGPoint		offset;
}StatData;

//システム設定を保存する
typedef struct PsysDataS{
	float		ZoomScale;		//ズーム増加率
	long		ZipSkipSize;	//ZIPファイルスキップサイズ
	long		ImgSkipSize;	//イメージスキップサイズ
	float		ImgSkipLen;		//イメージスキップ長
	float		ImgResizeLen;	//イメージリサイズ長
}PsysData;

extern PrefData prefData;
extern StatData statData;
extern PsysData psysData;
extern PageData pageData[];
extern char tmpFile[];
extern int PagesCnt;
extern BOOL isShowImage;
extern char tmpLastFile[];

extern PageData GetPageData(char *);
extern void SetPageData(char* fname, int page);

extern void SavePref();
extern void LoadPref();
extern void SavePage();
extern void LoadPage();
extern void SaveStat();
extern void LoadStat();
extern void LoadPsys();

extern void debug_log(char *);
