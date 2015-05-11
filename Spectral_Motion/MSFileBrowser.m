//
//  MSFileBrowser.m
//  Spectral_Motion
//
//  Created by Kale Evans on 5/11/15.
//  Copyright (c) 2015 Kale Evans. All rights reserved.
//

#import "MSFileBrowser.h"
#import "SharedHeader.h"
#import "NSString+MSString.h"

@implementation MSFileBrowser


+(NSArray *)getFoldersNamesSavedOnDisk
{
   // NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //iOS 8 Change
   NSString *documentsDirectory = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] path];
    
    NSString  *pathOfFolders = [NSString stringWithFormat:@"%@/%@", documentsDirectory, FILE_STORAGE_PATH];
    NSLog(@"folders path %@", pathOfFolders);
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *fileList = [manager contentsOfDirectoryAtPath:pathOfFolders error:&error];
    
    if(fileList == nil)
    {
        NSLog(@"file list on disk is empty");
        NSLog(@"Error desc: %@", error.description);
        return nil;
    }
    
    if(fileList.count == 0)
    {
        NSLog(@"Direcotry exists, but has no contents");
    }
    
    for (NSString *folder in fileList)
    {
        NSLog(@"Folder Named %@ Found", folder);
    }
    
    return fileList;
}

+(NSString *) getFolderPathForFileName:(NSString *) fileName;
{
    //name passed here is name with all but last extension
    
    NSString *documentsDirectory = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] path];
    
   // NSString *folderName = [NSString createFolderNameFromFileName:fileName];
    
    NSString  *filePath = [NSString stringWithFormat:@"%@/%@/%@", documentsDirectory, FILE_STORAGE_PATH, fileName];
    
    return filePath;
    
}

+(NSString *) getFullFilePathForFileName:(NSString *) fileName
{
    NSString *documentsDirectory = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] path];

     NSString *folderName = [NSString createFolderNameFromFileName:fileName];
    
    NSString  *filePath = [NSString stringWithFormat:@"%@/%@/%@/%@", documentsDirectory, FILE_STORAGE_PATH, folderName, fileName];

    return filePath;
    
}

@end
