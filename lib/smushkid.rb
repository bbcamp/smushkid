#!/usr/bin/env ruby
require 'find'
require 'RMagick'
require 'json'
require 'fileutils'

@quiet       = ARGV.delete('-q')
@make_backup = ARGV.delete('-b')
path         = ARGV[0]
@quality     = ARGV[1]

if File.directory?(path) 
  totalsavings = 0
  File.open("images_processed.json", "a+") { |f| f << "{ \"image_results\" : [ " }
  @multi = true
else
end

def process_file(file)
    simg = Magick::Image::read(file).first
    @source_image = {
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
    simg.strip!
    simg.quantize 32
    simg.write(@target_file) do
        self.quality = @quality.to_i
    end
    timg = Magick::Image::read(@target_file).first
    @target_image = {
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
    @savings =  @source_image['filesize'] - @target_image['filesize']
    @image_results = { "filename" => file, "savings" => @savings, "before" => @source_image, "after" => @target_image }
    puts "savings: " + @savings.to_s unless @quiet
    if @savings < 0
      @savings = 0
      puts "no space savings acheived deleting #{@target_file}" unless @quiet
      File.delete(@target_file)
    else
        if @make_backup
          puts "space savings! replacing with: #{file} and making backup or original: #{@backup_file}" unless @quiet
          puts "move #{@target_file} to #{file}" unless @quiet
          FileUtils.cp file, @backup_file
          File.rename @target_file, file
          File.open("images_processed.json", "a+") { |f| f << @image_results.to_json + ','}
        else
          puts "space savings! replacing with #{simg}" unless @quiet
          puts "move #{@target_file} to #{file}" unless @quiet
          File.rename @target_file, file
          File.open("images_processed.json", "a+") { |f| f << @image_results.to_json + ','}
        end
    end
end


Find.find(path) do |file|
  @target_file = File.dirname(file) + "/" + "smaller-" + File.basename(file)
  @backup_file = File.dirname(file) + "/" + "original-" + File.basename(file)
  if @multi
      pattern = '**' '/' '*.jpg'
      process_file(file) if File.fnmatch(pattern, file, File::FNM_CASEFOLD)
      File.open("images_processed_list.txt", "a+") { |f| f << file + "\n"}
  else
      pattern = '*.jpg'
      process_file(file) if File.fnmatch(pattern, file, File::FNM_CASEFOLD)
      puts @image_results.to_json
  end
  totalsavings = totalsavings.to_i + @savings.to_i
  puts "Total savings (in bytes): " + totalsavings.to_s unless @quiet
end
File.open("images_processed.json", "a+") { |f| f << "]}" } if File.directory?(path)
