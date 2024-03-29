require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
end

require "bundler/setup"
require "asciidoctor"
require "metanorma-mpfa"
require "metanorma/mpfa"
require "isodoc/mpfa/html_convert"
require "isodoc/mpfa/word_convert"
require "metanorma/standoc/converter"
require "rspec/matchers"
require "equivalent-xml"
require "htmlentities"
require "metanorma"
require "rexml/document"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.around do |example|
    Dir.mktmpdir("rspec-") do |dir|
      Dir.chdir(dir) { example.run }
    end
  end
end

def metadata(hash)
  hash.sort.to_h.delete_if do |_, v|
    v.nil? || (v.respond_to?(:empty?) && v.empty?)
  end
end

def strip_guid(str)
  str.gsub(%r{ id="_[^"]+"}, ' id="_"').gsub(%r{ target="_[^"]+"},
                                             ' target="_"')
end

def htmlencode(html)
  HTMLEntities.new.encode(html, :hexadecimal).gsub(/&#x3e;/, ">").gsub(/&#xa;/, "\n")
    .gsub(/&#x22;/, '"').gsub(/&#x3c;/, "<").gsub(/&#x26;/, "&").gsub(/&#x27;/, "'")
    .gsub(/\\u(....)/) do
    "&#x#{$1.downcase};"
  end
end

def xmlpp(xml)
  c = HTMLEntities.new
  xml &&= xml.split(/(&\S+?;)/).map do |n|
    if /^&\S+?;$/.match?(n)
      c.encode(c.decode(n), :hexadecimal)
    else n
    end
  end.join
  s = ""
  f = REXML::Formatters::Pretty.new(2)
  f.compact = true
  f.write(REXML::Document.new(xml), s)
  s
end

ASCIIDOC_BLANK_HDR = <<~"HDR".freeze
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :novalid:

HDR

VALIDATING_BLANK_HDR = <<~"HDR".freeze
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:

HDR

BLANK_HDR = <<~"HDR".freeze
  <?xml version="1.0" encoding="UTF-8"?>
  <mpfd-standard xmlns="https://www.metanorma.org/ns/mpfd" type="semantic" version="#{Metanorma::MPFA::VERSION}">
    <bibdata type="standard">
      <title language="en" format="text/plain">Document title</title>

      <contributor>
        <role type="author"/>
        <organization>
          <name>Mandatory Provident Fund Schemes Authority</name>
        </organization>
      </contributor>
      <contributor>
        <role type="publisher"/>
        <organization>
          <name>Mandatory Provident Fund Schemes Authority</name>
        </organization>
      </contributor>
      <language>en</language>
      <script>Latn</script>

      <status>
        <stage>published</stage>
      </status>
      <copyright>
        <from>#{Time.new.year}</from>
        <owner>
          <organization>
          <name>Mandatory Provident Fund Schemes Authority</name>
          </organization>
        </owner>
      </copyright>
      <ext>
        <doctype>standard</doctype>
      </ext>
    </bibdata>
HDR

HTML_HDR = <<~"HDR".freeze
  <body lang="EN-US" link="blue" vlink="#954F72" xml:lang="EN-US" class="container">
    <div class="title-section">
      <p>&#160;</p>
    </div>
    <br/>
    <div class="prefatory-section">
      <p>&#160;</p>
    </div>
    <br/>
    <div class="main-section">
HDR

WORD_HDR = <<~"HDR".freeze
  <body lang="EN-US" link="blue" vlink="#954F72">
    <div class="WordSection1">
      <p>&#160;</p>
    </div>
    <p><br clear="all" class="section"/></p>
    <div class="WordSection2">
      <p><br clear="all" style="mso-special-character:line-break;page-break-before:always"/></p>
HDR

WORD_FTR = <<~"FTR".freeze
  <p>&#160;</p>
  </div>
    <p><br clear="all" class="section"/></p>
    <div class="WordSection3">
      <p class="zzSTDTitle1"/>
    </div>
  </body>
FTR

def mock_pdf
  allow(::Mn2pdf).to receive(:convert) do |url, output,|
    FileUtils.cp(url.gsub(/"/, ""), output.gsub(/"/, ""))
  end
end
