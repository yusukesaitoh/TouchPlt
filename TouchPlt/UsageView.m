//
//  UsageView.m
//  TouchPlt
//
//  Created by Yusuke Saitoh on 2013/11/14.
//  Copyright (c) 2013年 Yusuke Saitoh. All rights reserved.
//

#import "UsageView.h"
#import "TouchPltUtil.h"

@interface UsageView ()
@end

@implementation UsageView
{
    UIButton *closeButton;
    UIScrollView *scrolView;
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp
{
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5f];
    self.alpha = 0;

    CGRect frame;
    
    UIButton *bgButton = [UIButton buttonWithType:UIButtonTypeCustom];
    bgButton.frame = self.bounds;
    [bgButton addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:bgButton];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.frame = CGRectMake(self.frame.size.width-80, 20, 80, 44);
        [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [closeButton setTitleColor:[UIColor yellowColor] forState:UIControlStateHighlighted];
        [closeButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
        [closeButton setTitle:NSLocalizedString(@"close", nil) forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
    }
    
    scrolView = [[UIScrollView alloc]init];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        scrolView.frame = CGRectMake(10, 64, self.frame.size.width-20, self.frame.size.height-74);
    else
        scrolView.frame = CGRectMake((self.frame.size.width-300)/2, 64, 300, self.frame.size.height-74);

    scrolView.backgroundColor = [UIColor whiteColor];
    [self addSubview:scrolView];
    
    float offsetY = 10;
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, offsetY, scrolView.frame.size.width, 30)];
    titleLabel.text = NSLocalizedString(@"usage_title", nil);
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:17];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [scrolView addSubview:titleLabel];
    offsetY += titleLabel.frame.size.height;
    
    UITextView *messageTextView = [[UITextView alloc]initWithFrame:CGRectMake(10, offsetY, scrolView.frame.size.width-20, 0)];
    messageTextView.text = NSLocalizedString(@"usage_message", nil);
    messageTextView.editable = NO;
    messageTextView.backgroundColor = [UIColor clearColor];
    [scrolView addSubview:messageTextView];
    frame = messageTextView.frame;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        CGSize size = [messageTextView.text sizeWithFont:messageTextView.font constrainedToSize:CGSizeMake(messageTextView.frame.size.width, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        frame.size.height = size.height+35;
    } else {
        frame.size.height = messageTextView.contentSize.height;
        
    }
    messageTextView.frame = frame;
    offsetY += messageTextView.frame.size.height;
    
    UIImageView *usageImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:NSLocalizedString(@"usage_img", nil)]];
    frame = usageImageView.frame;
    frame.origin.y = offsetY;
    usageImageView.frame = frame;
    [scrolView addSubview:usageImageView];
    offsetY += usageImageView.frame.size.height;

    scrolView.contentSize = CGSizeMake(scrolView.frame.size.width, offsetY);
    
    frame = scrolView.frame;
    frame.size.height = frame.size.height > scrolView.contentSize.height ? scrolView.contentSize.height : frame.size.height;
    scrolView.frame = frame;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        scrolView.center = self.center;

    
    [self statusbarHeightChanged];
}

- (void)touchUpInside:(id)sender
{
    [UIView animateWithDuration:0.5f animations:^{
        self
        .alpha = 0;
    }];
}

- (void)statusbarHeightChanged
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        CGRect rect = [[UIScreen mainScreen] applicationFrame];
        closeButton.frame = CGRectMake(self.frame.size.width-80, rect.origin.y, 80, 44);
        
        float svHeight = scrolView.frame.size.height > scrolView.contentSize.height ? scrolView.contentSize.height : scrolView.frame.size.height;
        scrolView.frame = CGRectMake(scrolView.frame.origin.x, closeButton.frame.size.height + closeButton.frame.origin.y, scrolView.frame.size.width, svHeight);
    }
}

@end
