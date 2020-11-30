require_relative "base_convert"
require_relative "init"
require "isodoc"

module IsoDoc
  module MPFA
    # A {Converter} implementation that generates Word output, and a document
    # schema encapsulation of the document for validation
    class WordConvert < IsoDoc::WordConvert
      def initialize(options)
        @libdir = File.dirname(__FILE__)
        super
      end

      include BaseConvert

      def default_fonts(options)
        {
          bodyfont: (options[:script] == "Hans" ? '"SimSun",serif' : '"Arial",sans-serif'),
          headerfont: (options[:script] == "Hans" ? '"SimHei",sans-serif' : '"Arial",sans-serif'),
          monospacefont: '"Courier New",monospace',
          normalfontsize: "10.5pt",
          monospacefontsize: "10.0pt",
          footnotefontsize: "10.0pt",
          smallerfontsize: "10.0pt",
        }
      end

      def default_file_locations(options)
        {
          htmlstylesheet: html_doc_path("htmlstyle.scss"),
          htmlcoverpage: html_doc_path("html_rsd_titlepage.html"),
          htmlintropage: html_doc_path("html_rsd_intro.html"),
          scripts: html_doc_path("scripts.html"),
          wordstylesheet: html_doc_path("wordstyle.scss"),
          standardstylesheet: html_doc_path("rsd.scss"),
          header: html_doc_path("header.html"),
          wordcoverpage: html_doc_path("word_rsd_titlepage.html"),
          wordintropage: html_doc_path("word_rsd_intro.html"),
          ulstyle: "l3",
          olstyle: "l2",
        }
      end

      def make_body(xml, docxml)
        body_attr = { lang: "EN-US", link: "blue", vlink: "#954F72" }
        xml.body **body_attr do |body|
          make_body1(body, docxml)
          make_body2(body, docxml)
          make_body3(body, docxml)
        end
      end

      def make_body2(body, docxml)
        body.div **{ class: "WordSection2" } do |div2|
          info docxml, div2
          #preface_block docxml, div2
          abstract docxml, div2
          foreword docxml, div2
          introduction docxml, div2
          terms_defs docxml, div2, 0
          div2.p { |p| p << "&nbsp;" } # placeholder
        end
        section_break(body)
      end

      include Init
    end
  end
end
