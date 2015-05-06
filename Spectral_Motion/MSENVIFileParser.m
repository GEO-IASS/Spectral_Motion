//
//  MSENVIFileParser.m
//  Spectral Motion
//
//  Created by Kale Evans on 12/23/14.
//  Copyright (c) 2014 Kale Evans. All rights reserved.
//

#import "MSENVIFileParser.h"
#import "NSString+MSString.h"


#define LINE_SIZE_REGEXP @"lines\\s*=\\s*[0-9]{1,5}\\s*\n"
#define SAMPLE_SIZE_REGEXP @"samples\\s*=\\s*[0-9]{1,5}\\s*\n"
#define BAND_SIZE_REGEXP @"bands\\s*=\\s*[0-9]{1,5}\\s*\n"
#define HEADER_OFFSET_REGEXP @"header\\s*offset\\s*=\\s*[0-9]{1,5}\\s*\n"
#define DATA_TYPE_REGEXP @"data\\s*type\\s*=\\s*[0-9]{1,5}\\s*\n"
#define BYTE_ORDER_REGEXP @"byte\\s*order\\s*=\\s*[0-9]{1,5}\\s*\n"

/*
 [A-Za-z]{0,20}  - Match 0 to 20 characters in range A-Z and a-z from 0 to 20 times
 
 (\\s*[A-Za-z]{0,10})? - The ? means optionally match characters in range A-Z and a-z from 0 to 20 times. This is optional for one word situations as opposed to two words like "ENVI Standard"
 
 */
#define FILE_TYPE_REGEXP @"file\\s*type\\s*=\\s*[A-Za-z]{0,20}(\\s*[A-Za-z]{0,20})?\\s*\n"

#define INTERLEAVE_TYPE_REGEXP @"interleave\\s*=\\s*[A-Za-z]{0,20}\\s*\n"

/*
 \\{  - Opening brace (must be escaped for regular expression so it doesn' have usual meaning which indicates a range
 
 ([0-9]{1,3},?\\s*){1,} - A group that consists of a 1 to 3 digit number from 0-9 and an optional ','(the ',' is optional because the last number in the array won't have an ',' following. Then 0 or more spaces with \\s*. The last {1,} indicates I want this pattern a minimum of 1 time, but can has an unlimited amount of times this pattern could repeat itself. 
 
 Acutally, this can be changed to only 3 occurerences instead of an unlimited amount since the defualt bands represent rgb, so 3 numbers only.
 
 */

#define DEFAULT_BANDS_REGEXP @"default\\s*bands\\s*=\\s*\\{\\s*([0-9]{1,3},?\\s*){1,}\\s*\\}"

#define WAVELENGTH_REGEXP @"wavelength\\s*=\\s*\\{\\s*([0-9]{1,2}.[0-9]{1,8},?\\s*){1,}\\s*\\}"



@interface MSENVIFileParser()
{
    HDRINFO hdrInfo;
    
}
-(void)convertHdrFileToString;
-(void)setHDRInfo;

-(void)setSampleSize;
-(void)setLineSize;
-(void)setBandSize;
-(void)setHdrOffset;
-(void)setDataType;
-(void)setDefaultBands;
-(void)setWaveLength;
-(void)setWavelengthWithAlternateFile:(NSString *) wvlnFile;
-(void)setByteOrder;
-(void)setFileType;
-(void)setInterleaveType;



@end

@implementation MSENVIFileParser
@synthesize hdrFileName, hdrFileContents;

-(id)initWithHDRFile: (NSString*)hdrFileNmae andImageFile:(NSString*)imgFileName
{
    self = [super init];
    
    if(self)
    {
        
    }
    
    return self; 
}

-(id)initWithFileName: (NSString*)fileName
{
    self = [super init];
    
    if(self)
    {
        self.hdrFileName = fileName;
        [self convertHdrFileToString];
        [self setHDRInfo];
    }
    
    return self;
}
-(void)setHDRInfo
{
    [self setSampleSize];
    [self setLineSize];
    [self setBandSize];
    [self setHdrOffset];
    [self setDataType];
    [self setDefaultBands];
    [self setWaveLength];
    [self setByteOrder];
    [self setFileType];
    [self setInterleaveType];
    
}

-(void)setSampleSize
{
    NSError *error;
    
    NSRegularExpression *regex = [[NSRegularExpression alloc]initWithPattern:SAMPLE_SIZE_REGEXP options:NSRegularExpressionCaseInsensitive error:&error];
    
    
    NSTextCheckingResult *textCheckingResult = [regex firstMatchInString:self.hdrFileContents options:0 range:NSMakeRange(0, self.hdrFileContents.length)];
    
    NSRange matchRange = [textCheckingResult range];
    NSString *sampleSizeStr = [self.hdrFileContents substringWithRange:matchRange];
    NSLog(@"found sample size %@", sampleSizeStr);
    
    sampleSizeStr = [sampleSizeStr stringBetweenString:@"=" andString:@"\n"];
   
    
    sampleSizeStr = [sampleSizeStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    //remove any extra end of line characters like carraige return
    sampleSizeStr = [sampleSizeStr stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc]init];
    
    NSNumber *sampleSizeNSNumber = [numberFormatter numberFromString:sampleSizeStr];
    
    int sampleSize = sampleSizeNSNumber.intValue;
    
    NSLog(@"sample size %i", sampleSize);
    hdrInfo.samples = sampleSize;
    
}

-(int) getSampleSize
{
    return hdrInfo.samples;
    
}

-(void)setLineSize
{
    NSError *error;
    
    NSRegularExpression *regex = [[NSRegularExpression alloc]initWithPattern:LINE_SIZE_REGEXP options:NSRegularExpressionCaseInsensitive error:&error];
    
    
    NSTextCheckingResult *textCheckingResult = [regex firstMatchInString:self.hdrFileContents options:0 range:NSMakeRange(0, self.hdrFileContents.length)];
    
    NSRange matchRange = [textCheckingResult range];
    NSString *lineSizeStr = [self.hdrFileContents substringWithRange:matchRange];
    NSLog(@"Found string '%@'", lineSizeStr);
    
    
    lineSizeStr = [lineSizeStr stringBetweenString:@"=" andString:@"\n"];

    lineSizeStr = [lineSizeStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    //remove any extra end of line characters like carraige return
    lineSizeStr = [lineSizeStr stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc]init];
    
    NSNumber *lineSizeNumber = [numberFormatter numberFromString:lineSizeStr];
    
    int lineSize = lineSizeNumber.intValue;
    hdrInfo.lines = lineSize;

    
}


-(int) getLineSize
{
    return hdrInfo.lines;
}


-(void)setBandSize
{
    NSError *error;
    
    NSRegularExpression *regex = [[NSRegularExpression alloc]initWithPattern:BAND_SIZE_REGEXP options:NSRegularExpressionCaseInsensitive error:&error];
    
    
    NSTextCheckingResult *textCheckingResult = [regex firstMatchInString:self.hdrFileContents options:0 range:NSMakeRange(0, self.hdrFileContents.length)];
    
    NSRange matchRange = [textCheckingResult range];
    NSString *bandSizeStr = [self.hdrFileContents substringWithRange:matchRange];
    NSLog(@"Found string '%@'", bandSizeStr);
    
    
    bandSizeStr = [bandSizeStr stringBetweenString:@"=" andString:@"\n"];
   
    bandSizeStr = [bandSizeStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    bandSizeStr = [bandSizeStr stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];

    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc]init];
    
    NSNumber *bandSizeNumber = [numberFormatter numberFromString:bandSizeStr];
    
    int bandSize = bandSizeNumber.intValue;
    hdrInfo.bands = bandSize;
    
}


-(int) getBandSize
{
    return hdrInfo.bands;
}


-(void)setHdrOffset
{
    NSError *error;
    
    NSRegularExpression *regex = [[NSRegularExpression alloc]initWithPattern:HEADER_OFFSET_REGEXP options:NSRegularExpressionCaseInsensitive error:&error];
    
    
    NSTextCheckingResult *textCheckingResult = [regex firstMatchInString:self.hdrFileContents options:0 range:NSMakeRange(0, self.hdrFileContents.length)];
    
    NSRange matchRange = [textCheckingResult range];
    NSString *headerOffsetStr = [self.hdrFileContents substringWithRange:matchRange];
    NSLog(@"Found string '%@'", headerOffsetStr);
    
    
    headerOffsetStr = [headerOffsetStr stringBetweenString:@"=" andString:@"\n"];
   
    headerOffsetStr = [headerOffsetStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    headerOffsetStr = [headerOffsetStr stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];

    
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc]init];
    
    NSNumber *headerOffsetNumber = [numberFormatter numberFromString:headerOffsetStr];
   
    int headerOffset = headerOffsetNumber.intValue;
    hdrInfo.header_Offset = headerOffset;

    
}


-(int) getHeaderOffset
{
    return hdrInfo.header_Offset;
    
}

-(void)setDataType
{
    NSError *error;
    
    NSRegularExpression *regex = [[NSRegularExpression alloc]initWithPattern:DATA_TYPE_REGEXP options:NSRegularExpressionCaseInsensitive error:&error];
    
    
    NSTextCheckingResult *textCheckingResult = [regex firstMatchInString:self.hdrFileContents options:0 range:NSMakeRange(0, self.hdrFileContents.length)];
    
    NSRange matchRange = [textCheckingResult range];
    NSString *dataTypeStr = [self.hdrFileContents substringWithRange:matchRange];
    NSLog(@"Found string '%@'", dataTypeStr);
    
    
    dataTypeStr = [dataTypeStr stringBetweenString:@"=" andString:@"\n"];
  
    dataTypeStr = [dataTypeStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    dataTypeStr = [dataTypeStr stringByTrimmingCharactersInSet:
                   [NSCharacterSet newlineCharacterSet]];

    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc]init];
    
    NSNumber *dataTypeNumber = [numberFormatter numberFromString:dataTypeStr];
    
    int dataType = dataTypeNumber.intValue;
    hdrInfo.dataType = dataType;

}

-(int)  getDataType
{
    return hdrInfo.dataType;
    
}

-(void)setDefaultBands
{
    NSError *error;
    
    NSRegularExpression *regex = [[NSRegularExpression alloc]initWithPattern:DEFAULT_BANDS_REGEXP options:NSRegularExpressionCaseInsensitive error:&error];
    
    
    NSTextCheckingResult *textCheckingResult = [regex firstMatchInString:self.hdrFileContents options:0 range:NSMakeRange(0, self.hdrFileContents.length)];
    
    NSRange matchRange = [textCheckingResult range];
    NSString *defaultBandsStr = [self.hdrFileContents substringWithRange:matchRange];
    NSLog(@"Found string '%@'", defaultBandsStr);
    
    
    defaultBandsStr = [defaultBandsStr stringBetweenString:@"{" andString:@"}"];
   
    if(defaultBandsStr == nil)
    {
        hdrInfo.defaultBands = 0;
        return;
    }
    
    
    NSArray *defaultBandsArray = [defaultBandsStr componentsSeparatedByString:@","];
    
    int *defaultBands = (int*)calloc(defaultBandsArray.count, sizeof(int));
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc]init];
    
    
    for(int i =0; i < defaultBandsArray.count; i++)
    {
        defaultBands[i] =   [numberFormatter numberFromString:defaultBandsArray[i]].intValue;
        
    }

    hdrInfo.defaultBands = defaultBands;
}

-(int*) getDefaultBands
{
    return hdrInfo.defaultBands;
}

-(void)setWaveLength
{
    NSError *error;
    
    NSRegularExpression *regex = [[NSRegularExpression alloc]initWithPattern:WAVELENGTH_REGEXP options:NSRegularExpressionCaseInsensitive error:&error];
    
    
    NSTextCheckingResult *textCheckingResult = [regex firstMatchInString:self.hdrFileContents options:0 range:NSMakeRange(0, self.hdrFileContents.length)];
    
    NSRange matchRange = [textCheckingResult range];
    NSString *wavelengthStr = [self.hdrFileContents substringWithRange:matchRange];
    NSLog(@"Found string '%@'", wavelengthStr);
    
    
    wavelengthStr = [wavelengthStr stringBetweenString:@"{" andString:@"}"];
  
    if(wavelengthStr == nil)
    {
        //hdrInfo.wavelength = 0;
        [self setWavelengthWithAlternateFile:@"Aviris"];
        return ;
    }
   
    
    NSArray *wavelengthArray = [wavelengthStr componentsSeparatedByString:@","];
    
    float *wavelength = (float*)calloc(wavelengthArray.count, sizeof(float));
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc]init];
    
    
    for(int i =0; i < wavelengthArray.count; i++)
    {
        NSString *wavelengthStrItem = [wavelengthArray[i] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        wavelength[i] =  [numberFormatter numberFromString:wavelengthStrItem].floatValue;
        
    }
    
    hdrInfo.wavelength = wavelength;
    
}

-(void)setWavelengthWithAlternateFile:(NSString *) wvlnFile
{
    NSError *error;
    
    NSRegularExpression *regex = [[NSRegularExpression alloc]initWithPattern:WAVELENGTH_REGEXP options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSString *file = [[NSBundle mainBundle] pathForResource:wvlnFile ofType:@"wvln"];
    
    NSString *fileStr = [NSString stringWithContentsOfFile:file
                                                  encoding:NSUTF8StringEncoding error:NULL];
    
    
    NSTextCheckingResult *textCheckingResult = [regex firstMatchInString:fileStr options:0 range:NSMakeRange(0, fileStr.length)];
    
    NSRange matchRange = [textCheckingResult range];
    NSString *wavelengthStr = [fileStr substringWithRange:matchRange];
    NSLog(@"Found string '%@'", wavelengthStr);
    
    
    wavelengthStr = [wavelengthStr stringBetweenString:@"{" andString:@"}"];
    
    if(wavelengthStr == nil)
    {
        hdrInfo.wavelength = 0;
        return ;
    }
    
    NSArray *wavelengthArray = [wavelengthStr componentsSeparatedByString:@","];
    
    float *wavelength = (float*)calloc(wavelengthArray.count, sizeof(float));
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc]init];
    
    
    for(int i =0; i < wavelengthArray.count; i++)
    {
        NSString *wavelengthStrItem = [wavelengthArray[i] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        wavelength[i] =  [numberFormatter numberFromString:wavelengthStrItem].floatValue;
        
    }
    
    hdrInfo.wavelength = wavelength;
    
}

-(float*) getWaveLength
{
    return hdrInfo.wavelength;
    
}

-(void)setByteOrder
{
    NSError *error;
    
    NSRegularExpression *regex = [[NSRegularExpression alloc]initWithPattern:BYTE_ORDER_REGEXP options:NSRegularExpressionCaseInsensitive error:&error];
    
    
    NSTextCheckingResult *textCheckingResult = [regex firstMatchInString:self.hdrFileContents options:0 range:NSMakeRange(0, self.hdrFileContents.length)];
    
    NSRange matchRange = [textCheckingResult range];
    NSString *byteOrderStr = [self.hdrFileContents substringWithRange:matchRange];
    NSLog(@"Found string '%@'", byteOrderStr);
    
    
    byteOrderStr = [byteOrderStr stringBetweenString:@"=" andString:@"\n"];

    byteOrderStr = [byteOrderStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    byteOrderStr = [byteOrderStr stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];

    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc]init];
    
    NSNumber *byteOrderNumber = [numberFormatter numberFromString:byteOrderStr];
    
    int byteOrder = byteOrderNumber.intValue;
    
    hdrInfo.byteOrder = byteOrder;

    
}

-(int)  getByteOrder
{
        return hdrInfo.byteOrder;
}

-(void)setFileType
{
    NSError *error;
    
    NSRegularExpression *regex = [[NSRegularExpression alloc]initWithPattern:FILE_TYPE_REGEXP options:NSRegularExpressionCaseInsensitive error:&error];
    
    
    NSTextCheckingResult *textCheckingResult = [regex firstMatchInString:self.hdrFileContents options:0 range:NSMakeRange(0, self.hdrFileContents.length)];
    
    NSRange matchRange = [textCheckingResult range];
    NSString *fileTypeStr = [self.hdrFileContents substringWithRange:matchRange];
    NSLog(@"Found string '%@'", fileTypeStr);
    
    
    fileTypeStr = [fileTypeStr stringBetweenString:@"=" andString:@"\n"];
  
    const char * fileType = [fileTypeStr UTF8String];
    
    hdrInfo.fileType = fileType;
    

}

-(const char*) getFileType
{
    return hdrInfo.fileType;
    
}

-(void)setInterleaveType
{
    NSError *error;
    
    NSRegularExpression *regex = [[NSRegularExpression alloc]initWithPattern:INTERLEAVE_TYPE_REGEXP options:NSRegularExpressionCaseInsensitive error:&error];
    
    
    NSTextCheckingResult *textCheckingResult = [regex firstMatchInString:self.hdrFileContents options:0 range:NSMakeRange(0, self.hdrFileContents.length)];
    
    NSRange matchRange = [textCheckingResult range];
    NSString *interleaveTypeStr = [self.hdrFileContents substringWithRange:matchRange];
    NSLog(@"Found string '%@'", interleaveTypeStr);
    
    
    interleaveTypeStr = [interleaveTypeStr stringBetweenString:@"=" andString:@"\n"];
  
    interleaveTypeStr = [interleaveTypeStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    const char * interleaveType = [interleaveTypeStr UTF8String];
    
    hdrInfo.interleave = interleaveType;

    
}

-(const char*) getInterleaveType
{
    return hdrInfo.interleave;
}



-(void)convertHdrFileToString
{
    NSString *file = [[NSBundle mainBundle] pathForResource:self.hdrFileName ofType:@"hdr"];
    
    NSString *fileStr = [NSString stringWithContentsOfFile:file
                                                  encoding:NSUTF8StringEncoding error:NULL];
    self.hdrFileContents = fileStr;

}

-(BOOL)hdrReadSuccess
{
    if(self.hdrFileContents.length == 0)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}



@end
