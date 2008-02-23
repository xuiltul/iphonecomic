#import"Global.h"
#define G  34943

#ifdef MOBILE
	#define DATA_DIR @"/private/var/mobile/Library/iComic/"
	#define COMIC_PREF_PATH "/private/var/mobile/Library/iComic/Pref.dat"
	#define COMIC_PAGE_PATH "/private/var/mobile/Library/iComic/Page.dat"
#else
	#define DATA_DIR @"/private/var/root/Library/iComic/"
	#define COMIC_PREF_PATH "/private/var/root/Library/iComic/Pref.dat"
	#define COMIC_PAGE_PATH "/private/var/root/Library/iComic/Page.dat"
#endif

unsigned crc_code(int, char *);
void InitPrefs();
void RefreshPageData();
void AddPageData(char *);
void InitPageData();
void FindFileRecursively(NSString*);

//iComicに必要な定義情報
int PagesCnt = 0;		//ページデータの情報数
int IsViewingComic = 0;
PrefData prefData;
PageData pageData[MAXBOOKS];
char PagesAccCnt[MAXBOOKS];
char tmpFile[MAXPATHLEN];

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
	//無かった場合は０で新規作成
	dummy.page = dummy.crc = 0;
	return dummy;
}

//ページデータの初期化
void InitPageData()
{
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
	NSArray *tempArray = [[NSArray alloc] 
	initWithArray:[fileManager directoryContentsAtPath:_path]];
	if ([fileManager fileExistsAtPath: _path] == NO) {
		return;
	}

	NSString *file;
	NSEnumerator *dirEnum = [tempArray objectEnumerator];
	while (file = [dirEnum nextObject]){
		file = [_path stringByAppendingString: file];
		if([fileManager fileExistsAtPath:file isDirectory:&isDir] && isDir){
			FindFileRecursively(file);
		}
		else{
			[file getCString: buf maxLength:MAXPATHLEN encoding:NSUTF8StringEncoding];
			AddPageData(buf);
		}
 	}
	[tempArray release];
}

//存在しないZIPファイルのページデータを削除する
void RefreshPageData()
{
	int i = 0 , j = 0;
	for(i = PagesCnt - 1; i >= 0; i--){
		//削除された
		if(PagesAccCnt[i] == 0){
			for(j = i; i < PagesCnt; i++){
				pageData[j] = pageData[j + 1];
				if(pageData[j].crc == 0) break;
			}
			pageData[PagesCnt - 1].crc = pageData[PagesCnt - 1].page = 0;
			PagesCnt--;
		}
	}
}

//ページデータを追加
void AddPageData(char *fname)
{
	int i = 0;
	int crc = crc_code(strlen(fname), fname);

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
	int crc = crc_code(strlen(fname), fname);

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
void InitPrefs()
{
	prefData.Ver=2;
	prefData.IsScroll			= YES;	// バウンズ
	prefData.ScrollSpeed		= 85;	// スクロールの速さ
	prefData.ToScrollRightTop	= YES;	// 次ページで右上に行く
	prefData.ToKeepScale		= YES;	// 拡大率を維持
	prefData.LBtnIsNext			= NO;	// 左ボタンで次のページ
	prefData.HitRange			= 60;	// 角判定の大きさ
	prefData.HideStatusbar		= YES;	// ステータスバー
	prefData.ToFitScreen		= YES;	// リサイズ
	prefData.Rotation			= 0;	// 回転(1-正面, 2-180°, 3-左, 4-右)
	prefData.GravitySlide		= NO;	// 重力ページめくり
	prefData.ButtonSlide		= YES;	// ボタンページめくり
	prefData.SwipeSlide			= YES;	// スワイプページめくり
	prefData.SoundOn			= NO;	// サウンド
	prefData.SlideRight			= YES;	// 右にスライド
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
		InitPrefs();
	}
	//Ver1の場合、Ver2で追加になっている項目を初期化する
	if(prefData.Ver==1){
		prefData.SoundOn			= NO;	// サウンド
		prefData.SlideRight			= YES;	// 右にスライド
	}
	prefData.Ver=2;	//最新版数
}

//定義情報の書き込み
void SavePref()
{
	NSFileManager *myFile = [NSFileManager defaultManager];

	if(![myFile fileExistsAtPath: DATA_DIR])
		[myFile createDirectoryAtPath: DATA_DIR attributes:nil];

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
	if(pfile != 0){
		memset(tmpFile, 0x00, sizeof(tmpFile));
		fread(&i, sizeof(i), 1, pfile);	//パスの長さ
		if(i>0){
			strcpy(tmpFile, COMICPATH2);
			fread(&tmpFile[COMICPATHLEN], i, 1, pfile);
		}
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
	NSFileManager *myFile = [NSFileManager defaultManager];

	if(![myFile fileExistsAtPath: DATA_DIR])
		[myFile createDirectoryAtPath: DATA_DIR attributes:nil];

	int i = 0;
	FILE* pfile = fopen(COMIC_PAGE_PATH, "wb");
	if(pfile != 0){
		i = strlen(tmpFile) - COMICPATHLEN;
		if(i<0) i=0;
		fwrite(&i, sizeof(i), 1, pfile);
		if(i){
			fwrite(&tmpFile[COMICPATHLEN], i, 1, pfile);
		}
		if(pfile == 0) return;
		for(i = 0; i < PagesCnt; i++){
			if(pageData[i].crc == 0) continue;
			fwrite(&pageData[i], sizeof(PageData), 1, pfile);
		}
		fclose(pfile);
	}
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
