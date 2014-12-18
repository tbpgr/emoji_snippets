require 'open-uri'
require 'nokogiri'
require 'erb'

module Emoji
  module SublimeText
    URL = 'http://www.emoji-cheat-sheet.com/'
    OUTPUT_DIR = 'emoji_snippets'
    OUTPUT_SAMPLE_DIR = 'emoji_samples'

    class Generator
      def self.bulk_output(klasses)
        Dir.mkdir(OUTPUT_DIR) unless Dir.exist?(OUTPUT_DIR)
        klasses.each do |klass|
          # 記号付きの emoji 名は例外的な処理が必要なので手動で対応
          next if %w(+1 -1).include?(klass)
          generator = Generator.new(klass)
          snippet = generator.apply_snippet
          generator.output_snippets(OUTPUT_DIR, snippet)
        end
      end

      def initialize(klass)
        @klass = klass
      end

      def apply_snippet
        klass = @klass
        template =<<-EOS
<snippet>
  <content><![CDATA[
:<%=klass%>:
]]></content>
  <tabTrigger>em_<%=klass%></tabTrigger>
  <scope>text.html.markdown</scope>
  <description>emoji <%=klass%></description>
</snippet>
        EOS
        ERB.new(template).result(binding)
      end

      def output_snippets(output_dir, snippet)
        File.open("./#{output_dir}/#{@klass}.sublime-snippet", "w:utf-8") do |e|
          e.puts(snippet)
        end
      end
    end
  end
end

charset = nil
html = open(Emoji::SublimeText::URL) do |f|
  charset = f.charset
  f.read
end

doc = Nokogiri::HTML.parse(html, nil, charset)
klasses = doc.xpath('//span[@class="name"]').map(&:text)
Emoji::SublimeText::Generator.bulk_output(klasses)
