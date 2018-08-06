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
        x.xpath("//[@guidance]").each do |h|
          c = h.previous_element || next
          c.add_child h.remove
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

      def make_preface(x, s)
        if x.at("//foreword | //introduction | //terms")
          preface = s.add_previous_sibling("<preface/>").first
          foreword = x.at("//foreword")
          preface.add_child foreword.remove if foreword
          introduction = x.at("//introduction")
          preface.add_child introduction.remove if introduction
          terms = x.at("//terms")
          preface.add_child terms.remove if terms
        end
        x.xpath("//clause[@preface]").each do |c|
          c.delete("preface")
          preface.add_child c.remove
        end
      end

      def clause_parse(attrs, xml, node)
        attrs[:preface] = true if node.attr("style") == "preface"
        attrs[:guidance] = true if node.option? "guidance"
        super
      end

    end
  end
end
