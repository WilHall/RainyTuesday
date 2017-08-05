/**
 * Wil Hall
 *
 * See LICENSE
 */

#import "RainyTuesdayView.h"
#import "ScreenCaptureHelper.h"
#import <Quartz/Quartz.h>


@implementation RainyTuesdayView

static NSString * const ScreensaverModuleName = @"com.wilhall.RainyTuesday";
ScreenSaverDefaults *defaults;

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    
    if (self)
    {
        defaults = [ScreenSaverDefaults defaultsForModuleWithName:ScreensaverModuleName];
        
        // Register default screen saver options
        [defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                                    @(YES), @"optionEnableRain",
                                    @(YES), @"optionEnableClouds",
                                    @(1), @"optionCloudType",
                                    @(3), @"optionLightning",
                                    @(0.6), @"optionRainContrast",
                                    @(2000), @"optionRainAmount",
                                    nil]];
        
        [self setAnimationTimeInterval:1/30.0];
    }
    
    return self;
}

- (void)drawRect:(NSRect)rect
{
    // determine the current display ID
    const int maxDisplays = 32;
    CGDisplayCount displayCount;
    CGDirectDisplayID viewDisplayId;
    CGGetDisplaysWithPoint(self.window.screen.visibleFrame.origin, maxDisplays, &viewDisplayId, &displayCount);
    
    CGDirectDisplayID mainDisplayId = CGMainDisplayID();
    NSImage *screenCapture = [ScreenCaptureHelper screenCaptureOfDisplay:viewDisplayId scaledToSize: rect.size];
    
    NSBundle *bundle = [NSBundle bundleWithIdentifier:ScreensaverModuleName];
    NSString *qtzPath = [bundle pathForResource:@"RainyDay2" ofType:@"qtz"];
    
    QCView* qcView = [[QCView alloc] initWithFrame:self.frame];
    [self addSubview:qcView];
    [qcView unloadComposition];
    [qcView loadCompositionFromFile:qtzPath];
    
    [qcView setValue:screenCapture forInputKey:@"_protocolInput_ScreenImage"];
    [qcView setValue:@(self.isPreview) forInputKey:@"_protocolInput_PreviewMode"];
    [qcView setValue:@([defaults boolForKey:@"optionEnableRain"]) forInputKey:@"Enable_Rain"];
    [qcView setValue:@([defaults boolForKey:@"optionEnableClouds"]) forInputKey:@"Enable_Clouds"];
    [qcView setValue:@([defaults integerForKey:@"optionCloudType"]) forInputKey:@"Cloud_Type"];
    [qcView setValue:@([defaults integerForKey:@"optionLightning"]) forInputKey:@"Lightning"];
    [qcView setValue:@([defaults integerForKey:@"optionRainContrast"]) forInputKey:@"Rain_Contrast"];
    [qcView setValue:@([defaults integerForKey:@"optionRainAmount"]) forInputKey:@"Rain_Amount"];
    
    [qcView setMaxRenderingFrameRate: 30.0];
    [qcView startRendering];
    
    [super drawRect:rect];
}

- (NSWindow*)configureSheet
{
    if (!configSheet)
    {
        if (![[NSBundle mainBundle] loadNibNamed:@"ConfigureSheet" owner:self topLevelObjects: nil])
        {
            NSLog( @"Failed to load configure sheet." );
            NSBeep();
        }
    }
    
    [optionEnableRain setState:[defaults boolForKey:@"optionEnableRain"]];
    [optionEnableClouds setState:[defaults boolForKey:@"optionEnableClouds"]];
    [optionCloudType setIntegerValue: [defaults integerForKey:@"optionCloudType"]];
    [optionLightning setIntegerValue: [defaults integerForKey:@"optionLightning"]];
    [optionRainContrast setFloatValue: [defaults floatForKey:@"optionRainContrast"]];
    [optionRainAmount setIntegerValue: [defaults integerForKey:@"optionRainAmount"]];
    
    return configSheet;
}

- (IBAction)cancelClick:(id)sender
{
    [[NSApplication sharedApplication] endSheet:configSheet];
}

- (IBAction) okClick: (id)sender
{
    // Update our defaults
    [defaults setBool:[optionEnableRain state]
               forKey:@"optionEnableRain"];
    [defaults setBool:[optionEnableClouds state]
               forKey:@"optionEnableClouds"];
    [defaults setInteger:[optionCloudType integerValue]
                  forKey:@"optionCloudType"];
    [defaults setInteger:[optionLightning integerValue]
                  forKey:@"optionLightning"];
    [defaults setFloat:[optionRainContrast floatValue]
                forKey:@"optionRainContrast"];
    [defaults setInteger:[optionRainAmount integerValue]
                forKey:@"optionRainAmount"];
    
    // Save the settings to disk
    [defaults synchronize];
    
    // Close the sheet
    [[NSApplication sharedApplication] endSheet:configSheet];
}

- (void)animateOneFrame
{
    [self setNeedsDisplay: false];
}

- (BOOL)hasConfigureSheet
{
    return YES;
}

- (void)startAnimation
{
    [super startAnimation];
}

- (void)stopAnimation
{
    [super stopAnimation];
}

@end
