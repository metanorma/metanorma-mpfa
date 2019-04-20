require "isodoc"
require_relative "metadata"
require  "fileutils"

module IsoDoc
  module Mpfd
  	module BaseConvert
      def convert1(docxml, filename, dir)
        FileUtils.cp html_doc_path("logo.jpg"), File.join(@localdir, "logo.jpg")
        FileUtils.cp html_doc_path('mpfa-logo-no-text@4x.png'), File.join(@localdir, "mpfa-logo-no-text@4x.png")
        @files_to_delete << File.join(@localdir, "logo.jpg")
        @files_to_delete << File.join(@localdir, "mpfa-logo-no-text@4x.png")
        super
      end

      def metadata_init(lang, script, labels)
        @meta = Metadata.new(lang, script, labels)
      end

      def annex_name(annex, name, div)
        div.h1 **{ class: "Annex" } do |t|
          t << "#{get_anchors[annex['id']][:label]} "
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
        "//sections/clause | //bibliography/references | "\
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
              clause_name(get_anchors[c['id']][:label],
                          c&.at(ns("./title"))&.content, s, nil)
              c.elements.reject { |c1| c1.name == "title" }.each do |c1|
                parse(c1, s)
              end
            end
          end
        end
      end

      def initial_anchor_names(d)
        d.xpath(ns(self.class::FRONT_CLAUSE)).each do |c|
          preface_names(c)
          sequential_asset_names(c)
        end
        middle_section_asset_names(d)
        clause_names(d, 0)
        termnote_anchor_names(d)
        termexample_anchor_names(d)
      end

      def middle(isoxml, out)
        middle_title(out)
        clause isoxml, out
        annex isoxml, out
        bibliography isoxml, out
      end

      def termdef_parse(node, out)
        set_termdomain("")
        node.children.each { |n| parse(n, out) }
      end

      def annex_name_lbl(clause, num)
        l10n("<b>#{@annex_lbl} #{num}</b>")
      end

      def clause_names(docxml, sect_num)
        q = "//clause[parent::sections]"
        @topnum = nil
        lvl = 0
        docxml.xpath(ns(q)).each do |c|
          container_names(c, 0)
          sect_num, lvl = sect_names(c, nil, sect_num, 0, lvl)
        end
      end

      def container_names(clause, lvl)
        if clause["container"]
          @anchors[clause["id"]] = 
            { label: nil, xref: clause.at(ns("./title"))&.text, level: lvl+1 }
        end
        clause.xpath(ns("./clause | ./term  | ./terms | "\
                        "./definitions")).each do |c|
          container_names(c, clause["container"] ? lvl+1 : lvl)
        end
      end

      def sect_names(clause, num, i, lvl, prev_lvl)
        return i if clause.nil?
        curr = i
        if !clause["container"]
          retlvl = lvl
          i+=1
          curr = i
          name = num.nil? ? i.to_s : "#{num}.#{i}"
          @anchors[clause["id"]] = { label: name, xref: l10n("#{@clause_lbl} #{name}"), level: lvl+1 }
        end
        prev = lvl
        j = 0
        clause.xpath(ns("./clause | ./term  | ./terms | "\
                        "./definitions")).each do |c|
          if clause["container"]
            i, lvl = sect_names(c, num, i, lvl, lvl)
          else
            j, prev = sect_names(c, name, j, lvl+1, prev)
          end
        end
        i = j if j >0
        i = curr if lvl < prev
        [i, prev]
      end

      def annex_naming(c, num, lvl, i)
        if c["guidance"] then annex_names1(c, "#{num}E", lvl + 1)
        else
          i+= 1 unless c["container"]
          annex_names1(c, "#{num}.#{i}", lvl + 1)
        end
        i
      end

      def annex_names(clause, num)
        @anchors[clause["id"]] = { label: annex_name_lbl(clause, num),
                                   xref: "#{@annex_lbl} #{num}", level: 1 }
        i = 0
        clause.xpath(ns("./clause")).each do |c|
          container_names(c, 0)
          i = annex_naming(c, num, 1, i)
        end
        hierarchical_asset_names(clause, num)
      end

      def annex_names1(clause, num, level)
        clause["container"] or @anchors[clause["id"]] = 
          { label: num, xref: "#{@annex_lbl} #{num}", level: level }
        i = 0
        clause.xpath(ns("./clause")).each do |c|
          i = annex_naming(c, num, level, i)
        end
      end

      def clause(isoxml, out)
        isoxml.xpath(ns(self.class::MIDDLE_CLAUSE)).each do |c|
          out.div **attr_code(id: c["id"]) do |s|
            clause_name(get_anchors[c['id']][:label],
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
          div.send "h#{get_anchors[node['id']][:level]}", **attr_code(attrs) do |h|
            lbl = get_anchors[node['id']][:label]
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