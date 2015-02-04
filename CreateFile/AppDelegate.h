//
//  AppDelegate.h
//  CreateFile
//
//  Created by highcom on 14-12-29.
//  Copyright (c) 2014年 zhanglei. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h> 
@interface AppDelegate : NSObject <NSApplicationDelegate,NSXMLParserDelegate>
//解析出得数据，内部是字典类型
@property (strong,nonatomic) NSMutableArray * notes ;

// 当前标签的名字 ,currentTagName 用于存储正在解析的元素名
@property (strong ,nonatomic) NSString * currentTagName ;

@property (strong ,nonatomic) NSString * createType;

//开始解析
- (void) start:(NSString *)filePath;
@end

