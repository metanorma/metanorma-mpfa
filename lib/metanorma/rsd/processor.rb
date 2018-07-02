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
          doc: "doc"
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
        else
          super
        end
      end
    end
  end
end
