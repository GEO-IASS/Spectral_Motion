//
//  NSString+MSString.m
//  Spectral Motion
//
//  Created by Kale Evans on 12/23/14.
//  Copyright (c) 2014 Kale Evans. All rights reserved.
//

#import "NSString+MSString.h"

@implementation NSString (MSString)

- (NSString*) stringBetweenString:(NSString*)start andString:(NSString*)end {
    NSRange startRange = [self rangeOfString:start];
    if (startRange.location != NSNotFound) {
        NSRange targetRange;
        targetRange.location = startRange.location + startRange.length;
        targetRange.length = [self length] - targetRange.location;
        NSRange endRange = [self rangeOfString:end options:0 range:targetRange];
        if (endRange.location != NSNotFound) {
            targetRange.length = endRange.location - targetRange.location;
            return [self substringWithRange:targetRange];
        }
    }
    return nil;
}

+(NSString *)createFolderNameFromFileName:(NSString *)fileName
{
    //create folder name based on filename without extension
    NSString *extension = [fileName pathExtension];
    
    //remove extension from filename for folder name
    NSString *folderName = [fileName stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@", extension] withString:@""];
    
    NSLog(@"Foldername : %@", folderName);
    
    return folderName;

}


@end
