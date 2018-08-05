require "asciidoctor"
require "asciidoctor/mpfd"
require "asciidoctor/iso/converter"
require "isodoc/mpfd/html_convert"
require "isodoc/mpfd/word_convert"

module Asciidoctor
  module Mpfd

    # A {Converter} implementation that generates MPFD output, and a document
    # schema encapsulation of the document for validation
    #
    class Converter < ISO::Converter

      def sections_cleanup(x)
        super
        x.xpath("//*[@inline-header]").each do |h|
          h.delete("inline-header")
        end
      end

      def section(node)
        a = { id: Asciidoctor::ISO::Utils::anchor_or_uuid(node) }
        noko do |xml|
          case sectiontype(node)
          when "introduction" then
            if node.level == 1 then introduction_parse(a, xml, node)
            else
              clause_parse(a, xml, node)
            end
          when "patent notice" then patent_notice_parse(xml, node)
          when "scope" then scope_parse(a, xml, node)
          when "normative references" then norm_ref_parse(a, xml, node)
          when "terms and definitions",
            "terms, definitions, symbols and abbreviated terms",
            "terms, definitions, symbols and abbreviations",
            "terms, definitions and symbols",
            "terms, definitions and abbreviations",
            "terms, definitions and abbreviated terms",
            "glossary"
            @term_def = true
            term_def_parse(a, xml, node, true)
            @term_def = false
          when "symbols and abbreviated terms"
            symbols_parse(a, xml, node)
          when "bibliography" then bibliography_parse(a, xml, node)
          else
            if @term_def then term_def_subclause_parse(a, xml, node)
            elsif @biblio then bibliography_parse(a, xml, node)
            elsif node.attr("style") == "bibliography" && node.level == 1
              bibliography_parse(a, xml, node)
            elsif node.attr("style") == "appendix" && node.level == 1
              annex_parse(a, xml, node)
            elsif node.option? "appendix"
              appendix_parse(a, xml, node)
            else
              clause_parse(a, xml, node)
            end
          end
        end.join("\n")
      end

      def term_def_title(_toplevel, node)
        return node.title
    end

    end
  end
end
