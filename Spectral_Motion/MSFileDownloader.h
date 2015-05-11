//
//  MSFileDownloader.h
//  Spectral_Motion
//
//  Created by Kale Evans on 5/10/15.
//  Copyright (c) 2015 Kale Evans. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MSFileDownloaderDelegate<NSObject>

-(void)downloadDidFinish;

@end


@interface MSFileDownloader : NSObject<NSURLSessionDownloadDelegate, NSStreamDelegate>

@property(strong,nonatomic) NSURL *m_FileURL;
@property(strong,nonatomic) NSString *m_FileName;
@property(weak, nonatomic) id<MSFileDownloaderDelegate> delegate;


-(id)initWithURL:(NSURL *) fileURL andName:(NSString *) fileName;

-(void)downloadFileInBackground;

//-(void)downloadFileWithURL:(NSURL *) fileURL;

@end
