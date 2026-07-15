#!/usr/bin/env ruby
# frozen_string_literal: true

STYLE = <<~CSS

  .catalog-back{position:fixed;top:max(14px,env(safe-area-inset-top));left:max(14px,env(safe-area-inset-left));z-index:2147483647;width:44px;height:44px;border:1px solid rgba(255,255,255,.25);border-radius:999px;display:flex;align-items:center;justify-content:center;background:rgba(17,17,17,.82);color:#fff;text-decoration:none;font:600 25px/1 system-ui,-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif;box-shadow:0 4px 16px rgba(0,0,0,.22);backdrop-filter:blur(10px);-webkit-backdrop-filter:blur(10px);transition:transform .18s ease,background .18s ease}
  .catalog-back:hover{background:rgba(17,17,17,.95);transform:translateX(-2px)}
  .catalog-back:focus-visible{outline:3px solid #fff;outline-offset:3px}
  @media print{.catalog-back{display:none!important}}
  @media (max-width:720px){.catalog-back{top:max(10px,env(safe-area-inset-top));left:max(10px,env(safe-area-inset-left))}}
CSS

files = Dir.glob("**/*.html").reject { |file| File.basename(file) == "index.html" }
missing = []
updated = []

files.each do |file|
  html = File.read(file, encoding: "UTF-8")

  if html.include?('class="catalog-back"')
    html = html.gsub(
      /@media \(max-width:720px\)\{\.catalog-back\{width:42px;height:42px;font-size:24px;top:max\(10px,env\(safe-area-inset-top\)\);left:max\(10px,env\(safe-area-inset-left\)\)\}\}/,
      '@media (max-width:720px){.catalog-back{top:max(10px,env(safe-area-inset-top));left:max(10px,env(safe-area-inset-left))}}'
    )
    File.write(file, html, encoding: "UTF-8")
    next
  end

  missing << file
  next if ARGV.include?("--check")

  href = File.dirname(file) == "." ? "index.html" : "../index.html"
  control = %(<a class="catalog-back" href="#{href}" aria-label="Вернуться к каталогу" title="Вернуться к каталогу">←</a>)
  html = html.sub("</style></head><body>", "#{STYLE}</style></head><body>\n#{control}")
  raise "Не удалось добавить стрелку: #{file}" unless html.include?('class="catalog-back"')

  File.write(file, html, encoding: "UTF-8")
  updated << file
end

if ARGV.include?("--check")
  warn missing.join("\n") unless missing.empty?
  exit(missing.empty? ? 0 : 1)
end

puts "Стрелка добавлена: #{updated.length}; всего страниц: #{files.length}"
