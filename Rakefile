#                                                                 -*- ruby -*-

require 'rubygems'
require 'rake/clean'

CLEAN << ['css', '_site']

version = '>= 0'
gem 'jekyll', version

task :default => :jekyll

task :jekyll => :css do |t|
  load Gem.bin_path('jekyll', 'jekyll', version)
end

# Generate CSS files from SCSS files

SASS_DIR = 'sass'
CSS_DIR = 'css'

directory 'stylesheets'

SASS_FILES = FileList["#{SASS_DIR}/*.scss"]
CSS_OUTPUT_FILES = SASS_FILES.map do |f|
  f.gsub(/^#{SASS_DIR}/, CSS_DIR).gsub(/\.scss$/, '.css')
end

# Figure out the name of the SCSS file necessary make a CSS file.
def css_to_scss
  Proc.new {|task| task.sub(/^#{CSS_DIR}/, SASS_DIR).sub(/\.css$/, '.scss')}
end

rule %r{^#{CSS_DIR}/.*\.css$} => [css_to_scss, 'Rakefile'] do |t|
  require 'sass'
  mkdir_p CSS_DIR
  puts("#{t.source} -> #{t.name}")
  Dir.chdir('sass') do
    sass_input = File.basename(t.source)
    engine = Sass::Engine.new(File.open(sass_input).readlines.join(''),
                              :syntax => :scss)
    out = File.open(File.join('..', t.name), 'w')
    out.write("/* AUTOMATICALLY GENERATED FROM #{t.source} on #{Time.now} */\n")
    out.write(engine.render)
    # Force close, to force flush BEFORE running other tasks.
    out.close
  end
end

task :css => CSS_OUTPUT_FILES

