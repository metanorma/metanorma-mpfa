require "asciidoctor" unless defined? Asciidoctor::Converter
require_relative "asciidoctor/mpfd/converter"
require_relative "isodoc/mpfd/html_convert"
require_relative "isodoc/mpfd/word_convert"
require_relative "isodoc/mpfd/pdf_convert"
require_relative "metanorma/mpfd/version"

if defined? Metanorma
  require_relative "metanorma/mpfd"
  Metanorma::Registry.instance.register(Metanorma::Mpfd::Processor)
end
