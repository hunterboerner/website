require 'erb'
require 'redcarpet'
require 'rouge'
require 'rouge/plugins/redcarpet'
require 'ostruct'
require 'fileutils'

class HTML < Redcarpet::Render::HTML
  include Rouge::Plugins::Redcarpet
end

class Gen
  def files
    Dir.glob("./src/**/*.md").sort
  end

  def as_size(s)
    units = %W(B KiB MiB GiB TiB)

    size, unit = units.reduce(s.to_f) do |(fsize, _), utype|
      fsize > 512 ? [fsize / 1024, utype] : (break [fsize, utype])
    end

    "#{size > 9 || size.modulo(1) < 0.1 ? '%d' : '%.1f'}%s" % [size, unit]
  end

  def sitemap
    files = {}
    Dir["src/**/*"].sort.each do |file|
      next if File.directory?(file)
      file.slice!("src/")
      dirname = File.dirname(file)
      if files[dirname]
        files[dirname] << [File.basename(file, ".md"), file]
      else
        files[dirname] = []
        files[dirname] << [File.basename(file, ".md"), file]
      end
    end

    sitemap = ""

    if files["."]
      files["."].each do |file|
        sitemap << "<a href=\"#{file[1].sub(/\.md$/, '')}.html\">#{file[0]}</a>\n"
      end
      files.delete(".")
      sitemap << "\n\n"
    end

    files.each do |dir, files|
      sitemap << "#{dir}:\n"
      sitemap << "  "
      files.each do |file|
        sitemap << "<a href=\"#{file[1].sub(/\.md$/, '')}.html\">#{file[0]}</a>\n  "
      end
      sitemap << "\n\n"
    end
    sitemap.strip
  end

  def page_objects
    files.map do |file|
      history = `git log --format="%an %cd %h" --date=short #{file}`.
                split("\n").map(&:strip)

      content = File.read(file)
      # Add sitemap here
      content.sub!("<!-- sitemap -->", sitemap)
      size = "Stats: " \
             "#{as_size(File.size(file))} -- " \
             "#{content.scan(/[[:alpha:]]+/).count} Word(s) -- " \
             "#{content.lines.count} Line(s)"
      title = content.lines.first.chomp
      title.sub!(/^#/, '').strip!
      content = content.lines[1..-1].join
      markdown = Redcarpet::Markdown.new(HTML,
                                         autolink: true,
                                         fenced_code_blocks: true,
                                         tables: true,
                                         footnotes: true,
                                         strikethrough: true)
      relative_location = "#{file.sub('./src/', '')}"
      {
        name: File.basename(file),
        title: title,
        raw: content,
        content: markdown.render(content),
        html: nil,
        updated_at: history.first,
        created_at: history.last,
        size: size,
        relative_location: relative_location,
        path_to_root: '../' * relative_location.count('/')
      }
    end
  end

  def gen_pages_html(posts)
    layout = File.read("page-template.erb")
    posts.each do |post|
      post[:html] = ERB.new(layout).
                    result(OpenStruct.new(post).instance_eval { binding })
      post[:html].gsub!('<hr>', "<span>#{'=' * 80}</span>")
    end
    posts
  end
end

gen = Gen.new
page_objects = gen.page_objects
pages = gen.gen_pages_html(page_objects)

begin
  FileUtils.remove_dir("./build")
rescue
end

pages.each do |page|
  FileUtils.mkdir_p("./build/#{File.dirname(page[:relative_location])}")
  loc = page[:relative_location].sub(/\.md$/, '')
  File.open("./build/#{loc}.html", "w") { |file| file.write(page[:html]) }
end

FileUtils.cp_r(Dir.glob("assets/*"), "build", :verbose => true)
