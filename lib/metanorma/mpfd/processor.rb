require "metanorma/processor"

module Metanorma
  module Mpfd
    class Processor < Metanorma::Processor

      def initialize
        @short = :rsd
        @input_format = :asciidoc
        @asciidoctor_backend = :rsd
      end

      def output_formats
        super.merge(
          html: "html",
          doc: "doc",
          pdf: "pdf"
        )
      end

      def version
        "Asciidoctor::Mpfd #{Asciidoctor::Mpfd::VERSION}"
      end

      def input_to_isodoc(file)
        Metanorma::Input::Asciidoc.new.process(file, @asciidoctor_backend)
      end

      def output(isodoc_node, outname, format, options={})
        case format
        when :html
          IsoDoc::Mpfd::HtmlConvert.new(options).convert(outname, isodoc_node)
        when :doc
          IsoDoc::Mpfd::WordConvert.new(options).convert(outname, isodoc_node)
        when :pdf
          IsoDoc::Mpfd::PdfConvert.new(options).convert(outname, isodoc_node)
        else
          super
        end
      end
    end
  end
end
