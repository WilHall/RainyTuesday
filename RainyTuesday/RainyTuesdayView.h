/**
 * Wil Hall
 *
 * See LICENSE
 */

#import <ScreenSaver/ScreenSaver.h>

@interface RainyTuesdayView : ScreenSaverView
{
    IBOutlet id configSheet;
    IBOutlet NSButton* optionEnableRain;
    IBOutlet NSButton* optionEnableClouds;
    IBOutlet id optionCloudType;
    IBOutlet id optionLightning;
    IBOutlet id optionRainContrast;
    IBOutlet id optionRainAmount;
}

@end
