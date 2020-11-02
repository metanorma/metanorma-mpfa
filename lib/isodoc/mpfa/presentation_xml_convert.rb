require_relative "init"
require "isodoc"

module IsoDoc
  module MPFA
    class PresentationXMLConvert < IsoDoc::PresentationXMLConvert
      def annex1(f)
        lbl = @xrefs.anchor(f['id'], :label)
        if t = f.at(ns("./title"))
          t.children = "<strong>#{t.children.to_xml}</strong>"
        end
        prefix_name(f, " ", lbl, "title")
      end

      def clause1(f)
        lbl = @xrefs.anchor(f['id'], :label, f.parent.name != "sections")
        if lbl == "1" and !f.at(ns("./title"))
          prefix_name(f, "<tab/>", " ", "title")
        else
          super
        end
      end

      include Init
    end
  end
end

