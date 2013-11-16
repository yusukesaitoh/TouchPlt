//
//  DebugLog.h
//  TouchPlt
//
//  Created by Yusuke Saitoh on 2013/11/07.
//  Copyright (c) 2013年 Yusuke Saitoh. All rights reserved.
//

#ifndef TouchPlt_DebugLog_h
#define TouchPlt_DebugLog_h

#ifdef DEBUG
#define DLog(fmt, ...) NSLog((@"%s " fmt), __PRETTY_FUNCTION__, ##__VA_ARGS__);
#define DLogInfo NSLog(@"%s [Line %d]", __PRETTY_FUNCTION__, __LINE__);
#else
#define DLog(...)
#define DLogInfo
#endif

#endif
