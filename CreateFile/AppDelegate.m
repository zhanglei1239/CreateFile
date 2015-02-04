//
//  AppDelegate.m
//  CreateFile
//
//  Created by highcom on 14-12-29.
//  Copyright (c) 2014年 zhanglei. All rights reserved.
//

#import "AppDelegate.h"
#import <libxml2/libxml/parser.h>
@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}
-(NSString *)getFilePath{
    NSString *homePath=NSHomeDirectory();
    NSLog(@"%@",homePath);
    NSString *filePath=[homePath stringByAppendingFormat:@"/Desktop/humam.xml"];
    return  filePath;
}
- (IBAction)createmFile:(id)sender {
    self.createType = @"m";
    [self start:[self getFilePath]];
}

- (IBAction)createhFile:(id)sender {
    self.createType = @"h";
    [self start:[self getFilePath]];
}
// 开始解析
-(void)start:(NSString *)filePath{
    NSURL * url = [NSURL fileURLWithPath:filePath];
    
    //开始解析 xml
    NSXMLParser * parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    parser.delegate = self ;
    
    [parser parse];
    
    NSLog(@"解析搞定...");
    
}
//文档开始时触发 ,开始解析时 只触发一次
-(void)parserDidStartDocument:(NSXMLParser *)parser{
    _notes = [NSMutableArray new];
}

// 文档出错时触发
-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
    NSLog(@"%@",parseError);
}

//遇到一个开始标签触发
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    
    //把elementName 赋值给 成员变量 currentTagName
    _currentTagName  = elementName ;
    
    //如果名字 是Note就取出 id
    if ([_currentTagName isEqualToString:@"file"]) {
        
        NSString * _id = [attributeDict objectForKey:@"filename"];
        NSString * superclass = [attributeDict objectForKey:@"superClass"];
        NSString * delegate = [attributeDict objectForKey:@"delegate"];
        // 实例化一个可变的字典对象,用于存放
        NSMutableDictionary *dict = [NSMutableDictionary new];
        //把id 放入字典中
        [dict setObject:_id forKey:@"filename"];
        [dict setObject:superclass forKey:@"superClass"];
        [dict setObject:delegate forKey:@"delegate"];
        // 把可变字典 放入到 可变数组集合_notes 变量中
        [_notes addObject:dict];
        
    }
    
}

#pragma mark 该方法主要是解析元素文本的主要场所，由于换行符和回车符等特殊字符也会触发该方法，因此要判断并剔除换行符和回车符
// 遇到字符串时 触发
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    //替换回车符 和空格,其中 stringByTrimmingCharactersInSet 是剔除字符的方法,[NSCharacterSet whitespaceAndNewlineCharacterSet]指定字符集为换行符和回车符;
    
    string  = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([string isEqualToString:@""]) {
        return;
    }
    
    NSMutableDictionary * dict = [_notes lastObject];
    if ([_currentTagName isEqualToString:@"copyright"] && dict) {
        [dict setObject:string forKey:@"copyright"];
    }
    
    if ([_currentTagName isEqualToString:@"import"] && dict) {
        [dict setObject:string forKey:@"import"];
    }
    
    if ([_currentTagName isEqualToString:@"importclass"] && dict) {
        [dict setObject:string forKey:@"importclass"];
    }
    
    if ([_currentTagName isEqualToString:@"var"] && dict) {
        [dict setObject:string forKey:@"var"];
    }
    
    if ([_currentTagName isEqualToString:@"function"] && dict) {
        [dict setObject:string forKey:@"function"];
    }
}

//遇到结束标签触发
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    self.currentTagName = nil ;
    //该方法主要是用来 清理刚刚解析完成的元素产生的影响，以便于不影响接下来解析
}

// 遇到文档结束时触发
-(void)parserDidEndDocument:(NSXMLParser *)parser{
    for (int i = 0; i<self.notes.count; i++) {
        NSDictionary * dic = [self.notes objectAtIndex:i];
        [self createFileWithData:dic];
    }
}

-(void)createFileWithData:(NSDictionary *)dic{
//第一部分 设置文件注释
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yy-MM-dd"];
    //用[NSDate date]可以获取系统当前时间
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter setDateFormat:@"yyyy"];
    NSString *curDateStr = [dateFormatter stringFromDate:[NSDate date]];
    
    NSArray * nameArr = [[dic objectForKey:@"copyright"] componentsSeparatedByString:@","];
    
    NSString * content = [NSString stringWithFormat:@"// %@.%@  \n// CreateFile \n// \n// Created by %@ on %@.\n// Copyright (c) %@ %@. All rights reserved.\n\n",[dic objectForKey:@"filename"],self.createType,[nameArr objectAtIndex:1],currentDateStr,curDateStr,[nameArr objectAtIndex:0]];
    
    if ([self.createType isEqualToString:@"h"]) {
        //第二部分 文件引入 import
        NSArray * importArr = [[dic objectForKey:@"import"] componentsSeparatedByString:@" "];
        for (NSString * string in importArr) {
            NSArray * array = [string componentsSeparatedByString:@"/"];
            if ([array count]>1) {
                content = [content stringByAppendingString:[NSString stringWithFormat:@"\n#import <%@>",string]];
            }else{
                content = [content stringByAppendingString:[NSString stringWithFormat:@"\n#import \"%@\"",string]];
            }
        }
        content = [content stringByAppendingString:@"\n"];
        
        NSArray * importClass = [[dic objectForKey:@"importclass"] componentsSeparatedByString:@","];
        for (NSString * string in importClass) {
            content = [content stringByAppendingString:[NSString stringWithFormat:@"\n@class %@;",string]];
        }
        
        //第三部分 interface定义类
        //    @interface AppDelegate : NSObject <NSApplicationDelegate,NSXMLParserDelegate>
        
        NSString * delegate =  @"";
        NSArray * delegateArr = [[dic objectForKey:@"delegate"] componentsSeparatedByString:@","];
        int count = 0;
        for (NSString * dele in delegateArr) {
            if (count == 0) {
                delegate = [delegate stringByAppendingString:[NSString stringWithFormat:@"%@",dele]];
            }else{
                delegate = [delegate stringByAppendingString:[NSString stringWithFormat:@",%@",dele]];
            }
            count++;
        }
        content = [content stringByAppendingString:[NSString stringWithFormat:@"\n@interface %@ : %@<%@>{\n}",[dic objectForKey:@"filename"],[dic objectForKey:@"superClass"],delegate]];
        
        content =  [content stringByReplacingOccurrencesOfString:@"<>" withString:@"\n"];
        
        //第四部分 变量定义
        //    @property (strong ,nonatomic) NSString * createType;
        NSArray * varArr = [[dic objectForKey:@"var"] componentsSeparatedByString:@","];
        for (NSString * string in varArr) {
            NSArray * array =  [string componentsSeparatedByString:@" "];
            NSString * type = [array objectAtIndex:0];
            NSString * name = [array objectAtIndex:1];
            if ([type isEqualToString:@"NSString"]) {
                content = [content stringByAppendingString:[NSString stringWithFormat:@"\n@property (copy,nonatomic) %@ * %@;",type, name]];
            }
            else if([self containKey:type]||[name isEqualToString:@"delegate"]){
                content = [content stringByAppendingString:[NSString stringWithFormat:@"\n@property (assign,nonatomic) %@ %@;",type, name]];
            }else{
                 content = [content stringByAppendingString:[NSString stringWithFormat:@"\n@property (retain,nonatomic) %@ * %@;",type, name]];
            }
        }
        
        //第五部分 方法定义
        //    - (void) start:(NSString *)filePath;
        NSArray * funArr = [[dic objectForKey:@"function"] componentsSeparatedByString:@","];
        for (NSString * string in funArr) {
            content = [content stringByAppendingString:[NSString stringWithFormat:@"\n%@;",string]];
        }
        
        //第六部分 @end
        content = [content stringByAppendingString:@"\n@end"];
        NSLog(@"content:\n%@",content);

    }else{
        if ([[dic objectForKey:@"superClass"] isEqualToString:@"NSObject"]) {
            content = [content stringByAppendingString:[NSString stringWithFormat:@"\n#import \"%@.h\"\n",[dic objectForKey:@"filename"]]];
            content = [content stringByAppendingString:[NSString stringWithFormat:@"\n@implementation %@\n",[dic objectForKey:@"filename"]]];
            content = [content stringByAppendingString:[NSString stringWithFormat:@"\n@end\n"]];
            
        }else if([[dic objectForKey:@"superClass"] isEqualToString:@"UIViewController"]){
            content = [content stringByAppendingString:[NSString stringWithFormat:@"\n#import \"%@.h\"\n",[dic objectForKey:@"filename"]]];
            content = [content stringByAppendingString:[NSString stringWithFormat:@"\n@interface %@()\n",[dic objectForKey:@"filename"]]];
            content = [content stringByAppendingString:@"\n@end\n"];
            content = [content stringByAppendingString:[NSString stringWithFormat:@"\n@implementation %@\n",[dic objectForKey:@"filename"]]];
            content = [content stringByAppendingString:[NSString stringWithFormat:@"\n\n- (void) viewDidLoad {\n  [super ViewDidLoad];\n  //TODO\n}\n"]];
            content = [content stringByAppendingString:[NSString stringWithFormat:@"\n\n- (void) didReceiveMemoryWarning {\n  [super didReceiveMemoryWarning];\n  //TODO\n}\n"]];
            
            content = [content stringByAppendingString:[NSString stringWithFormat:@"\n@end"]];
            
        }
         NSLog(@"content:\n%@",content);
    }
//    NSString *homePath=NSHomeDirectory();
//    NSString * path = [NSString stringWithFormat:@"/Desktop/%@.%@",[dic objectForKey:@"filename"],self.createType];
//    NSString *filePath=[homePath stringByAppendingString:path];
//    NSFileManager * manager = [NSFileManager defaultManager];
//    if (![manager fileExistsAtPath:filePath]) {
//        [manager createFileAtPath:filePath contents:nil attributes:nil];
//    }
//    
//    NSFileHandle *fileHandle=[NSFileHandle fileHandleForUpdatingAtPath:filePath];
//    [fileHandle seekToEndOfFile];
//    NSData * date =[content dataUsingEncoding:NSUTF8StringEncoding];
//    [fileHandle writeData:date];
//    
//    [fileHandle closeFile];
}

-(BOOL)containKey:(NSString * )key{
    NSString * basicVar = @"int,short int,long,char,float,double,bool";
    NSArray * arr = [basicVar componentsSeparatedByString:@","];
    for (NSString * type in arr) {
        if ([type isEqualToString:key]) {
            return  YES;
        }
    }
    return NO;
}
@end
