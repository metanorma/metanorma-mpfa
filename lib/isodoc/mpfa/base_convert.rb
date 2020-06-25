require "isodoc"
require_relative "metadata"
require_relative "xref"
require  "fileutils"

module IsoDoc
  module MPFA
    module BaseConvert
      def metadata_init(lang, script, labels)
        @meta = Metadata.new(lang, script, labels)
      end

      def xref_init(lang, script, klass, labels, options)
        @xrefs = Xref.new(lang, script, klass, labels, options)
      end

      def annex_name(annex, name, div)
        div.h1 **{ class: "Annex" } do |t|
          t << "#{@xrefs.anchor(annex['id'], :label)} "
          t.b do |b|
            name&.children&.each { |c2| parse(c2, b) }
          end
        end
      end

      def fileloc(loc)
        File.join(File.dirname(__FILE__), loc)
      end

      def i18n_init(lang, script)
        super
        y = if lang == "en"
              YAML.load_file(File.join(File.dirname(__FILE__), "i18n-en.yaml"))
            elsif lang == "zh" && script == "Hans"
              YAML.load_file(File.join(File.dirname(__FILE__),
                                       "i18n-zh-Hans.yaml"))
            else
              YAML.load_file(File.join(File.dirname(__FILE__), "i18n-en.yaml"))
            end
        @labels = @labels.merge(y)
        @annex_lbl = y["annex"]
        @clause_lbl = y["clause"]
      end

      def terms_defs_title(f)
        return f&.at(ns("./title"))&.content
      end

      TERM_CLAUSE = "//preface/terms | "\
        "//preface/clause[descendant::terms]".freeze

      SECTIONS_XPATH = 
        "//foreword | //introduction | //preface/terms | //preface/clause | //annex | "\
        "//sections/clause | //bibliography/references | //acknowledgements | "\
        "//bibliography/clause".freeze

      def terms_defs(isoxml, out, num)
        f = isoxml.at(ns(self.class::TERM_CLAUSE)) or return num
        out.div **attr_code(id: f["id"]) do |div|
          clause_name(nil, terms_defs_title(f), div, nil)
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
          else
            out.div **attr_code(id: c["id"]) do |s|
              clause_name(@xrefs.anchor(c['id'], :label),
                          c&.at(ns("./title"))&.content, s, nil)
              c.elements.reject { |c1| c1.name == "title" }.each do |c1|
                parse(c1, s)
              end
            end
          end
        end
      end

      def middle(isoxml, out)
        middle_title(out)
        middle_admonitions(isoxml, out)
        clause isoxml, out
        annex isoxml, out
        bibliography isoxml, out
      end

      def termdef_parse(node, out)
        set_termdomain("")
        node.children.each { |n| parse(n, out) }
      end

      def clause(isoxml, out)
        isoxml.xpath(ns(middle_clause)).each do |c|
          out.div **attr_code(id: c["id"]) do |s|
            clause_name(@xrefs.anchor(c['id'], :label),
                        c&.at(ns("./title"))&.content, s, class: c["container"] ? "containerhdr" : nil )
            c.elements.reject { |c1| c1.name == "title" }.each do |c1|
              parse(c1, s)
            end
          end
        end
      end

      def clause_parse_title(node, div, c1, out)
        if node["inline-header"] == "true"
          inline_header_title(out, node, c1)
        else
          attrs = { class: node["container"] ? "containerhdr" : nil }
          div.send "h#{@xrefs.anchor(node['id'], :level, :false) || '1'}", **attr_code(attrs) do |h|
            lbl = @xrefs.anchor(node['id'], :label, false)
            h << "#{lbl}. " if lbl && !@suppressheadingnumbers
            c1&.children&.each { |c2| parse(c2, h) }
          end
        end
      end

      def ol_depth(node)
        ol_style(node["type"])
      end
    end
  end
end
