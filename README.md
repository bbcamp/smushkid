
# smushkid #

--------------------------

A command utility that compresses images in the background for our customers. 
Outputs a JSON file with detailed information on the conversion, and a .txt
file listing the files processed.

### Requirements

You'll need the RMagick gem installed first, on OSX you may need to install imagemagick before you can do that. 

#### Meeting the requirements on Mountain Lion

    $ gem install rmagick

If this complains about imagemagick not being found, install Homebrew (http://mxcl.github.com/homebrew/)

    $ brew install imagemagick

To use the EXIF option, you must have jhead installed, see below for more
information


### Installation

    $ gem install smushkid

### Options

    -q no STDOUT ( except for single file JSON )
    -b create backup of any optimized files  ( prefixes with original- )
    -e add EXIF tag to prevent double processing ( must have jhead installed )

### Usage

    $ smushkid path/to/directory desired_quality -b -q -e

### Example

    $ smushkid wp-content/uploads 75

### EXIF

to prevent double processing on subsequent script runs, tag the EXIF metadata
with the string "smushkid" using jhead:
<http://www.sentex.net/~mwandel/jhead/>

GH mirror here: <https://github.com/oelbrenner/jhead>

eventually this would be nice to have baked-into RMagick or at least use a ruby
wrapper like this one:
<https://github.com/oelbrenner/jhead-ruby>

directory = directory you want to process JPG images in

desired_quality = JPG compression value ( or % quality )

### information:

this script strips metadata from the source image, then quantizies the color
map at 32 bit, and compresses to desired quality level.

#### Information about RMagick here:

<http://www.imagemagick.org/RMagick/doc/usage.html>

#### Read more about image quantization:
<http://www.imagemagick.org/Usage/quantize/#colors>

<http://www.imagemagick.org/RMagick/doc/ilist.html#quantize>

<http://www.impulseadventure.com/photo/jpeg-quantization.html>
