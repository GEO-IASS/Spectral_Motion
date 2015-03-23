//
//  MSHyperspectralData.h
//  Spectral Motion
//
//  Created by Kale Evans on 12/23/14.
//  Copyright (c) 2014 Kale Evans. All rights reserved.
//

//#import "opencv2/highgui/ios.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "MSENVIFileParser.h"


@protocol ProgressDelegate <NSObject>

- (void) updateProgressView:(float)progress;

@end

@interface MSHyperspectralData : NSObject
{

    HDRINFO hdrInfo;

}
@property(weak,nonatomic) id <ProgressDelegate> delegate;


//intializes a MSHyperspectral object and sets hdr information
-(id)initWithHDRFile:(NSString*)fileName;

-(id)initWithMSFileParser:(MSENVIFileParser*)fileParser;

//loads binary hyperspectral image file
-(void)loadHyperspectralImageFile:(NSString*)fileName;//loads

-(void)releaseHypCube;

-(NSMutableArray*)getPixelValuesForAllBandsAtXCoordinate:(int) xCoordinate andYCoordinate:(int) yCoordinate;


-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat;


-(cv::Mat)createCVMatrixForBand:(int)band;


-(cv::Mat)createCVBGRMatrixWithBlueBand:(int) blueBand greenBand:(int)greenBand andRedBand:(int) redBand;
-(cv::Mat)createPrincipalComponentMatrixWithBandArray:(int[])bandArray andBandArraySize:(int)arraySize;

-(cv::Mat)createPrincipalComponentMatrixWithRedBandArray:(int[])redBands redBandsSize:(int) redBandsSize greenBands:(int[])greenBands greenBandsSize:(int)greenBandSize blueBands:(int[])blueBands blueBandsSize:(int)blueBandsSize;

@end
