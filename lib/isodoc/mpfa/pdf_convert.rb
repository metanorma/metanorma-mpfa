require_relative "base_convert"
require "isodoc"

module IsoDoc
  module MPFA
    # A {Converter} implementation that generates PDF HTML output, and a
    # document schema encapsulation of the document for validation
    class PdfConvert < IsoDoc::XslfoPdfConvert
      def initialize(options)
        @libdir = File.dirname(__FILE__)
        super
      end

      def pdf_stylesheet(docxml)
        doctype = docxml&.at(ns("//bibdata/ext/doctype"))&.text
        doctype = "standards" unless %w(circular guidelines
        compliance-standards-for-mpf-trustees
        supervision-of-mpf-intermediaries).include? doctype
        "mpfd.#{doctype}.xsl"
      end
    end
  end
end
