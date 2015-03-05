//
//  MSENVIFileParser.h
//  Spectral Motion
//
//  Created by Kale Evans on 12/23/14.
//  Copyright (c) 2014 Kale Evans. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct HDRINFO
{
    int samples;//columns
    int lines;// rows
    int bands;
    int header_Offset;
    int dataType;
    int *defaultBands;
    int byteOrder;
    float *wavelength;
    
    const char *interleave;
    const char *fileType;
    
}HDRINFO;

@interface MSENVIFileParser : NSObject
{
}
@property(strong,nonatomic) NSString *hdrFileName;
@property(strong,nonatomic) NSString *hdrFileContents;


-(id)initWithHDRFile: (NSString*)hdrFileNmae andImageFile:(NSString*)imgFileName;

-(id)initWithFileName: (NSString*)fileName;

/*-(void)parseHdrFileWithFileName: (NSString*)fileName;*/

-(BOOL)hdrReadSuccess;



-(int)  getSampleSize;
-(int)  getLineSize;
-(int)  getBandSize;
-(int)  getHeaderOffset;
-(int)  getDataType;
-(int)  getByteOrder;
-(int*) getDefaultBands;
-(float*) getWaveLength;



-(const char*) getFileType;
-(const char*) getInterleaveType;


@end
