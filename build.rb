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
  writing = file.start_with?("writing/")
  page = {
    file: file,
    slug: slug,
    writing: writing,
    url: slug == "hjem" ? "/" : "/#{slug}/",
    title: front["title"] || slug,
    type: front["type"],
    author: front["author"],
    year: front["year"],
    date: front["date"],
    rating: front["rating"],
    link: front["link"],
    body: markdown.render(body)
  }
  template = if writing
               front["type"] == "movie-review" ? "movie_review.erb" : "book_review.erb"
             end
  page[:html] = writing ? render.call(template, page: page) : page[:body]
  page
end

writings = pages.select { |page| page[:writing] }.sort_by { |page| page[:date] }.reverse
others = pages.reject { |page| page[:writing] }
home = others.find { |page| page[:slug] == "hjem" }

feed_html = render.call("feed.erb", writings: writings)
home[:html] = "#{home[:html]}<br />#{feed_html}"

FileUtils.rm_rf(DIST)
FileUtils.mkdir_p(DIST)

(others + writings).each do |page|
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

puts "Built #{others.length} pages + #{writings.length} writings into dist/"
