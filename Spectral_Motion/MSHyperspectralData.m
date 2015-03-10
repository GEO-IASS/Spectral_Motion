//
//  MSHyperspectralData.m
//  Spectral Motion
//
//  Created by Kale Evans on 12/23/14.
//  Copyright (c) 2014 Kale Evans. All rights reserved.
//

#import "MSHyperspectralData.h"

//interleave types
#define BIP "bip"
#define BIL "bil"
#define BSQ "bsq"

using namespace cv;

@interface Objc_CVMatWrapper : NSObject
{
    Mat m_CVMatrix;
}

-(Mat)getMatrix;
-(id)initWithCVMatrix:(Mat)matrix;


@end

@implementation Objc_CVMatWrapper

-(Mat)getMatrix
{
    return m_CVMatrix;
}

-(id)initWithCVMatrix:(cv::Mat)matrix
{
    if(self = [super init])
    {
        m_CVMatrix = matrix;
    }
    return self;
}

@end

@interface MSHyperspectralData()
{
    void *** m_HyperspectralCube;//3d cube of hyperspectral data
    int m_DataSize;//size of hyperspectral data in bytes
    void *m_DataBuffer;//buffer that intially holds hyperspctral data. This is transferred to hypercube and freed
    cv::Mat m_FinalPCAMatrix;
    
    cv::Mat m_FinalPCARedMatrix;
    cv::Mat m_FinalPCAGreenMatrix;
    cv::Mat m_FinalPCABlueMatrix;


    /**Function pointer and selector section. These selectors are set to functions in readHyperspectralDataIntoBuffer method**/
    
    SEL m_PopulateHyperspectralCube;
    SEL m_CreateCVMatrixForBand;
    SEL m_CreateBGRCVMatrixForBands;

    
    //function pointer for getting pixel index
    int (*getPixelIndex) (int x, int y, int z, int width, int height, int depth);
    


}

-(void)setHDRInfoWithFileName:(NSString*)fileName;

-(void)setHDRInfoWithMSFileParser:(MSENVIFileParser*)fileParser;

//reads hyperpsectral data into cube and sets function pointers depending on data type
-(void) readHyperspectralDataIntoBuffer:(void*) dataBuffer dataType:(int) dataType elementsToAllocate:(int)elementsToAllocate fileName:(NSString*)fileName;

//important. Used if byte order in hdr file is set to 1
-(void)convertWordToLittleEndian:(int16_t&)word;

//important. Scaled pixel values of image to between 255-0 for rendering on screen.
-(Mat)scaleImage:(Mat) img cvFormat:(int)rtype;

-(void)releaseHypCube;



-(void)setPixelIndexFunctionPointers;


/*Functions being pointed to by function pointers annd selectors above. Primarily used for creating image matrix and hyperspectral cube */


-(void)populateHyperspectralCubeForShortType;

-(Objc_CVMatWrapper*)create16BitCVMatrixForBand:(NSNumber*) band;

-(Objc_CVMatWrapper*)create16BitBGRMatrixForBands:(NSDictionary*)dictOfBands;




/*Get pixel index functions. These are assigned to function pointers when image format is determined. Set using setFunctionPointers method*/

int getStandardPixelIndex(int x, int y, int z, int width, int height, int depth);

int getBIPPixelIndex(int x, int y, int z, int width, int height, int depth);

int getBILPixelIndex(int x, int y, int z, int width, int height, int depth);


@end

@implementation MSHyperspectralData
@synthesize delegate;

-(id)initWithHDRFile:(NSString*)fileName
{
    self = [super init];
    
    if(self)
    {

        [self setHDRInfoWithFileName:fileName];

    }
    
    return self;
}

-(id)initWithMSFileParser:(MSENVIFileParser*)fileParser
{
    self = [super init];
    
    if(self)
    {
        [self setHDRInfoWithMSFileParser:fileParser];
        
    }
    
    return self;
}

-(void)setPixelIndexFunctionPointers
{
    
    
    if(strcmp(hdrInfo.interleave, BIL)==0)
    {
        NSLog(@"bil format");
        getPixelIndex = getBILPixelIndex;
    }
    else if (strcmp(hdrInfo.interleave, BIP)==0)
    {
        NSLog(@"bip format");
        getPixelIndex = getBIPPixelIndex;
    }
    else if (strcmp(hdrInfo.interleave, BSQ)==0)
    {
        NSLog(@"bsq format");
        //set to get BSQPixelIndex function
    }
    else
    {   //TODO: replace with another function. Perhaps greyscale i.e one band pixel index??
        getPixelIndex = getBIPPixelIndex;
    }
}

-(void)setHDRInfoWithFileName:(NSString *)fileName
{
    MSENVIFileParser *enviFileParser = [[MSENVIFileParser alloc]initWithFileName:fileName];
    
    hdrInfo.dataType = [enviFileParser getDataType];
    hdrInfo.bands = [enviFileParser getBandSize];
    hdrInfo.lines = [enviFileParser getLineSize];
    hdrInfo.interleave = [enviFileParser getInterleaveType];
    hdrInfo.header_Offset = [enviFileParser getHeaderOffset];
    hdrInfo.byteOrder = [enviFileParser getByteOrder];
    hdrInfo.fileType = [enviFileParser getFileType];
    hdrInfo.defaultBands = [enviFileParser getDefaultBands];
    hdrInfo.wavelength = [enviFileParser getWaveLength];
    hdrInfo.samples = [enviFileParser getSampleSize];
    
    [self setPixelIndexFunctionPointers];
    

}

-(void)setHDRInfoWithMSFileParser:(MSENVIFileParser*)fileParser
{
    
    hdrInfo.dataType = [fileParser getDataType];
    hdrInfo.bands = [fileParser getBandSize];
    hdrInfo.lines = [fileParser getLineSize];
    hdrInfo.interleave = [fileParser getInterleaveType];
    hdrInfo.header_Offset = [fileParser getHeaderOffset];
    hdrInfo.byteOrder = [fileParser getByteOrder];
    hdrInfo.fileType = [fileParser getFileType];
    hdrInfo.defaultBands = [fileParser getDefaultBands];
    hdrInfo.wavelength = [fileParser getWaveLength];
    hdrInfo.samples = [fileParser getSampleSize];
    
    [self setPixelIndexFunctionPointers];

    
}

//here we read in buffer, casting depending on data type, and we also set function pointers which are
//also dependent on data type
-(void) readHyperspectralDataIntoBuffer:(void*) dataBuffer dataType:(int) dataType elementsToAllocate:(int)elementsToAllocate fileName:(NSString *)fileName
{
    
    int nPixelsInBand = hdrInfo.samples * hdrInfo.lines;
    
    NSString *path = [[NSBundle mainBundle] pathForResource: fileName ofType:nil];
    
    FILE * hyperspectralFile = fopen([path cStringUsingEncoding:1], "rb");
    
    switch (dataType)
    {
        case 1:
        {
            //8-bit unsigned integer Byte
            
            m_DataBuffer = (int8_t*) calloc(elementsToAllocate, sizeof(int8_t));
            size_t dataRead = fread(m_DataBuffer, sizeof(int8_t), (nPixelsInBand * hdrInfo.bands), hyperspectralFile);
            NSLog(@"data read %zu",dataRead);

            
        }
            break;
        case 2:
        {
            //16-bit signed integer Integer
            NSLog(@"16 bit");
            
            m_DataBuffer = (int16_t*) calloc(elementsToAllocate, sizeof(int16_t));
            size_t dataRead = fread(m_DataBuffer, sizeof(int16_t), (nPixelsInBand * hdrInfo.bands), hyperspectralFile);
            m_PopulateHyperspectralCube = @selector(populateHyperspectralCubeForShortType);
            m_CreateCVMatrixForBand = @selector(create16BitCVMatrixForBand:);
            m_CreateBGRCVMatrixForBands = @selector(create16BitBGRMatrixForBands:);

            m_DataSize = nPixelsInBand * hdrInfo.bands * sizeof(int16_t);

            NSLog(@"data read %zu",dataRead);
            
        }
            
            break;
        case 3:
            
            //32-bit signed integer Long
            break;
        case 4:
            //32-bit single-precision Floating-point
            break;
        case 5:
            //64-bit double precision floating point Double precision
            break;
        case 6:
            //real-imaginary pair of single-precision floating point Complex
            break;
        case 9:
            //real-imaginary pair of doule precision floating-point
            break;
        case 12:
            //unsigned integer 16-bit
            break;
        case 13:
            //unsigned long integer 32-bit
            break;
        case 14:
            //64-bit long integer (signed)
            break;
        case 15:
            //64-bit unsigned long integer (unsigned)
            break;
            
        default:
            break;
    }
    
    NSLog(@"num of elements to read %i", (nPixelsInBand * hdrInfo.bands));
    
    fclose(hyperspectralFile);
    
}


-(void)loadHyperspectralImageFile:(NSString*)fileName
{
    
    int nPixelsInBand = hdrInfo.samples * hdrInfo.lines;
    
    [self readHyperspectralDataIntoBuffer:m_DataBuffer dataType:hdrInfo.dataType elementsToAllocate:nPixelsInBand*hdrInfo.bands fileName:fileName];
    
    if(m_DataBuffer == NULL)
    {
        NSLog(@"Data buffer has no data");
        return;
    }
    
    [self performSelector:m_PopulateHyperspectralCube];
 
    free(m_DataBuffer);
    NSLog(@"Freed band buffer");
    
}

//this formula assumes array used is already cast to correct data type. Otherwise
//will also have to multiply by the number of bytes used per pixel/sample to get correct byte
-(int)getBIPPixelIndexAtX:(int)x atY:(int)y andZ:(int)z
{
    //(row*samples + column)*allocation*bands+band
    return ((   (y * hdrInfo.samples) + x   ) * hdrInfo.bands + z);
}

int getBIPPixelIndex(int x, int y, int z, int width, int height, int depth)
{
    //(row*samples + column)*allocation*bands+band
    return ((   (y * width) + x   ) * depth + z);
}


int getBILPixelIndex(int x, int y, int z, int width, int height, int depth)
{
    //(row*bands+band*column)*samples*allocation
    return ((   (y * depth) + z * width   ) * width );
}

int getStandardPixelIndex(int x, int y, int z, int width, int height, int depth)
{
    return (((y * width) + x) + (width * height));

}

-(void)convertWordToLittleEndian:(int16_t&)word
{
    /* below washes image out, and there is not enough detail
    if(word < 0)
    {
        word = 0;
        return;
    }
     */
    
    word = ( (word & 0x00FF) << 8 ) | ( (word & 0xFF00) >> 8 );
    
}

-(void)populateHyperspectralCubeForShortType
{
    
    int width = hdrInfo.samples;
    int height = hdrInfo.lines;
    int depth = hdrInfo.bands;
    float progress;

    
    //allocated space for height
    //here we need pointer to pointer to datatype for width and depth dimensions
    m_HyperspectralCube = (void***)calloc(height, sizeof(uint16_t**) );
    for(int i = 0; i < height; i++)
    {
        //allocate space for width
        //here we need pointer to datatype for depth dimension
        m_HyperspectralCube[i] = (void**)calloc(width, sizeof(uint16_t*) );
        for (int j = 0; j < width; j++)
        {
            //allocate space for depth
            //here we need can just used data type to allocate an array.
            m_HyperspectralCube[i][j] = (uint16_t*)calloc(depth, sizeof(uint16_t) );
        }
    }
    
    //fill cube with data
    for(int i = 0; i < height; i++)
    {
        for(int j = 0; j < width; j++)
        {
            for(int k =0; k < depth; k++)
            {
                int pixelIndex = getPixelIndex(j, i, k, hdrInfo.samples, hdrInfo.lines, depth);
                
                //convert to little endian for iOS and other devices with intel processors
                if(hdrInfo.byteOrder == 1)
                {
                    [self convertWordToLittleEndian:((int16_t*)m_DataBuffer)[pixelIndex]];

                }
                
                ((uint16_t***)m_HyperspectralCube)[i][j][k] =((uint16_t*)m_DataBuffer)[pixelIndex];
                
                //update MSHeaderViewController with our progress loading image data
                
                //measure progress by which line we are currently on
                if((k == (depth -1)) && (j == (width-1)))//did a full line i/height perecentage done
                {
                     progress = (float)i/height;
                    if(progress > .25)
                    {                    
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [self.delegate updateProgressView:progress];

                        });
                    }
                }
               
            }
        }
    }
    
    NSLog(@"m_datasize %i", m_DataSize);
    
}

-(void)releaseHypCube
{
    int lines = hdrInfo.lines;
    int samples = hdrInfo.samples;
    
    for(int i = 0; i < lines; i++)
    {
        for(int j = 0; j < samples; j++)
        {
            free(m_HyperspectralCube[i][j]);
        }
        free(m_HyperspectralCube[i]);
    }
    free(m_HyperspectralCube);
}

-(cv::Mat)createPrincipalComponentMatrixWithRedBandArray:(int[])redBands redBandsSize:(int) redBandsSize greenBands:(int[])greenBands greenBandsSize:(int)greenBandSize blueBands:(int[])blueBands blueBandsSize:(int)blueBandsSize
{
    
    cv::Mat colorImage;

    NSOperation *redBandPCAOperation = [NSBlockOperation blockOperationWithBlock:^{
        
        m_FinalPCARedMatrix = [self createPrincipalComponentMatrixWithBandArray:redBands andBandArraySize:redBandsSize];
        
    }];
    
    NSOperation *greenBandPCAOperation = [NSBlockOperation blockOperationWithBlock:^{
        
        m_FinalPCAGreenMatrix = [self createPrincipalComponentMatrixWithBandArray:greenBands andBandArraySize:greenBandSize];
        
    }];

    
    NSOperation *blueBandPCAOperation = [NSBlockOperation blockOperationWithBlock:^{
        
        m_FinalPCABlueMatrix = [self createPrincipalComponentMatrixWithBandArray:blueBands andBandArraySize:blueBandsSize];
        
    }];
    
    //merge all created PCA band matrixes here
    NSOperation *completionOperation = [NSBlockOperation blockOperationWithBlock:^{
        
        std::vector<cv::Mat> bandsToMergeArray;
        
        bandsToMergeArray.push_back(m_FinalPCABlueMatrix);
        bandsToMergeArray.push_back(m_FinalPCAGreenMatrix);
        bandsToMergeArray.push_back(m_FinalPCARedMatrix);
        
        cv::merge(bandsToMergeArray, colorImage);
        
    }];
    
    //set priority to very high for all operations for the best chance they are executed concurrently
    redBandPCAOperation.queuePriority = NSOperationQueuePriorityVeryHigh;
    greenBandPCAOperation.queuePriority = NSOperationQueuePriorityVeryHigh;
    blueBandPCAOperation.queuePriority = NSOperationQueuePriorityVeryHigh;
    
    [completionOperation addDependency:redBandPCAOperation];
    [completionOperation addDependency:greenBandPCAOperation];
    [completionOperation addDependency:blueBandPCAOperation];
    
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc]init];
    
    //set max concurrent operations to 3 for red, green, and blue pca band creation
    operationQueue.maxConcurrentOperationCount = 3;
    
    [operationQueue addOperation:redBandPCAOperation];
    [operationQueue addOperation:greenBandPCAOperation];
    [operationQueue addOperation:blueBandPCAOperation];
    [operationQueue addOperation:completionOperation];
    
    return colorImage;
    
}

-(cv::Mat)createPrincipalComponentMatrixWithBandArray:(int[])bandArray andBandArraySize:(int)arraySize
{
    /*First populate Mat in format for PCA.(Each element in column vector represents a pixels value for a particular band. The number of rows represent the number of bands used
     */
  //  int bands = maxBand;
    
    int nPixelsInBand = hdrInfo.lines * hdrInfo.samples;
    int samples = hdrInfo.samples;
    
    //mat of bands rows and nPixelsInBand columns. One full image per row
    Mat prePCAMatrix(arraySize, nPixelsInBand, CV_16UC1);
    int rowIdx = 0;
    int columnIdx = 0;
    
    for(int bandIdx = 0; bandIdx < arraySize; bandIdx++)
    {
        for(int pixelInBand = 0; pixelInBand < nPixelsInBand; pixelInBand++)
        {
            rowIdx = pixelInBand/samples;
            columnIdx = pixelInBand % samples;
            
            prePCAMatrix.at<uint16_t>(bandIdx,pixelInBand) = ((uint16_t***)m_HyperspectralCube)[rowIdx][columnIdx][bandArray[bandIdx]];
            
        }
    }
    
    //maybe release old matrix?
    [self releaseHypCube];
    
    //normalize before processing for smaller numbers during PCA calculation
    Mat scaledImg;
    cv::normalize(prePCAMatrix, scaledImg, 0, 255, NORM_MINMAX, CV_8UC1);
    
    //create pca matrix
    PCA pca = PCA(scaledImg, cv::Mat(), PCA::DATA_AS_COL, (int)1);
    
    NSLog(@"PCA rows: %i and PCA cols: %i", pca.mean.rows, pca.mean.cols);
    
    NSLog(@"scaledImg rows: %i and scaledImg cols: %i", scaledImg.rows, scaledImg.cols);
    
    /*subtract mean vector from each column of image vector
     Mat differenceMat(scaledImg.rows, scaledImg.cols, CV_8UC1, Scalar(0));
     
     
     for(int i =0; i < scaledImg.cols; i++)
     {
     add(scaledImg.col(i), pca.mean.col(0), differenceMat.col(i));
     }
     
     Mat postPCAMatrix = pca.project(differenceMat);
     */
    
    Mat postPCAMatrix = pca.project(scaledImg);
    
    NSLog(@"pre pca image size %i", nPixelsInBand);
    
    NSLog(@"pre pca image size with pixel function %zu", prePCAMatrix.total());
    
    NSLog(@"post pca image size = %zu", postPCAMatrix.total());
    
    NSLog(@"rows : %i columns : %i", postPCAMatrix.rows, postPCAMatrix.cols);
    
    m_FinalPCAMatrix = postPCAMatrix.reshape(1, hdrInfo.lines);
    
    NSLog(@"Final rows : %i Final columns : %i", m_FinalPCAMatrix.rows, m_FinalPCAMatrix.cols);
    
    Mat normalizedPCA;
    
    //normalize before return for display purposes
    cv::normalize(m_FinalPCAMatrix, normalizedPCA, 0, 255, NORM_MINMAX, CV_8UC1);
    return normalizedPCA;
}


-(Objc_CVMatWrapper*)create16BitCVMatrixForBand:(NSNumber*) band
{
    int width = hdrInfo.samples;
    int height = hdrInfo.lines;
    
    int bandIdx = [band intValue];
    NSLog(@"Band selected is %i", bandIdx);
    
    Mat imgBand(height,width,CV_16U);
    
    //fill mat with image from chosen band
    for(int i =0; i< height; i++)
    {
        for(int j =0; j <width; j++)
        {
            // mat.row(i).col(j).setTo(hyperspectralCube[i][j][0]);
            imgBand.at<uint16_t>(i,j) = ((uint16_t***)m_HyperspectralCube)[i][j][bandIdx];
            //Scalar intensity = imgBand.at<uint16_t>(i,j);
           // NSLog(@"\n Pixel Value: %f",intensity.val[0]);
          // float f = (intensity.val[0] * (255.0/65535.0));
          //  NSLog(@"Pixel value after conversion %f",f);
        }
    }
    
    Mat scaledImg;
    scaledImg = [self scaleImage:imgBand cvFormat:CV_8U];
    
  //  [self checkPixelValues:scaledImg];
    
    
    Objc_CVMatWrapper *cvWrapper = [[Objc_CVMatWrapper alloc]initWithCVMatrix:scaledImg];
    
    return cvWrapper;
    
}


-(cv::Mat)createCVMatrixForBand:(int)band
{
    
    Objc_CVMatWrapper* objc_Img = (Objc_CVMatWrapper*) [self performSelector:m_CreateCVMatrixForBand withObject:[NSNumber numberWithInt:band]];
    
    return [objc_Img getMatrix];
    
}

-(Objc_CVMatWrapper*)create16BitBGRMatrixForBands:(NSDictionary*)dictOfBands
{
    int width = hdrInfo.samples;
    int height = hdrInfo.lines;
    
    NSNumber *NSNumberBlueBand = (NSNumber*)[dictOfBands valueForKey:@"blueBand"];
    NSNumber *NSNumbergreenBand = (NSNumber*)[dictOfBands valueForKey:@"greenBand"];
    NSNumber *NSNumberRedBand = (NSNumber*)[dictOfBands valueForKey:@"redBand"];

    
    
    int blueBand = [NSNumberBlueBand intValue];
    int greenBand = [NSNumbergreenBand intValue];
    int redBand = [NSNumberRedBand intValue];
    
    Mat imgBand(height, width, CV_16UC3);
    
    for(int i =0; i< height; i++)
    {
        for(int j=0; j< width; j++)
        {
            
            uint16_t blueChannel =   ((uint16_t***)m_HyperspectralCube)[i][j][blueBand];
            
            uint16_t greenChannel =  ((uint16_t***)m_HyperspectralCube)[i][j][greenBand];
            
            uint16_t redChannel  =   ((uint16_t***)m_HyperspectralCube)[i][j][redBand];
            
            /*Doesn't seem to work well
             imgBand.at<cv::Vec3b>(i,j)[0] = blueChannel;
             imgBand.at<cv::Vec3b>(i,j)[1] = greenChannel;
             imgBand.at<cv::Vec3b>(i,j)[2] = redChannel;
             //imgBand.at<cv::Vec3b>(i, j)[3] = 255;
             */
            
            Point3_<uint16_t> *pixel = imgBand.ptr<Point3_<uint16_t> >(i,j);
            
            pixel->x = redChannel;
            pixel->y = greenChannel;
            pixel->z = blueChannel;
            
            
#if 0
            Scalar *pixel = (Scalar*)imgBand.at<UNSIGNED_DATA_TYPE>(i, j);
            pixel->val[0] = blueChannel;
            pixel->val[1] = greenChannel;
            pixel->val[2] = redChannel;
            pixel->val[3] = (UNSIGNED_DATA_TYPE) 255;
            
#endif
            
        }
    }
    
   Mat scaledImg = [self scaleImage:imgBand cvFormat:CV_8UC3];

    
    Objc_CVMatWrapper *objcMatWrapper = [[Objc_CVMatWrapper alloc]initWithCVMatrix:scaledImg];
    
    return objcMatWrapper ;
    
}

-(cv::Mat)createCVBGRMatrixWithBlueBand:(int) blueBand greenBand:(int)greenBand andRedBand:(int) redBand
{
    NSLog(@"red band %i", redBand);
    NSLog(@"green band %i", greenBand);
    NSLog(@"blue band %i", blueBand);

    
    NSDictionary *dict = [[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:blueBand],@"blueBand",[NSNumber numberWithInt:greenBand], @"greenBand",[NSNumber numberWithInt:redBand], @"redBand", nil];
    
  Objc_CVMatWrapper* objcMat= (Objc_CVMatWrapper*) [self performSelector:m_CreateBGRCVMatrixForBands withObject:dict];
    
    return [objcMat getMatrix];

}

-(void)checkPixelValues:(Mat)imgBand
{
    
    int width = hdrInfo.samples;
    int height = hdrInfo.lines;
    
    //int bandIdx = [band intValue];
    
    
    for(int i =0; i< height; i++)
    {
        for(int j =0; j <width; j++)
        {
            // mat.row(i).col(j).setTo(hyperspectralCube[i][j][0]);
            // imgBand.at<uint16_t>(i,j) = ((uint16_t***)m_HyperspectralCube)[i][j][bandIdx];
            // Scalar intensity = imgBand.at<uint16_t>(i,j);
            Scalar intensity = imgBand.at<uint8_t>(i,j);
            NSLog(@"\n Pixel Value: %f",intensity.val[0]);
            //   NSLog(@"\n Pixel Value: %f",intensity.val[1]);
            // NSLog(@"\n Pixel Value: %f",intensity.val[2]);
            //  NSLog(@"\n Pixel Value: %f",intensity.val[3]);
            
            
            
        }
    }
    
}

-(Mat)scaleImage:(Mat) img cvFormat:(int)rtype
{
    double minVal, maxVal;
    minMaxLoc(img, &minVal, &maxVal); //find minimum and maximum intensities
    
    Mat temp;
    //scale pixel values to between 255 and 0.
    //also adding arbitrary 5 as beta for brightness
    img.convertTo(temp, rtype, (255.0/(maxVal - minVal)),5);
    
    return temp;
}




-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    NSLog(@"Channels %i", cvMat.channels());
    
    //if (cvMat.elemSize() == 1)
    if(cvMat.channels() == 1)
    {
        NSLog(@"colorspace is gray");
        colorSpace = CGColorSpaceCreateDeviceGray();
    }
    else
    {
        NSLog(@"colorspace is bgr");
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    int bitsPerComponent = 8;
    int bitsPerPixel = 8;
    int type = CV_MAT_TYPE(cvMat.type());
    switch (type)
    {
            
        case CV_8UC1:
            NSLog(@"8 bit CU1");
            bitsPerComponent = 8;
            bitsPerPixel = 8;
            break;
            
        case CV_8UC3:
            NSLog(@"8 bit CU3");

            bitsPerComponent = 8;
            //bitsPerPixel = bitsPerComponent * cvMat.channels();
            bitsPerPixel = 24;
            break;
            
        case CV_16UC1:
            bitsPerComponent = 16;
            bitsPerPixel = 16;
            break;
            
        case CV_16UC3:
            bitsPerComponent = 16;
            bitsPerPixel = 48;
            break;
            
        case CV_32FC4:
            bitsPerComponent = 8;
            bitsPerPixel = 32;
            //bitsPerPixel = cvMat.channels()*bitsPerComponent;
            break;
            
        case CV_64FC4:
            bitsPerComponent = 16;
            //bitsPerPixel = 16 * cvMat.channels();
            bitsPerPixel = 64;
            break;
            
        default:
            break;
    }
    
   // [self checkPixelValues:cvMat];
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        bitsPerComponent,                           //bits per component
                                        bitsPerPixel,                               //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}


@end
