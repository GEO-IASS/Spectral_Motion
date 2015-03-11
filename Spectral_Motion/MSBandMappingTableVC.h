//
//  MSBandMappingTableVC.h
//  Spectral_Motion
//
//  Created by Kale Evans on 3/9/15.
//  Copyright (c) 2015 Kale Evans. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BandsSelectedDelegate <NSObject>

-(void)didFinishSelectingBandsForPCA:(NSArray*) bandsSelected;

-(void)didFinishMappingColorsForPCA:(NSDictionary*) bandsMapped;


@end

@interface MSBandMappingTableVC : UITableViewController
@property(strong,nonatomic) NSMutableArray *m_BandsSelected;
//@property(strong,nonatomic)NSDictionary *m_BandsMapped;

//@property(strong,nonatomic) NSMutableArray *m_RedBandsMapped;
//@property(strong,nonatomic) NSMutableArray *m_GreenBandsMapped;
//@property(strong,nonatomic) NSMutableArray *m_BlueBandsMapped;


@property(nonatomic,weak) id<BandsSelectedDelegate> delegate;

-(void)setWavelenghths:(float*)wavelengthArr andBandCount:(int)bandCount;

-(void)setColorMappingBOOL:(BOOL)colorMapBool;

-(short*)getColorsMapped;

@end
