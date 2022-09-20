require_relative "init"
require "isodoc"

module IsoDoc
  module MPFA
    class PresentationXMLConvert < IsoDoc::PresentationXMLConvert
      def annex1(elem)
        lbl = @xrefs.anchor(elem["id"], :label)
        if t = f.at(ns("./title"))
          t.children = "<strong>#{t.children.to_xml}</strong>"
        end
        prefix_name(elem, " ", lbl, "title")
      end

      def clause1(elem)
        lbl = @xrefs.anchor(elem["id"], :label, elem.parent.name != "sections")
        if lbl == "1" && !elem.at(ns("./title"))
          prefix_name(elem, "<tab/>", " ", "title")
        else
          super
        end
      end

      include Init
    end
  end
end
