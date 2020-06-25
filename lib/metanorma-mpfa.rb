require "asciidoctor" unless defined? Asciidoctor::Converter
require_relative "asciidoctor/mpfa/converter"
require_relative "isodoc/mpfa/html_convert"
require_relative "isodoc/mpfa/word_convert"
require_relative "isodoc/mpfa/presentation_xml_convert"
require_relative "metanorma/mpfa/version"

if defined? Metanorma
  require_relative "metanorma/mpfa"
  Metanorma::Registry.instance.register(Metanorma::MPFA::Processor)
end
