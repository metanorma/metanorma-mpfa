require "asciidoctor"
require "metanorma/mpfa"
require "metanorma/standoc/converter"
require "isodoc/mpfa/html_convert"
require "isodoc/mpfa/word_convert"
require_relative "section"
require "fileutils"
require_relative "./validate"

module Metanorma
  module MPFA
    # A {Converter} implementation that generates MPFD output, and a document
    # schema encapsulation of the document for validation
    #
    class Converter < Standoc::Converter
      XML_ROOT_TAG = "mpfd-standard".freeze
      XML_NAMESPACE = "https://www.metanorma.org/ns/mpfd".freeze

      register_for "mpfa"

      def default_publisher
        "Mandatory Provident Fund Schemes Authority"
      end

      def metadata_committee(node, xml)
        return unless node.attr("committee")

        xml.editorialgroup do |a|
          a.committee node.attr("committee"),
                      **attr_code(type: node.attr("committee-type"))
          i = 2
          while node.attr("committee_#{i}")
            a.committee node.attr("committee_#{i}"),
                        **attr_code(type: node.attr("committee-type_#{i}"))
            i += 1
          end
        end
      end

      def metadata_id(node, xml)
        xml.docidentifier { |i| i << node.attr("docnumber") }
        xml.docnumber { |i| i << node.attr("docnumber") }
      end

      def title_validate(_root)
        nil
      end

      def makexml(node)
        @draft = node.attributes.has_key?("draft")
        super
      end

      def outputs(node, ret)
        File.open("#{@filename}.xml", "w:UTF-8") { |f| f.write(ret) }
        presentation_xml_converter(node).convert("#{@filename}.xml")
        html_converter(node).convert("#{@filename}.presentation.xml", nil,
                                     false, "#{@filename}.html")
        doc_converter(node).convert("#{@filename}.presentation.xml", nil,
                                    false, "#{@filename}.doc")
        pdf_converter(node)&.convert("#{@filename}.presentation.xml", nil,
                                     false, "#{@filename}.pdf")
      end

      def validate(doc)
        content_validate(doc)
        schema_validate(formattedstr_strip(doc.dup),
                        File.join(File.dirname(__FILE__), "mpfd.rng"))
      end

      def style(_n, _t)
        nil
      end

      def presentation_xml_converter(node)
        IsoDoc::MPFA::PresentationXMLConvert.new(html_extract_attributes(node))
      end

      def html_converter(node)
        IsoDoc::MPFA::HtmlConvert.new(html_extract_attributes(node))
      end

      def doc_converter(node)
        IsoDoc::MPFA::WordConvert.new(doc_extract_attributes(node))
      end

      def pdf_converter(node)
        return if node.attr("no-pdf")

        IsoDoc::MPFA::PdfConvert.new(pdf_extract_attributes(node))
      end
    end
  end
end
