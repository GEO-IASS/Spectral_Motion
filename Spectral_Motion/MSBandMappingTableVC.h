//
//  MSBandMappingTableVC.h
//  Spectral_Motion
//
//  Created by Kale Evans on 3/9/15.
//  Copyright (c) 2015 Kale Evans. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PCABandsSelectedDelegate <NSObject>

//-(void)didFinishSelectingBandsForPCA:(NSArray*) bandsSelected;

-(void)didFinishSelectingBandsForPCAWithArray:(int*) selectedBands andBandCount:(int) bandCount;


-(void)didFinishMappingColorsForPCAWithRedArray:(int*) redBands redArraryCount:(int) redCount greenArray:(int*) greenBands greenArrayCount:(int) greenCount andBlueArray:(int*) blueBands blueArrayCount:(int) blueCount;


//-(void)didFinishMappingColorsForPCA:(NSDictionary*) bandsMapped;


@end


@interface MSBandMappingTableVC : UITableViewController
@property(strong,nonatomic) NSMutableArray *m_BandsSelected;
@property (strong,nonatomic) UINavigationController *m_ParentNavController;// for ImageViewController

//@property(strong,nonatomic)NSDictionary *m_BandsMapped;

//@property(strong,nonatomic) NSMutableArray *m_RedBandsMapped;
//@property(strong,nonatomic) NSMutableArray *m_GreenBandsMapped;
//@property(strong,nonatomic) NSMutableArray *m_BlueBandsMapped;


@property(nonatomic,weak) id<PCABandsSelectedDelegate> delegate;


-(void)setWavelenghths:(float*)wavelengthArr andBandCount:(int)bandCount;

-(void)setColorMappingBOOL:(BOOL)colorMapBool;

-(short*)getColorsMapped;

@end
