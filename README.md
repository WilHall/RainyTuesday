## RainyTuesday
A cocoa wrapper for the [RainyDay2 quartz screensaver](http://sribs.blogspot.com/2008/04/rainy-day-2.html) created by [@spaceribs](https://github.com/spaceribs).

### About
_**tl;dr;**_ *`.qtz` files don't work as screensavers anymore, this fixes that*  

This is essentially a cocoa screensaver which wraps the RainyDay2 quartz composition. It provides a configuration sheet and proxies configuration options to the composition, along with a screenshot of the current screen.

### Building
1. Download the project and open it in XCode
2. Drop `RainyDay2.qtz` inside `RainyTuesday/`
3. Build the project.

### Known Issues
1. Proper multiple display support. There are some rendering issues with multiple displays that I have yet to figure out. The common case is that all displays are rendered with a screenshot of the main display.
