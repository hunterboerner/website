require 'erb'
require 'redcarpet'
require 'rouge'
require 'rouge/plugins/redcarpet'

class HTML < Redcarpet::Render::HTML
  include Rouge::Plugins::Redcarpet
end

class Gen
  def files
    Dir.glob("./blog/*.md").sort
  end

  def as_size(s)
    units = %W(B KiB MiB GiB TiB)

    size, unit = units.reduce(s.to_f) do |(fsize, _), utype|
      fsize > 512 ? [fsize / 1024, utype] : (break [fsize, utype])
    end

    "#{size > 9 || size.modulo(1) < 0.1 ? '%d' : '%.1f'}%s" % [size, unit]
  end

  def blog_objects
    files.map do |file|
      history = `git log --format="%an %cd %h" --date=short #{file}`.
                split("\n").map(&:strip)

      content = File.read(file)
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
      {
        name: File.basename(file),
        title: title,
        raw: content,
        content: markdown.render(content),
        last_modified: history.first,
        created: history.last,
        size: size
      }
    end
  end

  def blog_to_html(posts)
    layout = File.read("post-template.erb")
    posts = posts.map do |post|
      b = binding
      name = post[:name]
      content = post[:content]
      title = post[:title]
      updated_at = post[:last_modified]
      created_at = post[:created]
      size = post[:size]
      ERB.new(layout).result(b)
    end

    posts.first.gsub('<hr>', '<span>' + '=' * 80 + '</span>')
  end

  def build
    b = binding
    ERB.new("").result(b)
  end
end

# puts Gen.new.files
# puts Gen.new.files.map { |file| File.basename(file) }
gen = Gen.new
blog_objects = gen.blog_objects
html = gen.blog_to_html(blog_objects)

File.open("demo.html", 'w') { |file| file.write(html) }