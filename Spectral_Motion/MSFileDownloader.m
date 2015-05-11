//
//  MSFileDownloader.m
//  Spectral_Motion
//
//  Created by Kale Evans on 5/10/15.
//  Copyright (c) 2015 Kale Evans. All rights reserved.
//

#import "MSFileDownloader.h"
#import "SharedHeader.h"
#import "NSString+MSString.h"

@interface MSFileDownloader()
{
    NSInputStream *m_InputStream;
    NSMutableData *m_fileData;
}

-(void)setUpInputStreamWithURL:(NSURL *) fileLink;
-(void)tearDownInputStream;
-(void)writeDataToBuffer;
-(void)writeDataToFile;
-(void)createDirectoryIfNotExistsWithFolderPath:(NSString *) folderPath;


@end

@implementation MSFileDownloader
@synthesize m_FileURL ,m_FileName;


-(id)initWithURL:(NSURL *) fileURL andName:(NSString *) fileName;
{
    if(self = [super init])
    {
        m_FileURL = fileURL;
        m_FileName = fileName;
    }
    return self;
}

-(void)downloadFileInBackground
{
    /*First create session configuration. This must go first*/
    NSURLSessionConfiguration *sessionConfig =
    [NSURLSessionConfiguration defaultSessionConfiguration];
    
    sessionConfig.allowsCellularAccess = YES;
    
   /* [sessionConfig setHTTPAdditionalHeaders:
     @{@"Accept": @"application/json"}];
    */
    
    sessionConfig.timeoutIntervalForRequest = 30.0;
    sessionConfig.timeoutIntervalForResource = 300.0;
    sessionConfig.HTTPMaximumConnectionsPerHost = 1;
    
    
    /*Second, create Session with configuration object from above*/
    
    NSURLSession *session =
    [NSURLSession sessionWithConfiguration:sessionConfig
                                  delegate:self
                             delegateQueue:nil];
    
    
    
    /*Lastly, create the download*/
    
    NSURLSessionDownloadTask *getFileTask =
    
    [session downloadTaskWithURL:m_FileURL];
    
    /*
    [session downloadTaskWithURL: m_FileURL
     
               completionHandler:^(NSURL *location,
                                   NSURLResponse *response,
                                   NSError *error)
    {
        
        [NSData dataWithContentsOfURL:location];
        
        }];
     */
    
    
    // Start the task
    [getFileTask resume];

    
}

-(void)URLSession:(NSURLSession *)session
     downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    // use code above from completion handler
    
    //NSString *filename = [[location absoluteString] lastPathComponent];
    [self setUpInputStreamWithURL:location];
    
    //NSData *urlData = [NSData dataWithContentsOfURL:location];
    
    
}

-(void)setUpInputStreamWithURL:(NSURL *)fileLink
{
    m_InputStream = [NSInputStream inputStreamWithURL:fileLink];
    
    [m_InputStream setDelegate:self];
    
    [m_InputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    [m_InputStream open];
    
}

-(void)tearDownInputStream
{
    [m_InputStream close];
    [m_InputStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                      forMode:NSDefaultRunLoopMode];
    m_InputStream = nil;
}

-(void)writeDataToBuffer
{
    if(!m_fileData)
    {
        m_fileData = [NSMutableData data];
    }
    uint8_t buf[1024];
    unsigned int len = 0;
    len = [m_InputStream read:buf maxLength:1024];
    if(len)
    {
        [m_fileData appendBytes:(const void *)buf length:len];
        NSLog(@"wrote %i bytes", len);
        // bytesRead is an instance variable of type NSNumber.
        // [bytesRead setIntValue:[bytesRead intValue]+len];
    }
    else
    {
        NSLog(@"no buffer!");
    }

    
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {
    
    switch(eventCode)
    {
            //data available in buffer for reading
        case NSStreamEventHasBytesAvailable:
        {
            [self writeDataToBuffer];
            break;
        }
            
            //reached end of file
        case NSStreamEventEndEncountered:
        {
            //since eof, write data to file then alert delegate observer
            [self writeDataToFile];
            [self.delegate downloadDidFinish];
            [self tearDownInputStream];
            break;
        }
            
            //stream opened
        case NSStreamEventOpenCompleted:
        {
            NSLog(@"stream opened");
            
        }
            
    }
}


-(void)writeDataToFile
{
    
    NSLog(@"Writing data to file");
    if(m_fileData)
    {
       // NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        //NSString  *documentsDirectory = [paths objectAtIndex:0];
        
        //create parent directory for header and binary data
        NSString *documentsDirectory = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] path];
        
        NSString *folderName = [NSString createFolderNameFromFileName:m_FileName];
        
        NSString *folderPath = [NSString stringWithFormat:@"%@/%@/%@", documentsDirectory, FILE_STORAGE_PATH, folderName ];

        [self createDirectoryIfNotExistsWithFolderPath:folderPath];

        
        //write file to folder
        NSString  *filePath = [NSString stringWithFormat:@"%@/%@/%@/%@", documentsDirectory, FILE_STORAGE_PATH, folderName ,m_FileName];
        
        BOOL rc = [m_fileData writeToFile:filePath atomically:YES];
        if(rc)
        {
            NSLog(@"Data stored in location %@",filePath);
        }
        else
        {
            NSLog(@"Failure to write data to file %@", filePath);
            return;
        }
    }
    else
    {
        NSLog(@"No File Data!");
        return;
    }
    
    NSLog(@"File write complete");
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Success" message:@"File Downloaded Successfully" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//    [alert show];
}

-(void)createDirectoryIfNotExistsWithFolderPath:(NSString *) folderPath
{
    
    //create directory
    NSError * error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:folderPath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
    if (error != nil)
    {
        NSLog(@"error creating directory: %@", error.description);
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Could not save file" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        
    }

}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    //float progress = totalBytesWritten / totalBytesExpectedToWrite;
    
}

/*
-(void)downloadFileWithURL:(NSURL *) fileURL
{
 
 
}
 */


@end
