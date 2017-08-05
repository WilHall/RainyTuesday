/**
 * Wil Hall
 *
 * See LICENSE
 */

#import "ScreenCaptureHelper.h"
#import <AppKit/AppKit.h>

/**
 * This class contains code from
 * https://developer.apple.com/library/mac/#samplecode/SonOfGrab/Listings/Controller_m.html
 * With modifications from Tae Won Ha https://github.com/qvacua
 */


NSString *kAppNameKey = @"applicationName";
NSString *kWindowIDKey = @"windowID";
NSString *kWindowLevelKey = @"windowLevel";
NSString *kWindowOrderKey = @"windowOrder";

typedef struct {
    __unsafe_unretained NSMutableArray *outputArray;
    int order;
} WindowListData;

@implementation ScreenCaptureHelper { }

+ (NSImage *)resizedImage:(NSImage *)sourceImage toPixelDimensions:(NSSize)newSize
{
    if (!sourceImage.isValid) return nil;
    
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc]
                             initWithBitmapDataPlanes:NULL
                             pixelsWide:newSize.width
                             pixelsHigh:newSize.height
                             bitsPerSample:8
                             samplesPerPixel:4
                             hasAlpha:YES
                             isPlanar:NO
                             colorSpaceName:NSCalibratedRGBColorSpace
                             bytesPerRow:0
                             bitsPerPixel:0];
    rep.size = newSize;
    
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:rep]];
    [sourceImage drawInRect:NSMakeRect(0, 0, newSize.width, newSize.height) fromRect:NSZeroRect operation:NSCompositingOperationCopy fraction:1.0];
    [NSGraphicsContext restoreGraphicsState];
    
    NSImage *newImage = [[NSImage alloc] initWithSize:newSize];
    [newImage addRepresentation:rep];
    return newImage;
}

+ (NSImage *)screenCaptureOfDisplay: (CGDirectDisplayID) displayId scaledToSize: (NSSize) screenCaptureSize   {
    // get a list of on-screen windows from the window server
    CFArrayRef windowList = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly, kCGNullWindowID);
    
    // clone the list into a mutable array and create a WindowListData object to track
    // information about the window list
    NSMutableArray* windowArray = [[NSMutableArray alloc] initWithCapacity:32];
    WindowListData windowListData = {windowArray, 0};
    
    // loop through the window list so we can filter out windows we don't want
    for (int i = (int)(CFArrayGetCount(windowList)-1); i >= 0; i--) {
        NSDictionary *windowInfoDictionary = (__bridge NSDictionary *) CFArrayGetValueAtIndex(windowList, i);
        
        // if we get a window back that we don't have permission to read, skip it
        if ([windowInfoDictionary[(id) kCGWindowSharingState] intValue] == kCGWindowSharingNone) {
            continue;
        }
        
        NSMutableDictionary *windowListEntry = [NSMutableDictionary dictionary];
        
        // get the application name and pid; if no application name exists, use a placeholder
        NSString *applicationName = windowInfoDictionary[(id) kCGWindowOwnerName];
        if (applicationName != NULL) {
            NSString *nameAndPID = [NSString stringWithFormat:@"%@ (%@)", applicationName, windowInfoDictionary[(id) kCGWindowOwnerPID]];
            windowListEntry[kAppNameKey] = nameAndPID;
        } else {
            NSString *nameAndPID = [NSString stringWithFormat:@"((unknown)) (%@)", windowInfoDictionary[(id) kCGWindowOwnerPID]];
            windowListEntry[kAppNameKey] = nameAndPID;
        }
        
        // get the bounds of this window
        CGRect windowBounds;
        CGRectMakeWithDictionaryRepresentation((CFDictionaryRef) windowInfoDictionary[(id) kCGWindowBounds], &windowBounds);
        
        // get the display ID of this window.
        // we do this by finding the display which contains the origin point of the window's bounds
        const int maxDisplays = 32;
        CGDisplayCount displayCount;
        CGDirectDisplayID windowDisplayId;
        CGGetDisplaysWithPoint(windowBounds.origin, maxDisplays, &windowDisplayId, &displayCount);
        
        // if the window wasn't on the specified display, skip it
        if ((int)windowDisplayId != (int)displayId) {
            continue;
        }
        
        // Grab the Window ID & Window Level. Both are required, so just copy from one to the other
        windowListEntry[kWindowIDKey] = windowInfoDictionary[(id) kCGWindowNumber];
        windowListEntry[kWindowLevelKey] = windowInfoDictionary[(id) kCGWindowLayer];
        
        // Finally, we are passed the windows in order from front to back by the window server
        // Should the user sort the window list we want to retain that order so that screen shots
        // look correct no matter what selection they make, or what order the items are in. We do this
        // by maintaining a window order key that we'll apply later.
        windowListEntry[kWindowOrderKey] = @(windowListData.order);
        windowListData.order++;
        
        [windowListData.outputArray addObject:windowListEntry];
    }
    
    CFRelease(windowList);
    
    __block CGWindowID bottomIrrelevantWindowId = 0;
    __block NSInteger maxWindowLevel = -1;
    __block NSInteger maxWindowOrder = -1;
    
    [windowArray enumerateObjectsUsingBlock:^(NSDictionary *windowInfo, NSUInteger index, BOOL *stop) {
        NSString *appName = windowInfo[kAppNameKey];
        NSInteger windowLevel = [windowInfo[kWindowLevelKey] integerValue];
        NSInteger windowOrder = [windowInfo[kWindowOrderKey] integerValue];
        
        NSRange loginWindowNameRange = [appName rangeOfString:@"loginwindow"];
        NSRange screenSaverNameRange = [appName rangeOfString:@"ScreenSaverEngine"];
        
        if (loginWindowNameRange.location == NSNotFound && screenSaverNameRange.location == NSNotFound) {
            return;
        }
        
        if (windowLevel > maxWindowLevel || windowOrder > maxWindowOrder) {
            maxWindowLevel = windowLevel;
            bottomIrrelevantWindowId = (CGWindowID) [windowInfo[kWindowIDKey] intValue];
        }
    }];
    
    CGRect displayBounds = CGDisplayBounds(displayId);
    CGImageRef cgImageRef = CGWindowListCreateImage(displayBounds, kCGWindowListOptionOnScreenBelowWindow, bottomIrrelevantWindowId, kCGWindowImageDefault);
    NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:cgImageRef];
    NSImage *screenCapture = [[NSImage alloc] init];
    [screenCapture addRepresentation:bitmapRep];
    CGImageRelease(cgImageRef);
    
    NSImage* scaledScreenCapture = [self resizedImage:screenCapture toPixelDimensions:screenCaptureSize];
    
    return scaledScreenCapture;
}

@end
