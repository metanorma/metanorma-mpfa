require "metanorma/processor"

module Metanorma
  module MPFA
    class Processor < Metanorma::Processor

      def initialize
        @short = [:mpfd, :mpfa]
        @input_format = :asciidoc
        @asciidoctor_backend = :mpfa
      end

      def output_formats
        super.merge(
          html: "html",
          doc: "doc",
          pdf: "pdf"
        )
      end

      def fonts_manifest
        {
          "Arial" => nil,
          "STIX Two Math" => nil,
        }
      end

      def version
        "Metanorma::MPFA #{Metanorma::MPFA::VERSION}"
      end

      def output(isodoc_node, inname, outname, format, options={})
        case format
        when :html
          IsoDoc::MPFA::HtmlConvert.new(options).convert(inname, isodoc_node, nil, outname)
        when :doc
          IsoDoc::MPFA::WordConvert.new(options).convert(inname, isodoc_node, nil, outname)
        when :pdf
          IsoDoc::MPFA::PdfConvert.new(options).convert(inname, isodoc_node, nil, outname)
        when :presentation
          IsoDoc::MPFA::PresentationXMLConvert.new(options).convert(inname, isodoc_node, nil, outname)
        else
          super
        end
      end
    end
  end
end
