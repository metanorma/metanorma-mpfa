require "asciidoctor" unless defined? Asciidoctor::Converter
require_relative "metanorma/mpfa/converter"
require_relative "isodoc/mpfa/html_convert"
require_relative "isodoc/mpfa/pdf_convert"
require_relative "isodoc/mpfa/word_convert"
require_relative "isodoc/mpfa/presentation_xml_convert"
require_relative "metanorma/mpfa/version"
require "metanorma"

if defined? Metanorma::Registry
  require_relative "metanorma/mpfa"
  Metanorma::Registry.instance.register(Metanorma::MPFA::Processor)
end
