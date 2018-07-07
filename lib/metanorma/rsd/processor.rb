require "metanorma/processor"

module Metanorma
  module Rsd
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
        "Asciidoctor::Rsd #{Asciidoctor::Rsd::VERSION}"
      end

      def input_to_isodoc(file)
        Metanorma::Input::Asciidoc.new.process(file, @asciidoctor_backend)
      end

      def output(isodoc_node, outname, format, options={})
        case format
        when :html
          IsoDoc::Rsd::HtmlConvert.new(options).convert(outname, isodoc_node)
        when :doc
          IsoDoc::Rsd::WordConvert.new(options).convert(outname, isodoc_node)
        when :pdf
          require 'tempfile'
          outname_html = outname + ".html"
          IsoDoc::Rsd::HtmlConvert.new(options).convert(outname_html, isodoc_node)
          puts outname_html
          system "cat #{outname_html}"
          Metanorma::Output::Pdf.new.convert(outname_html, outname)
        else
          super
        end
      end
    end
  end
end
