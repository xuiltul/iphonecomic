#import <UIKit/UIKit.h>
#import "Application.h"

int main(int argc, char **argv)
{
    //NSAutoreleasePool型のポインタpool は、NSAutoreleasePoolを作って、init関数を呼び出して得る。
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    //なにこれ使い捨てにしてんの？ poolなんてどこでも使ってねえじゃん

    //UIApplicationMainを呼び出す。
    //初めのはargc, argv. 3つ目は BooksAppのclassを送っているのか。 classってなんだ。
    return UIApplicationMain(argc, argv, [Application class]);
}


