#import"Global.h"
#define G  34943

#define DATA_DIR		@"/private/var/mobile/Library/iComic/"
#define COMIC_PREF_PATH	"/private/var/mobile/Library/iComic/Pref.dat"
#define COMIC_STAT_PATH	"/private/var/mobile/Library/iComic/Stat.dat"
#define COMIC_PAGE_PATH	"/private/var/mobile/Library/iComic/Page.dat"
#define COMIC_PSYS_PATH	"/Applications/iComic.app/Psys.dat"

void MakeLibDir();
unsigned crc_code(int, char *);
void InitPref();
void InitStat();
void RefreshPageData();
void AddPageData(char *,int);
void InitPageData();
void FindFileRecursively(NSString*);

//iComicに必要な定義情報
int PagesCnt;		//ページデータの情報数

PrefData prefData;
StatData statData;
PsysData psysData;
PageData pageData[MAXBOOKS];
char PagesAccCnt[MAXBOOKS];
char tmpFile[MAXPATHLEN];
BOOL isShowImage;
char tmpLastFile[MAXPATHLEN];

//定義情報格納ディレクトリ作成
void MakeLibDir(void)
{
	NSFileManager *myFile = [NSFileManager defaultManager];

//NSLog(@"MakeLibDir");
//
	if(![myFile fileExistsAtPath: DATA_DIR])
		[myFile createDirectoryAtPath: DATA_DIR attributes:nil];
}

//CRCコードの生成
unsigned crc_code(int len, char *data)
{
    int i;
    unsigned d;
    unsigned bit;
    unsigned crc;
    d = 0;
    while (len-- > 0) d = ((d << 8) + *data++) % G;
    crc = 0;
    if ((d = (d << 16) % G) > 0) {
        for (i = 0, bit = 1; i < 16; i++, bit <<= 1) {
            if (((d + crc) ^ G) & bit) crc |= bit;
        }
    }
    return crc;
}

//ファイル名からページデータを取得する
PageData GetPageData(char *fname)
{
	static PageData dummy;
	int i = 0;
	int crc = crc_code(strlen(fname), fname);	//CRCを算出

	for(i = 0; i < PagesCnt; i++){
		//該当データがあった場合はページデータを返す
		if(pageData[i].crc == crc){
			return pageData[i];
		}
	}
	//無かった場合は新規作成
	dummy.crc = 0;
	dummy.page = -2;
	return dummy;
}

//ページデータの初期化
void InitPageData()
{
	memset( PagesAccCnt, 0x00, sizeof(PagesAccCnt) );
	FindFileRecursively(COMICPATH);
	RefreshPageData();
}

//全てのZIPファイルを検索して、ページデータを作成する
void FindFileRecursively(NSString* _path)
{
	BOOL isDir;
	char buf[MAXPATHLEN];

	if([_path characterAtIndex: [_path length] - 1] != '/'){
		_path = [_path stringByAppendingString: @"/"];
	}

	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *tempArray = [[NSArray alloc] initWithArray:[fileManager directoryContentsAtPath:_path]];
	if ([fileManager fileExistsAtPath: _path] == NO) {
		return;
	}

	NSString *file;
	NSEnumerator *dirEnum = [tempArray objectEnumerator];
	while (file = [dirEnum nextObject]){
		file = [_path stringByAppendingString: file];
		[file getCString: buf maxLength:MAXPATHLEN encoding:NSUTF8StringEncoding];

		int crc = crc_code(strlen(buf), buf);

		if([fileManager fileExistsAtPath:file isDirectory:&isDir] && isDir){
			FindFileRecursively(file);
		}
		else if( [[file pathExtension] compare:@"zip" options:NSCaseInsensitiveSearch] == NSOrderedSame ){
			AddPageData(buf, crc);
		}
//		else{
//NSLog(@"skip buf=%s", buf);
//		}
		if( crc == statData.ReadFile ){
			strcpy(tmpFile, buf);
		}
 	}
	[tempArray release];
//
//NSLog(@"tmpFile=%s", tmpFile);
}

//存在しないZIPファイルのページデータを削除する
void RefreshPageData()
{
	int i = 0 , j = 0;

	for(i = PagesCnt - 1; i >= 0; i--){
		//削除された
		if(PagesAccCnt[i] == 0){
			for(j = i; j < PagesCnt; j++){
				pageData[j] = pageData[j + 1];
				if(pageData[j].crc == 0) break;
			}
			pageData[PagesCnt - 1].crc = pageData[PagesCnt - 1].page = 0;
			PagesCnt--;
		}
	}
}

//ページデータを追加
//void AddPageData(char *fname)
void AddPageData(char *fname, int crc)
{
	int i = 0;

//NSLog(@"AddPageData crc=%d, ReadFile=%d", crc, statData.ReadFile);

	if(crc == 0) return;
	for(i = 0; i < MAXBOOKS; i++){
		if(pageData[i].crc == 0 ) break;
		if(pageData[i].crc == crc){
			PagesAccCnt[i] = 1;
			return;
		}
	}
	if(PagesCnt == MAXBOOKS) return;
	
	//追加
	pageData[PagesCnt].crc = crc;
	pageData[PagesCnt].page = -2;
	PagesAccCnt[PagesCnt] = 1;
	PagesCnt++;

	return;
}

//ページデータを保存
void SetPageData(char* fname, int page)
{
	int i = 0;
	int crc = crc_code(strlen(tmpFile), tmpFile);

	for(i = 0; i < PagesCnt; i++){
		if(pageData[i].crc == crc){
			pageData[i].page = page;
			return;
		}
	}
	if(crc == 0) return;
	pageData[PagesCnt].crc = crc;
	pageData[PagesCnt].page = page;
	PagesCnt++;
	return;
}

//定義の初期設定
void InitPref()
{
	prefData.Ver=5;
	prefData.IsNextZip			= YES;	// 次のZIPを表示
	prefData.ScrollSpeed		= 85;	// スクロールの速さ
	prefData.ToScrollRightTop	= YES;	// 次ページで右上に行く
	prefData.ToKeepScale		= YES;	// 拡大率を維持
	prefData.LBtnIsNext			= NO;	// 左ボタンで次のページ
	prefData.HitRange			= 60;	// ボタンの大きさ
	prefData.HideStatusbar		= YES;	// ステータスバー
	prefData.ToFitScreen		= YES;	// リサイズ
	prefData.Rotation			= 0;	// 回転(1-正面, 2-180°, 3-左, 4-右)
	prefData.GravitySlide		= NO;	// 重力ページめくり
	prefData.ButtonSlide		= YES;	// ボタンページめくり
	prefData.SwipeSlide			= YES;	// スワイプページめくり
	prefData.SoundOn			= NO;	// サウンド
	prefData.SlideRight			= YES;	// 右にスライド
	prefData.MaxScale			= 4;	// 最大倍率
	prefData.ButtonIgnore		= 10;	// ボタン感度
	prefData.ReloadScreen		= YES;	// 画面再読込み
}

//定義情報の読み込み
void LoadPref()
{
	FILE *pfile = fopen(COMIC_PREF_PATH, "rb");
	if(pfile != 0){
		fread(&prefData, sizeof(prefData), 1, pfile);
		fclose(pfile);
	}
	//ファイルが無い場合は初期化する
	else{
		memset(&prefData, 0x00, sizeof(prefData));
		InitPref();
	}
	//Ver1の場合、Ver2で追加になっている項目を初期化する
	if(prefData.Ver<=1){
		prefData.SoundOn			= NO;	// サウンド
		prefData.SlideRight			= YES;	// 右にスライド
	}
	if(prefData.Ver<=2){
		prefData.MaxScale			= 4;	// 最大倍率
		prefData.ButtonIgnore		= 10;	// ボタン感度
	}
	if(prefData.Ver<=3){
		prefData.ReloadScreen		= YES;	// 画面再読込み
	}
	if(prefData.Ver<=4){
		prefData.IsNextZip			= YES;	// 次のZIPを表示
	}
	prefData.Ver=5;	//最新版数
}

//定義情報の書き込み
void SavePref()
{
	MakeLibDir();

	FILE* pfile = fopen(COMIC_PREF_PATH, "wb");
	if(pfile != 0){
		fwrite(&prefData, sizeof(prefData), 1, pfile);
		fclose(pfile);
	}
}

//ページデータの読み込み
void LoadPage()
{
	int i = 0;
	FILE *pfile = fopen(COMIC_PAGE_PATH, "rb");
	PagesCnt=0;

	memset(pageData, 0x00, sizeof(pageData));
	if(pfile != 0){
		while(feof(pfile) == 0){
			fread(&pageData[PagesCnt], sizeof(PageData), 1, pfile);
			if(feof(pfile) != 0) break;
			PagesCnt++;
		}
		fclose(pfile);
	}
	//ファイルが無い場合は初期化する
	else{
		memset(pageData, 0x00, sizeof(pageData));
		memset(tmpFile, 0x00, sizeof(tmpFile));
	}
	InitPageData();
}

//ページデータの書き込み
void SavePage()
{
	MakeLibDir();

	int i = 0;
	FILE* pfile = fopen(COMIC_PAGE_PATH, "wb");
	if(pfile != 0){
		if(pfile == 0) return;
		for(i = 0; i < PagesCnt; i++){
			if(pageData[i].crc == 0) continue;
			fwrite(&pageData[i], sizeof(PageData), 1, pfile);
		}
		fclose(pfile);
	}
}

//状態の初期設定
void InitStat(void)
{
	statData.Ver = 1;
	statData.ReadFile = -1;
	statData.ShowView = BWZ_VIEW;
	statData.BefView = BWZ_VIEW;
	statData.ZoomRate = 1.0f;
	statData.offset = CGPointZero;
}

//最後の状態の読み込み
void LoadStat()
{
	FILE *pfile = fopen(COMIC_STAT_PATH, "rb");
	if(pfile != 0){
		fread(&statData, sizeof(statData), 1, pfile);
		fclose(pfile);
	}
	//ファイルが無い場合は初期化する
	else{
		memset(&statData, 0x00, sizeof(statData));
		InitStat();
	}
	//Ver1の場合、Ver2で追加になっている項目を初期化する
	if(statData.Ver<=1){
		statData.BefView = BWZ_VIEW;
		statData.ZoomRate = 1.0f;
	}
	if(statData.Ver<=2){
		statData.offset = CGPointZero;
	}
	statData.Ver=3;	//最新版数
//NSLog(@"LoadStat ReadFile=%d", statData.ReadFile);
}

//最後の状態の書き込み
void SaveStat()
{
	MakeLibDir();
	
	if( strlen(tmpFile) > 0 ){
		statData.ReadFile = crc_code(strlen(tmpFile), tmpFile);
	}
	FILE* pfile = fopen(COMIC_STAT_PATH, "wb");
	if(pfile != 0){
		fwrite(&statData, sizeof(statData), 1, pfile);
		fclose(pfile);
	}
}

//システム設定の読み込み
void LoadPsys()
{
	char psystmp[23];

	FILE *pfile = fopen(COMIC_PSYS_PATH, "rb");
	if(pfile != 0){
		fread(psystmp, sizeof(psystmp), 1, pfile);
		fclose(pfile);
	}
	//ファイルが無い場合は初期化する
	else{
		strcpy(psystmp, "05 1024 5120 1400 1200");
	}
	psystmp[2] = 0x00;
	psystmp[7] = 0x00;
	psystmp[12] = 0x00;
	psystmp[17] = 0x00;
	psystmp[22] = 0x00;
	
	psysData.ZoomScale = atof(&psystmp[0])*(0.001f);	//ズーム増加率
	psysData.ZipSkipSize = atoi(&psystmp[3])*1024;		//ZIPファイルスキップサイズ
	psysData.ImgSkipSize = atoi(&psystmp[8])*1024;		//イメージスキップサイズ
	psysData.ImgSkipLen = atof(&psystmp[13]);			//イメージスキップ長
	psysData.ImgResizeLen = atof(&psystmp[18]);		//イメージリサイズ長
//NSLog(@"psysData.ZoomScale=%f", psysData.ZoomScale);
//NSLog(@"psysData.ZipSkipSize=%i", psysData.ZipSkipSize);
//NSLog(@"psysData.ImgSkipSize=%i", psysData.ImgSkipSize);
//NSLog(@"psysData.ImgSkipLen=%f", psysData.ImgSkipLen);
//NSLog(@"psysData.ImgResizeLen=%f", psysData.ImgResizeLen);
}

//デバッグログ
void debug_log(char *log_data)
{
#if 0
	FILE* pfile = fopen("/Applications/iComic.app/Debug.log", "a");
	if(log_data==0x00) return;
	if(log_data[0]==0x00) return;
	if(pfile != 0){
		fwrite(log_data, strlen(log_data), 1, pfile);
		fclose(pfile);
	}
#endif
}
