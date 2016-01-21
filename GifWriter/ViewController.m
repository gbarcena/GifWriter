//
//  ViewController.m
//  GifWriter
//
//  Created by Gustavo Barcena on 9/28/14.
//  Copyright (c) 2014 GDB. All rights reserved.
//

@import MobileCoreServices;
@import ImageIO;
@import MessageUI;

#import "ViewController.h"
#import "YLGIFImage.h"
#import "YLImageView.h"
#import "GifWriter-Swift.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet YLImageView *imageView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) NSMutableArray *images;
@property (strong, nonatomic) GIFWriter *gifWriter;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.images = @[].mutableCopy;
    for (int i = 1; i <= 7; i++) {
        NSString *imageName = [NSString stringWithFormat:@"ninenine_%d", i];
        [self.images addObject:[UIImage imageNamed:imageName]];
    }
    
    self.gifWriter = [[GIFWriter alloc] initWithImages:self.images frameDelay:0.25];
}

-(IBAction)makeGIFPressed:(id)sender
{
    self.label.text = @"Start Writing";
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        __weak typeof(self) weakSelf = self;
        [self.gifWriter setProgressBlock:^(NSInteger frameIndex, NSInteger frameCount) {
            weakSelf.progressView.progress = (float)frameIndex/frameCount;
        }];
        
        [self.gifWriter makeGIF:[self fileLocation]];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.label.text = @"End Writing";
            self.imageView.image = [YLGIFImage imageWithContentsOfFile:[self filePath]];
        });
    });
}

#pragma mark - GIF File Location Methods

-(NSString *)filePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectoryURL = [paths objectAtIndex:0];
    NSString *path = [cacheDirectoryURL  stringByAppendingPathComponent:@"gifs"];
    NSError *error;
    [[NSFileManager defaultManager] createDirectoryAtPath:path
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
    NSString *fileName = [NSString stringWithFormat:@"ninenine.gif"];
    NSString *filePath = [path stringByAppendingPathComponent:fileName];
    return filePath;
}

-(NSURL *)fileLocation
{
    NSString *filePath = [self filePath];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    return fileURL;
}

@end
 