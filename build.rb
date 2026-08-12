#!/usr/bin/env ruby
# frozen_string_literal: true

# Builds the static site into dist/ for GitHub Pages.
#
#   ruby build.rb
#
# Content:  markdown files under content/, filesystem hierarchy maps to URLs.
# Templates: ERB files under templates/.
# Static:   copied verbatim into dist/ (CNAME, .nojekyll, favicon, ...).
# Assets:   non-markdown files under content/ are copied as-is.
# Front matter: a `---\nkey: value` block at the top of a content file.

require "erb"
require "fileutils"
require "redcarpet"

ROOT      = File.expand_path(__dir__)
CONTENT   = File.join(ROOT, "content")
TEMPLATES = File.join(ROOT, "templates")
STATIC    = File.join(ROOT, "static")
DIST      = File.join(ROOT, "dist")

markdown = Redcarpet::Markdown.new(
  Redcarpet::Render::HTML,
  autolink: true,
  no_intra_emphasis: true,
  fenced_code_blocks: true,
  tables: true
)

site = {
  title: "ANDREAS HJEMMESIDE",
  nav: [
    { title: "hjem", url: "/" },
    { title: "filmer", url: "/filmer/" },
    { title: "bøker", url: "/boker/" },
    { title: "frilans", url: "/frilans/" },
    { title: "foto", url: "https://foto.aeide.no", external: true },
    { title: "github", url: "https://github.com/aaaeide/", external: true },
    { title: "linkedin", url: "https://www.linkedin.com/in/andreas-aaberge-eide-513078151/", external: true }
  ]
}

def parse_front_matter(content)
  return [{}, content] unless content.start_with?("---\n")

  header, body = content.sub(/\A---\n/, "").split("\n---", 2)
  data = header.lines.each_with_object({}) do |line, hash|
    key, value = line.chomp.split(": ", 2)
    value = value.strip if value
    hash[key] = value unless value.nil? || value.empty?
  end
  [data, body]
end

def esc(text)
  text.to_s.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;").gsub('"', "&quot;")
end

def writing_meta(writing)
  main = if writing[:type] == "movie-review"
           writing[:year] && "<span class=\"year\">#{esc(writing[:year])}</span>"
         else
           writing[:author] && "<span class=\"author\">#{esc(writing[:author])}</span>"
         end
  rating = writing[:rating] && "<span class=\"rating\">#{esc(writing[:rating])}/5</span>"
  [main, rating].compact.join(" · ")
end

def render_writing_header(writing)
  "<header><a href=\"#{esc(writing[:url])}\">#{esc(writing[:title])}</a>" \
    "<time datetime=\"#{esc(writing[:date])}\">#{esc(writing[:date])}</time></header>" \
    "<div class=\"meta\">#{writing_meta(writing)}</div>"
end

render = lambda do |name, locals|
  ERB.new(File.read(File.join(TEMPLATES, name)), trim_mode: "-")
     .result_with_hash(locals)
end

pages = Dir.glob(File.join(CONTENT, "**", "*.md")).map do |path|
  file = path.delete_prefix("#{CONTENT}/")
  slug = file.sub(/\.md\z/, "")
  front, body = parse_front_matter(File.read(path))
  kind = if file.start_with?("filmer/")
           :movie
         elsif file.start_with?("boker/")
           :book
         else
           :page
         end
  image = front["image"]
  dir = File.dirname(file)
  dir = "" if dir == "."
  base = image && File.basename(image, ".*")
  page = {
    file: file,
    slug: slug,
    kind: kind,
    url: slug == "hjem" ? "/" : "/#{slug}/",
    title: front["title"] || slug,
    type: front["type"],
    author: front["author"],
    year: front["year"],
    date: front["date"],
    rating: front["rating"],
    link: front["link"],
    image: image,
    image_url: image && (dir.empty? ? "/#{image}" : "/#{dir}/#{image}"),
    thumb_url: image && (dir.empty? ? "/#{base}-thumb.jpg" : "/#{dir}/#{base}-thumb.jpg"),
    image_src: image && File.join(CONTENT, dir, image),
    thumb_dest: image && File.join(DIST, dir, "#{base}-thumb.jpg"),
    body: markdown.render(body)
  }
  template = case kind
             when :movie then "movie_review.erb"
             when :book then "book_review.erb"
             else "page.erb"
             end
  page[:html] = render.call(template, page: page)
  page
end

movies = pages.select { |page| page[:kind] == :movie }.sort_by { |page| page[:date].to_s }.reverse
books = pages.select { |page| page[:kind] == :book }.sort_by { |page| page[:date].to_s }.reverse
others = pages.reject do |page|
  page[:kind] == :movie || page[:kind] == :book || %w[filmer.md boker.md].include?(page[:file])
end
home = others.find { |page| page[:slug] == "hjem" }

read_intro = lambda do |name|
  path = File.join(CONTENT, name)
  return "" unless File.exist?(path)

  _front, body = parse_front_matter(File.read(path))
  slug = name.sub(/\.md\z/, "")
  page = { file: name, title: name, url: "/#{slug}/", body: markdown.render(body) }
  render.call("page.erb", page: page)
end

filmer_page = {
  slug: "filmer",
  url: "/filmer/",
  title: "filmer",
  html: "#{read_intro.call("filmer.md")}<br />#{render.call("list.erb", heading: "filmer", items: movies)}"
}
boker_page = {
  slug: "boker",
  url: "/boker/",
  title: "bøker",
  html: "#{read_intro.call("boker.md")}<br />#{render.call("list.erb", heading: "bøker", items: books)}"
}

recent = (movies + books).sort_by { |page| page[:date].to_s }.reverse.first(20)
feed_html = render.call("feed.erb", writings: recent, heading: "siste nytt")
home[:html] = "#{home[:html]}<br />#{feed_html}"

FileUtils.rm_rf(DIST)
FileUtils.mkdir_p(DIST)

(others + [filmer_page, boker_page] + movies + books).each do |page|
  output = page[:slug] == "hjem" ? "index.html" : File.join(page[:slug], "index.html")
  dest = File.join(DIST, output)
  FileUtils.mkdir_p(File.dirname(dest))
  File.write(dest, render.call("layout.erb", site: site, page: page))
end

Dir.children(STATIC).each do |entry|
  FileUtils.cp_r(File.join(STATIC, entry), DIST)
end

Dir.glob(File.join(CONTENT, "**/*")).each do |path|
  next if File.directory?(path) || path.end_with?(".md")

  rel = path.delete_prefix("#{CONTENT}/")
  dest = File.join(DIST, rel)
  FileUtils.mkdir_p(File.dirname(dest))
  FileUtils.cp(path, dest)
end

THUMB_CACHE = File.join(ROOT, ".thumb-cache")
THUMB_VERSION = "320q70"
FileUtils.mkdir_p(THUMB_CACHE)
im = ["magick", "convert"].find { |c| !`which #{c} 2>/dev/null`.strip.empty? }
if im
  pages.each do |p|
    next unless p[:image_src] && File.exist?(p[:image_src])

    key = p[:image_src].delete_prefix("#{ROOT}/").gsub("/", "_")
    cached = File.join(THUMB_CACHE, "#{key}.#{THUMB_VERSION}.jpg")
    unless File.exist?(cached) && File.mtime(cached) >= File.mtime(p[:image_src])
      system(im, p[:image_src], "-resize", "320x", "-quality", "70", cached)
    end
    FileUtils.mkdir_p(File.dirname(p[:thumb_dest]))
    FileUtils.cp(cached, p[:thumb_dest])
  end
else
  warn "warning: ImageMagick not found — skipping thumbnail generation"
end

puts "Built #{others.length} pages + #{movies.length} movies + #{books.length} books into dist/"
