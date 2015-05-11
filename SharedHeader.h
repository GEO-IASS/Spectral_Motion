//
//  SharedHeader.h
//  Spectral_Motion
//
//  Created by Kale Evans on 3/9/15.
//  Copyright (c) 2015 Kale Evans. All rights reserved.
//
#import "MSHyperspectralData.h"
#import "MSENVIFileParser.h"

typedef struct RGBPixel{
    
    uint8_t red;
    uint8_t green;
    uint8_t blue;
    uint8_t alpha;
    
    
}RGBPixel;

#define FILE_STORAGE_PATH @"Spectral_Motion_File_Data"


/*
typedef struct Hypserspectral_Data_Info
{
    MSHyperspectralData * hyperspectral_data;
    MSENVIFileParser    * headerFile;
    float               * wavelengths;    
    
    
}Hypserspectral_Data_Info;
*/


#ifndef Spectral_Motion_SharedHeader_h
#define Spectral_Motion_SharedHeader_h


#define SYSTEM_VERSION_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)

#define SYSTEM_VERSION_GREATER_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#endif
