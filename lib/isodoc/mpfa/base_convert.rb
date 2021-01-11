require "isodoc"
require  "fileutils"

module IsoDoc
  module MPFA
    module BaseConvert
      TERM_CLAUSE = "//preface/terms | "\
        "//preface/clause[descendant::terms]".freeze

      SECTIONS_XPATH = 
        "//foreword | //introduction | //preface/terms | //preface/clause | //annex | "\
        "//sections/clause | //bibliography/references | //acknowledgements | "\
        "//bibliography/clause".freeze

      def terms_defs(isoxml, out, num)
        f = isoxml.at(ns(self.class::TERM_CLAUSE)) or return num
        out.div **attr_code(id: f["id"]) do |div|
          clause_name(nil, f&.at(ns("./title")), div, nil)
          f.elements.each do |e|
            parse(e, div) unless %w{title source}.include? e.name
          end
        end
        num
      end

      FRONT_CLAUSE = "//*[parent::preface]".freeze

      def preface(isoxml, out)
        isoxml.xpath(ns(self.class::FRONT_CLAUSE)).each do |c|
          if c.name == "terms" || c.at(ns(".//terms")) then terms_defs isoxml, out, 0
          elsif !is_clause?(c.name) then parse(c, out)
          else
            out.div **attr_code(id: c["id"]) do |s|
              clause_name(nil, c&.at(ns("./title")), s, nil)
              c.elements.reject { |c1| c1.name == "title" }.each do |c1|
                parse(c1, s)
              end
            end
          end
        end
      end

      def middle_clause(_docxml)
        "//clause[parent::sections][not(descendant::terms)]"
      end

      def middle(isoxml, out)
        middle_title(isoxml, out)
        middle_admonitions(isoxml, out)
        clause isoxml, out
        annex isoxml, out
        bibliography isoxml, out
      end

      def termdef_parse(node, out)
        name = node&.at(ns("./name"))&.remove
        set_termdomain("")
        node.children.each { |n| parse(n, out) }
      end

      def clause(isoxml, out)
        isoxml.xpath(ns(middle_clause(isoxml))).each do |c|
          out.div **attr_code(id: c["id"]) do |s|
            clause_name(nil, c&.at(ns("./title")), s, 
                        class: c["container"] ? "containerhdr" : nil )
            c.elements.reject { |c1| c1.name == "title" }.each do |c1|
              parse(c1, s)
            end
          end
        end
      end

      def clause_parse_title(node, div, c1, out, header_class = {})
        attrs = {}
        attrs = { class: "containerhdr" } if node["container"]
        header_class = header_class.merge(attrs)
        super
      end

      def ol_depth(node)
        ol_style(node["type"])
      end
    end
  end
end
