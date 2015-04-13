//
//  MSBandPickerViewsVC.m
//  Spectral_Motion
//
//  Created by Kale Evans on 4/8/15.
//  Copyright (c) 2015 Kale Evans. All rights reserved.
//

#import "MSBandPickerViewsVC.h"

@interface MSBandPickerViewsVC ()

-(void)setNavControllerButtonsForNavController:(UINavigationController*)navController;
-(void)setDelegateAndDataSourceForPickerView:(UIPickerView*)pickerView;

@end

@implementation MSBandPickerViewsVC
@synthesize m_NumberOfBands, m_ShouldShowColorOptions, m_ParentNavController, delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        
    if(m_ShouldShowColorOptions == [NSNumber numberWithBool:NO])
    {
        //set delegate and datasource, hide colorbandPickerview, and move greyscalepickerview into proper y position
        [self setDelegateAndDataSourceForPickerView:self.greyscaleBandPickerView];
        self.greyscalePickerViewBackground.frame  = self.colorBandPickerViewBackground.frame;
        self.colorBandPickerViewBackground.hidden = YES;

    }
    else
    {
        //set delegate and datasource, hide greyscalebandPickerview,
        [self setDelegateAndDataSourceForPickerView:self.colorBandPickerView];
        self.greyscalePickerViewBackground.hidden = YES;
    }
    
    [self setNavControllerButtonsForNavController:m_ParentNavController];
}
-(void)setDelegateAndDataSourceForPickerView:(UIPickerView*)pickerView
{
    pickerView.delegate = self;
    pickerView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)saveBandSelection
{
    //here after bands have been selected, create new image and call delegate to add to view
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
        
        //[delegate didFinishCreatingImage:<#(UIImage *)#>];
    }];
    
}

-(void)cancelBandSelection
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
        
    }];
}

-(void)setNavControllerButtonsForNavController:(UINavigationController*)navController
{
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Done"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   
                                   action:@selector(saveBandSelection)];
    
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithTitle:@"Cancel"
                                                                    style:UIBarButtonItemStylePlain target:self
                                                                   action:@selector(cancelBandSelection)];
    
    
    navController.topViewController.navigationItem.rightBarButtonItem = saveButton;
    navController.topViewController.navigationItem.leftBarButtonItem = cancelButton;
}



#pragma mark - UIPickerView Datasource Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if(m_ShouldShowColorOptions)
    {
        return 3;
    }
    else
    {
        return 1;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return m_NumberOfBands.intValue;
}


#pragma mark - UIPickerView Delegate methods

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%li", (long)row];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
