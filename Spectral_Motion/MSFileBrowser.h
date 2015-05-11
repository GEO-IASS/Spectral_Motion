//
//  MSFileBrowser.h
//  Spectral_Motion
//
//  Created by Kale Evans on 5/11/15.
//  Copyright (c) 2015 Kale Evans. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSFileBrowser : NSObject

+(NSArray *) getFoldersNamesSavedOnDisk;

+(NSString *) getFolderPathForFileName:(NSString *) fileName;

+(NSString *) getFullFilePathForFileName:(NSString *) fileName;

@end
