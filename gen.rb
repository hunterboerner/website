require 'erb'
require 'redcarpet'
require 'rouge'
require 'rouge/plugins/redcarpet'
require 'ostruct'

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

  def page_objects
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
        html: nil,
        updated_at: history.first,
        created_at: history.last,
        size: size,
        relative_location: "#{file.sub('./src', '')}\n"
      }
    end
  end

  def gen_pages_html(posts)
    layout = File.read("page-template.erb")
    posts.each do |post|
      post[:html] = ERB.new(layout).
                    result(OpenStruct.new(post).instance_eval { binding })
    end
    posts
    # posts.first[:html].gsub('<hr>', '<span>' + '=' * 80 + '</span>')
  end
end

gen = Gen.new
page_objects = gen.page_objects
pages = gen.gen_pages_html(page_objects)

pages.each do |page|

end

# File.open("demo.html", 'w') { |file| file.write(html) }
