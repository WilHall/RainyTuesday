/**
 * Wil Hall
 *
 * See LICENSE
 */

#import <Foundation/Foundation.h>


@interface ScreenCaptureHelper : NSObject

+ (NSImage *)screenCaptureOfDisplay: (CGDirectDisplayID) displayId scaledToSize: (NSSize) screenCaptureSize;
@end
