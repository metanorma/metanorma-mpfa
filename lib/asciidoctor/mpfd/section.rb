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

      def sectiontype_streamline(ret)
        case ret
        when "glossary" then "terms and definitions"
        else
          super
        end
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
        acknowledgements = x.at("//acknowledgements")
        preface.add_child acknowledgements.remove if acknowledgements
      end

      def make_preface(x, s)
        if x.at("//foreword | //introduction | //terms | //acknowledgements |"\
            "//abstract[not(ancestor::bibitem)] | //clause[@preface]")
          preface = s.add_previous_sibling("<preface/>").first
          move_sections_into_preface(x, preface)
          make_abstract(x, s)
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
