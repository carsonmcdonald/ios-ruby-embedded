## About

This is a project that will build the current mruby source into a XCode
framework. That framework can then be used to embed Ruby into an iOS
application.

This is not an attempt to make a bridge between Objective-C and Ruby, if you
want that then check out the [mobiruby](http://mobiruby.org/) project.

## Build

* git clone git://github.com/carsonmcdonald/ios-ruby-embedded.git
* cd ios-ruby-embedded
* git submodule init
* git submodule update
* rake

After the above steps you should have a complete MRuby.framework framework
structure that is ready to use.

## Install

To install the framework in an XCode project follow these steps (these steps
assume XCode 5.0.0):

* Select the top of the project on the left hand project display
* Select the "Build Phases" tab in the project details
* Click the + button under the "Link Binary With Libraries" dropdown
* Select "Add Other..." from the framework add popup
* Navigate to the MRuby.framework direcotry in the file browser and click
  "Open"

## Example Use

Assume you have the following simple Ruby script you want to execute:

```
puts "Hello world"
```

First you need to compile the script into byte code using the mrbc command
that can be found in the bin directory after you have compiled the project:

```
mrbc helloworld.rb
```

The output of that command is a bytecode file that can be run using the mruby
command found in the same bin directory. NB you currently need to cat all your
script files together before compiling the, using require doesn't work.

Once you have compiled your Ruby code and added it to your application bundle
you can embed it in your app using something like the following code:

```
#include "mruby/mruby.h"
#include "mruby/mruby/proc.h"
#include "mruby/mruby/dump.h"

// ...

    NSString *bcfile = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"helloworld.mrb"];
    
    mrb_state *mrb = mrb_open();    
    FILE *fp = fopen([bundleLocation UTF8String], "rb");
    if (fp == NULL) {
        NSLog(@"Error loading file...");
    } else {
        int n = mrb_read_irep_file(mrb, fp);
        fclose(fp);
        
        mrb_run(mrb, mrb_proc_new(mrb, mrb->irep[n]), mrb_top_self(mrb));
    }
```

## Notes

* mruby is new and changing constantly, don't be surprised if this project
  doesn't build.
* Currently you can't use the mruby compiler while embedded in an arm7 device.
  That is why you need to pre-compile the code using mrbc. It will work on the 
  simulator but don't let that fool you into thinking it will work on a device. 
  An app created to compile code would almost certainly have other issues.

## License

MIT to match the mruby license. See the LICENSE file for full license.
