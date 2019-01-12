require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
end

require "bundler/setup"
require "asciidoctor"
require "metanorma-mpfd"
require "asciidoctor/mpfd"
require "isodoc/mpfd/html_convert"
require "isodoc/mpfd/word_convert"
require "asciidoctor/standoc/converter"
require "rspec/matchers"
require "equivalent-xml"
require "htmlentities"
require "metanorma"
require "metanorma/mpfd"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def strip_guid(x)
  x.gsub(%r{ id="_[^"]+"}, ' id="_"').gsub(%r{ target="_[^"]+"}, ' target="_"')
end

def htmlencode(x)
  HTMLEntities.new.encode(x, :hexadecimal).gsub(/&#x3e;/, ">").gsub(/&#xa;/, "\n").
    gsub(/&#x22;/, '"').gsub(/&#x3c;/, "<").gsub(/&#x26;/, '&').gsub(/&#x27;/, "'").
    gsub(/\\u(....)/) { |s| "&#x#{$1.downcase};" }
end

ASCIIDOC_BLANK_HDR = <<~"HDR"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:

HDR

VALIDATING_BLANK_HDR = <<~"HDR"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:

HDR

BLANK_HDR = <<~"HDR"
       <?xml version="1.0" encoding="UTF-8"?>
       <mpfd-standard xmlns="https://open.ribose.com/standards/mpfd">
       <bibdata type="article">
        <title language="en" format="text/plain">Document title</title>

         <contributor>
           <role type="author"/>
           <organization>
             <name>Mandatory Provident Fund Schemes Authority</name>
             <abbreviation>MPFA</abbreviation>
           </organization>
         </contributor>
         <contributor>
           <role type="publisher"/>
           <organization>
             <name>Mandatory Provident Fund Schemes Authority</name>
             <abbreviation>MPFA</abbreviation>
           </organization>
         </contributor>
         <language>en</language>
         <script>Latn</script>

         <copyright>
           <from>#{Time.new.year}</from>
           <owner>
             <organization>
             <name>Mandatory Provident Fund Schemes Authority</name>
             <abbreviation>MPFA</abbreviation>
             </organization>
           </owner>
         </copyright>
         <editorialgroup>
           <committee/>
         </editorialgroup>
       </bibdata>
HDR

HTML_HDR = <<~"HDR"
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

WORD_HDR = <<~"HDR"
<body lang="EN-US" link="blue" vlink="#954F72">
    <div class="WordSection1">
      <p>&#160;</p>
    </div>
    <p><br clear="all" class="section"/></p>
    <div class="WordSection2">
      <p><br clear="all" style="mso-special-character:line-break;page-break-before:always"/></p>
HDR

WORD_FTR = <<~"FTR"
   <p>&#160;</p>
 </div>
   <p><br clear="all" class="section"/></p>
   <div class="WordSection3">
     <p class="zzSTDTitle1"/>
   </div>
 </body>
FTR
