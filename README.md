
# smushkid #

--------------------------

A command utility that compresses images in the background for our customers. 
Outputs a JSON file with detailed information on the conversion, and a .txt
file listing the files processed.

### Installation

    $ gem install smushkid

### Usage

    $ smushkid path/to/directory desired_quality

### Example

    $ smushkid wp-content/uploads 75


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
