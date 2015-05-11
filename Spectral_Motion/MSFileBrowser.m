//
//  MSFileBrowser.m
//  Spectral_Motion
//
//  Created by Kale Evans on 5/11/15.
//  Copyright (c) 2015 Kale Evans. All rights reserved.
//

#import "MSFileBrowser.h"
#import "SharedHeader.h"

@implementation MSFileBrowser


+(NSArray *)getFoldersNamesSavedOnDisk
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString  *pathOfFolders = [NSString stringWithFormat:@"%@/%@", documentsDirectory, FILE_STORAGE_PATH];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *fileList = [manager contentsOfDirectoryAtPath:pathOfFolders error:nil];
    
    if(fileList == nil)
    {
        return nil;
    }
    
    for (NSString *folder in fileList)
    {
        NSLog(@"Folder Named %@ Found", folder);
    }
    
    return fileList;
}
@end
