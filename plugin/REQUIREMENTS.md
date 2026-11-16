# Requirements of the Roku plugin

# Features

## Feature 1 - Setting and Configuration
The plugin will have a settings page that will prompt for 
    * a base URL to access photos 
    * a delay (in seconds) between photos
All settings will be persisted on the Roku device

The default delay will be 15 seconds.

The settings page will open automatically when no server URL has been saved.
Otherwise, settings will be accessible through the normal application's Options
(`*`) button and through Roku's screensaver settings menu.

## Feature 2 - Basic slideshow behavior
This Roku plugin will run a basic slideshow of photos, with a configuraable delay between each photo.

### Feature 2.1 - Slideshow timing
The slideshow will have a delay between pictures being displayed. The delay will
begin when a photo finishes loading and is displayed. The delay will reset after
manual left/right navigation.

### Feature 2.2 - Picture rendering
The slideshow will render such that it will fit on the center of the screen without stretching.  On the dimension that is
smaller, use black background in order to maintain proper aspect ratio.

### Feature 2.3 Photo API 
The photos will be retrieved from the python application that hosts the pictures.  The next (and first) photo 
to render is retrieved via HTTP GET $baseUrl/next where $baseurl comes from the earlier settings/configuration
page.  The response is the raw bytes of the image.
When the slideshow needs to go backwards, the previous image can be retrieved via HTTP GET $baseUrl/prev

Changes to the Python server are out of scope for the current work.

### Feature 2.4 Navigation
These navigation controls apply only in normal application mode.

When the user presses the right arrow on the remote, the slideshow should immediately display the next photo
without waiting for the delay time to have expired.  When the user presses the left arrow, the slideshow should
immediately display the previous image displayed.  When the user presses the back button, the application should exit.

### Feature 2.5 - Loading failures
If a photo fails to load or the server is unavailable, the slideshow will retain
the last displayed image.

## Feature 3 - Screen saver
The Roku pligin should also supply the same slideshow behavior in screen saver mode.

In screensaver mode, any remote input will dismiss the screensaver. Left/right
photo navigation applies only in normal application mode.


