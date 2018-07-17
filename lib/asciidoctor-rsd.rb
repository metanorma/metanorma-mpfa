require "asciidoctor" unless defined? Asciidoctor::Converter
require_relative "asciidoctor/rsd/converter"
require_relative "isodoc/rsd/html_convert"
require_relative "isodoc/rsd/word_convert"
require_relative "isodoc/rsd/pdf_convert"
require_relative "asciidoctor/rsd/version"

if defined? Metanorma
  require_relative "metanorma/rsd"
  Metanorma::Registry.instance.register(Metanorma::Rsd::Processor)
end
