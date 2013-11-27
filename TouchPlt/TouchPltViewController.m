//
//  TouchPltViewController.m
//  TouchPlt
//
//  Created by Yusuke Saitoh on 2013/11/04.
//  Copyright (c) 2013年 Yusuke Saitoh. All rights reserved.
//

#import "TouchPltViewController.h"
#import "CanvasView.h"
#import "UsageView.h"
#import "TouchPltUtil.h"
#import <MessageUI/MessageUI.h>

@interface TouchPltViewController () <UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate>
@property (weak) id statusBarWillChange;
@end

@implementation TouchPltViewController {
    IBOutlet CanvasView *canvasView;
    UISegmentedControl *modeSegmentedControl;
    UsageView *usageView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Navigationbar
    self.title = @"TouchPlt";
    UIBarButtonItem *guideBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"usage_title", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(touchUpInside:)];
    guideBarButtonItem.tag = 11;
    self.navigationItem.rightBarButtonItem = guideBarButtonItem;
    
    // Toolbar
    modeSegmentedControl = [[UISegmentedControl alloc]initWithItems:@[NSLocalizedString(@"mode_draw", nil), NSLocalizedString(@"mode_move", nil), NSLocalizedString(@"mode_delete", nil), NSLocalizedString(@"mode_close", nil), NSLocalizedString(@"mode_copy", nil)]];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        [modeSegmentedControl setTitleTextAttributes:
         [ NSDictionary dictionaryWithObject:[ UIFont systemFontOfSize:10 ]
                                      forKey:UITextAttributeFont ]
                                            forState:UIControlStateNormal];

    modeSegmentedControl.selectedSegmentIndex = 0;
    modeSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [modeSegmentedControl addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    UIBarButtonItem *modeBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:modeSegmentedControl];
    UIBarButtonItem *allDeleteBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(touchUpInside:)];
    allDeleteBtn.tag = 1;
    UIBarButtonItem *actionBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(touchUpInside:)];
    actionBtn.tag = 2;
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [self setToolbarItems:@[allDeleteBtn, flexSpace, modeBarButtonItem, flexSpace, actionBtn] animated:YES];
    
    // UsageView
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (!window) window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    usageView = [[UsageView alloc]initWithFrame:window.bounds];
    [window addSubview:usageView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    self.statusBarWillChange = [center
                                addObserverForName:UIApplicationWillChangeStatusBarFrameNotification
                                object:nil
                                queue:[NSOperationQueue mainQueue]
                                usingBlock:^(NSNotification *note) {
                                    [usageView statusbarHeightChanged];
                                }
                                ];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:animated];
}

- (void)viewWillDisappear
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.statusBarWillChange];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UIControl

- (void)valueChanged:(id)sender
{    
    UISegmentedControl *segmentedControl = (UISegmentedControl*)sender;
    canvasView.mode = segmentedControl.selectedSegmentIndex;
    [canvasView setNeedsDisplay];
}

- (void)touchUpInside:(id)sender
{
    UIButton *button = (UIButton*)sender;
    switch (button.tag) {
        case 1:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"al_delete_m",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"no",nil) otherButtonTitles:NSLocalizedString(@"yes",nil), nil];
            alert.tag = 1;
            [alert show];
        }
            break;
            
        case 2:
        {
            UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:NSLocalizedString(@"ex_title",nil) delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"ex_thin",nil), NSLocalizedString(@"ex_normal",nil), NSLocalizedString(@"ex_thick",nil), NSLocalizedString(@"ex_pen",nil), NSLocalizedString(@"ex_svg",nil), nil];
            [actionSheet showInView:self.navigationController.view];
        }
            break;
            
        case 11:
        {
            [UIView animateWithDuration:0.5f animations:^{
                usageView.alpha = 1.0f;
            }];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == actionSheet.cancelButtonIndex) return;
    
    if ([MFMailComposeViewController canSendMail] == NO) {
        return;
    }
    
    NSData *attachmentData = nil;
    NSString *mimeType = nil;
    NSString *fileName = nil;
    NSDate *currentDate = [NSDate date];
    
    // Create Mail
    MFMailComposeViewController *vc = [[MFMailComposeViewController alloc] init];
	[vc setSubject:[NSString stringWithFormat:@"Vector Data from TouchPlt (%@)", [currentDate datetimeString]]];
    [vc setMailComposeDelegate:self];
    
    if (buttonIndex == 4) {
        attachmentData = [[TouchPltUtil createSvgString:canvasView] dataUsingEncoding:NSUTF8StringEncoding];
        mimeType = @"image/svg+xml";
        fileName = [NSString stringWithFormat:@"vectorData_%@.svg", [currentDate datetimeString]];
    } else {
        attachmentData = [[TouchPltUtil createPltString:canvasView exportType:(int)buttonIndex] dataUsingEncoding:NSUTF8StringEncoding];
        mimeType = @"text/plain";
        fileName = [NSString stringWithFormat:@"vectorData_%@.plt", [currentDate datetimeString]];
        
        // Capture canvasView
        canvasView.mode = 0;
        [canvasView setNeedsDisplay];
        UIGraphicsBeginImageContextWithOptions(canvasView.frame.size, YES, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(context, -canvasView.frame.origin.x, -canvasView.frame.origin.y);
        [canvasView.layer renderInContext:context];
        NSData *imageData = UIImageJPEGRepresentation(UIGraphicsGetImageFromCurrentImageContext(), 0.8);
        UIGraphicsEndImageContext();
        canvasView.mode = modeSegmentedControl.selectedSegmentIndex;
        [canvasView setNeedsDisplay];

        [vc addAttachmentData:imageData mimeType:@"image/jpeg" fileName:[NSString stringWithFormat:@"preview_%@.jpg", [currentDate datetimeString]]];
    }
    
    [vc addAttachmentData:attachmentData mimeType:mimeType fileName:fileName];

	[self.navigationController presentViewController:vc animated:YES completion:nil];
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result) {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"al_saved_m",nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"yes",nil), nil];
            [alert show];
        }
            break;
        case MFMailComposeResultSent:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"al_sent_m",nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"yes",nil), nil];
            [alert show];
        }
            break;
        case MFMailComposeResultFailed:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"al_not_sent_m",nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"yes",nil), nil];
            [alert show];
        }
            break;
        
        default:
            break;
    }
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            [canvasView deleteAll];
        }
    }
}

@end
