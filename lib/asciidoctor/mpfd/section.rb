require "asciidoctor"
require "asciidoctor/mpfd"
require "asciidoctor/standoc/converter"
require "isodoc/mpfd/html_convert"
require "isodoc/mpfd/word_convert"

module Asciidoctor
  module Mpfd

    # A {Converter} implementation that generates MPFD output, and a document
    # schema encapsulation of the document for validation
    #
    class Converter < Standoc::Converter

      def sections_cleanup(x)
        super
        x.xpath("//*[@inline-header]").each do |h|
          h.delete("inline-header")
        end
        x.xpath("//*[@guidance]").each do |h|
          c = h.previous_element || next
          c.add_child h.remove
        end
      end

      def section(node)
        a = { id: Asciidoctor::Standoc::Utils::anchor_or_uuid(node) }
        noko do |xml|
          case sectiontype(node)
          when "introduction" then introduction_parse(a, xml, node)
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
          when "symbols and abbreviated terms",
            "symbols", "abbreviated terms", "abbrevations"
            symbols_parse(a, xml, node)
          when "bibliography" then bibliography_parse(a, xml, node)
          else
            if @term_def then term_def_subclause_parse(a, xml, node)
            elsif @biblio then bibliography_parse(a, xml, node)
            elsif node.attr("style") == "bibliography"
              bibliography_parse(a, xml, node)
            elsif node.attr("style") == "abstract"
              abstract_parse(a, xml, node)
            elsif node.attr("style") == "appendix" && node.level == 1
              annex_parse(a, xml, node)
            else
              clause_parse(a, xml, node)
            end
          end
        end.join("\n")
      end

      def term_def_title(_toplevel, node)
        return node.title
      end

      def move_sections_into_preface(x, preface)
        foreword = x.at("//foreword")
        preface.add_child foreword.remove if foreword
        introduction = x.at("//introduction")
        preface.add_child introduction.remove if introduction
        terms = x.at("//sections/clause[descendant::terms]") || x.at("//terms")
        preface.add_child terms.remove if terms
        x.xpath("//clause[@preface]").each do |c|
          c.delete("preface")
          preface.add_child c.remove
        end
      end

      def make_preface(x, s)
        if x.at("//foreword | //introduction | //terms | //abstract | //clause[@preface]")
          preface = s.add_previous_sibling("<preface/>").first
          move_sections_into_preface(x, preface)
        end
      end

      def clause_parse(attrs, xml, node)
        attrs[:preface] = true if node.attr("style") == "preface"
        attrs[:guidance] = true if node.role == "guidance"
        attrs[:container] = true if node.role == "container"
        super
      end

    end
  end
end
