#!/usr/bin/env ruby

require 'find'
require 'RMagick'
require 'json'
totalsavings = 0
Find.find('uploads') do |file|
  pattern = '**' '/' '*.jpg'
  if File.fnmatch(pattern, file, File::FNM_CASEFOLD)
    puts "matched: #{file}"
    simg = Magick::Image::read(file).first
    source_image = {
             'format' => simg.format,
             'filesize' => simg.filesize,
             'geometry_cols' => simg.columns,
             'geometry_rows' => simg.rows,
             'resolution_x' =>  simg.x_resolution.to_i,
             'resolution_y' => simg.y_resolution.to_i,
             'depth' =>  simg.depth,
             'colors' => simg.number_colors,
             'ppi' => simg.units
    }
    target_file = File.dirname(file) + "/" + "smaller-" + File.basename(file)
    simg.strip!
    simg.write(target_file) do
      # maybe doing this wrong?  seems to make file bigger
      # something with unknow pixel density
      #self.compression = Magick::LosslessJPEGCompression
      self.quality = 90
    end
    timg = Magick::Image::read(target_file).first
    target_image = {
             'format' => timg.format,
             'filesize' => timg.filesize,
             'geometry_cols' => timg.columns,
             'geometry_rows' => timg.rows,
             'resolution_x' =>  timg.x_resolution.to_i,
             'resolution_y' => timg.y_resolution.to_i,
             'depth' =>  timg.depth,
             'colors' => timg.number_colors,
             'ppi' => timg.units
    }
    @savings =  source_image['filesize'] - target_image['filesize']
    image_results = { 'filename' => file, 'savings' => @savings, 'before' => source_image, 'after' => target_image }
    puts "savings:"
    puts @savings
    if @savings < 0
      @savings = 0
      puts "no space savings acheived deleting #{target_image}"
      File.delete(target_file)
    else
      puts "space savings! replacing with #{simg}"
      puts "move #{target_file} to #{file}"
      File.rename target_file, file
    end
    File.open("imageprocessed.json", "a+") { |f| f << image_results.to_json}
    File.open("savings.txt", "a+") { |f| f << @savings.to_s + "\n"}
  else
    puts "no match: #{file}"
  end
  totalsavings = totalsavings + @savings.to_i
  puts "RUNNING TOTAL"
  puts totalsavings
end


