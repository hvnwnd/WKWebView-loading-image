//
// ViewController.m
// WebView
//
// Created by CHEN Bin on 10/10/16.
// Copyright © 2016 Allianz. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>

@interface ViewController () <WKScriptMessageHandler, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic) WKWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    WKUserContentController *contentController = [[WKUserContentController alloc] init];
    [contentController addScriptMessageHandler:self name:@"IOSHandler"];

    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.userContentController = contentController;

    _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
    [self.view addSubview:_webView];
    CGRect frame = self.view.bounds;
    frame.origin.y = 20.0;
    frame.size.height -= 20.0;
    _webView.frame      = frame;

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://192.168.2.141:8888/webview.html"]];
    [_webView loadRequest:request];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message;
{
    if ([message.name isEqualToString:@"IOSHandler"] && [message.body isEqualToString:@"photo1"]) {
        UIImagePickerController *vc = [[UIImagePickerController alloc] init];
        vc.sourceType = UIImagePickerControllerSourceTypeCamera;
        vc.delegate = self;
        [self presentViewController:vc animated:YES completion:^{
            
        }];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    NSData *data = UIImageJPEGRepresentation(image, 0.1);
    NSString *base64 = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    [_webView evaluateJavaScript:[NSString stringWithFormat: @"loadImage(\"%@\")" , base64] completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"Image length %@", result);
        [self dismissViewControllerAnimated:YES completion:NULL];
    }];
}

@end
