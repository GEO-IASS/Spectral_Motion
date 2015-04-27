//
//  MSHyperspectralDataPlotter.h
//  Spectral_Motion
//
//  Created by Kale Evans on 3/23/15.
//  Copyright (c) 2015 Kale Evans. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CorePlot-CocoaTouch.h"
#import "MSHyperspectralData.h"

@interface MSHyperspectralDataPlotter : NSObject


@property (nonatomic, readwrite, strong) CPTXYGraph *m_Graph;
@property (nonatomic, strong) CPTGraphHostingView *m_GraphHostingView;
@property (nonatomic, strong) CPTScatterPlot * m_BoundPlot;
@property (nonatomic, strong) CPTXYPlotSpace * m_PlotSpace;


-(id)initWithHyperpsectralData:(MSHyperspectralData*)hyperspectralData andHeader:(HDRINFO)hdrInfo;

//-(id)initWithWavelengthsForXAxis:(NSMutableArray *) xValues PixelValuesForYAxis:(NSMutableArray *) yPixelValues andHeader:(HDRINFO) hdrInfo;

-(void)createScatterPlot;

-(void)updateScatterPlotForAllBandsWithXCoordinate:(int) xCoordinate andYCoordinate:(int) yCoordinate;

-(void)createScatterPlotWithView:(UIView *)view;

-(void)plotReflectanceDataAtIndexPaths:(NSArray *) indexPaths;

//-(void)setDelegate:(NSObject*)delegate;
//-(void)setDataSource:(CPTPlotDataSource*)dataSource;

-(void)graphStartRunLoop;

-(void)graphStopRunLoop;

-(CPTGraphHostingView*) getGraphView;


@end
