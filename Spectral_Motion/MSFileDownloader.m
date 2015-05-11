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
    [self writeDataToFile];
    
    [self.delegate downloadDidFinish];
    
    
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
        NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString  *documentsDirectory = [paths objectAtIndex:0];
        
        NSString *folderName = [NSString createFolderNameFromFileName:m_FileName];
        
        NSString  *filePath = [NSString stringWithFormat:@"%@/%@/%@/%@", documentsDirectory, FILE_STORAGE_PATH, folderName ,m_FileName];
        
        [m_fileData writeToFile:filePath atomically:YES];
        
        NSLog(@"Data stored in location %@",filePath);

    }
    else
    {
        NSLog(@"No File Data!");
    }
    
    NSLog(@"File write complete");
}



/*
-(void)downloadFileWithURL:(NSURL *) fileURL
{
    
    
}
 */


@end
