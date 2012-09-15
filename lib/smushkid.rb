#!/usr/bin/env ruby
require 'find'
require 'RMagick'
require 'json'
require 'fileutils'

@quiet       = ARGV.delete('-q')
@make_backup = ARGV.delete('-b')
@exif_tag    = ARGV.delete('-e')
path         = ARGV[0]
@quality     = ARGV[1]

if File.directory?(path)
  totalsavings = 0
  File.open("images_processed.json", "a+") { |f| f << "{ \"image_results\" : [ " }
  @multi = true
else
end

def already_done?(file)
    simg = Magick::Image::read(file).first
    puts "checking for EXIF value"
    simg.properties.has_value?("smushkid")
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
      puts "tagging original file" unless @quiet
      @quoted_filename = "\"#{file}\""
      %x(/usr/local/bin/jhead -cl \"smushkid\" #{@quoted_filename}) if @exif_tag
      File.delete(@target_file)
    else
        if @make_backup
          puts "space savings! replacing with: #{simg} and making backup or original: #{@backup_file}" unless @quiet
          puts "tagging target file" unless @quiet
          %x(/usr/local/bin/jhead -cl \"smushkid\" #{@quoted_filename}) if @exif_tag
          puts "move #{@target_file} to #{file}" unless @quiet
          FileUtils.cp file, @backup_file
          File.rename @target_file, file
          File.open("images_processed.json", "a+") { |f| f << @image_results.to_json + ','}
        else
          puts "space savings! replacing with #{simg}" unless @quiet
          puts "tagging target file" unless @quiet
          %x(/usr/local/bin/jhead -cl \"smushkid\" #{@quoted_filename}) if @exif_tag
          puts "move #{@target_file} to #{file}" unless @quiet
          File.rename @target_file, file
          File.open("images_processed.json", "a+") { |f| f << @image_results.to_json + ','}
        end
    end
end


Find.find(path) do |file|
  @target_file = File.dirname(file) + "/" + "smaller-" + File.basename(file)
  @quoted_filename = "\"#{@target_file}\""
  @backup_file = File.dirname(file) + "/" + "original-" + File.basename(file)
  puts "processing #{file}" unless @quiet
  if @multi
      pattern1 = "**" "/" "*.jpg"
      pattern2 = "**" "/" "*.jpeg"
      if File.fnmatch(pattern1, file, File::FNM_CASEFOLD) || File.fnmatch(pattern2, file, File::FNM_CASEFOLD)
          if already_done?(file)
              puts "EXIF signature detected, skipping." unless @quiet
          else
              puts "EXIF data not found attempting compression..." unless @quiet
              process_file(file)
          end
        File.open("images_processed_list.txt", "a+") { |f| f << file + "\n"}
      else
          puts "no file match" unless @quiet
      end
  else
      pattern1 = '*.jpg'
      pattern2 = '*.jpeg'
      if File.fnmatch(pattern1, file, File::FNM_CASEFOLD) || File.fnmatch(pattern2, file, File::FNM_CASEFOLD)
          if already_done?(file)
              puts "EXIF signature detected, skipping." unless @quiet
          else
              puts "EXIF data not found attempting compression..." unless @quiet
              process_file(file)
          end
      puts @image_results.to_json
      else
          puts "no file match" unless @quiet
      end
  end
  totalsavings = totalsavings.to_i + @savings.to_i
  puts "Total savings (in bytes): " + totalsavings.to_s unless @quiet
end
File.open("images_processed.json", "a+") { |f| f << "]}" } if File.directory?(path)
