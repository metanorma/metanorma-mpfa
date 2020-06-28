require_relative "init"
require "isodoc"

module IsoDoc
  module MPFA
    class PresentationXMLConvert < IsoDoc::PresentationXMLConvert
      include Init
    end
  end
end

