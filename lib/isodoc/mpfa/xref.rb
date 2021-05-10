module IsoDoc
  module MPFA
    class Xref < IsoDoc::Xref
      FRONT_CLAUSE = "//*[parent::preface]".freeze

      def initial_anchor_names(doc)
        doc.xpath(ns(self.class::FRONT_CLAUSE)).each do |c|
          preface_names(c)
          sequential_asset_names(c)
        end
        middle_section_asset_names(doc)
        clause_names(doc, 0)
        termnote_anchor_names(doc)
        termexample_anchor_names(doc)
      end

      def annex_name_lbl(_clause, num)
        l10n("<strong>#{@labels['annex']} #{num}</strong>")
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
            { label: nil, xref: clause.at(ns("./title"))&.text, level: lvl + 1 }
        end
        clause.xpath(ns("./clause | ./term  | ./terms | "\
                        "./definitions")).each do |c|
          container_names(c, clause["container"] ? lvl + 1 : lvl)
        end
      end

      def sect_names(clause, num, i, lvl, _prev_lvl)
        return i if clause.nil?

        curr = i
        if !clause["container"]
          i += 1
          curr = i
          name = num.nil? ? i.to_s : "#{num}.#{i}"
          @anchors[clause["id"]] = { label: name, level: lvl + 1,
                                     xref: l10n("#{@labels['clause']} #{name}") }
        end
        prev = lvl
        j = 0
        clause.xpath(ns("./clause | ./term  | ./terms | "\
                        "./definitions")).each do |c|
          if clause["container"]
            i, lvl = sect_names(c, num, i, lvl, lvl)
          else
            j, prev = sect_names(c, name, j, lvl + 1, prev)
          end
        end
        i = j if j.positive?
        i = curr if lvl < prev
        [i, prev]
      end

      def annex_naming(clause, num, lvl, idx)
        if clause["guidance"] then annex_names1(clause, "#{num}E", lvl + 1)
        else
          idx += 1 unless clause["container"]
          annex_names1(clause, "#{num}.#{idx}", lvl + 1)
        end
        idx
      end

      def annex_names(clause, num)
        @anchors[clause["id"]] =
          { label: annex_name_lbl(clause, num), value: num,
            xref: l10n("#{@labels['annex']} #{num}"), level: 1 }
        if a = single_annex_special_section(clause)
          annex_names1(a, num.to_s, 1)
        else
          i = 0
          clause.xpath(ns("./clause | ./references")).each do |c|
            container_names(c, 0)
            i = annex_naming(c, num, 1, i)
          end
        end
        hierarchical_asset_names(clause, num)
      end

      def annex_names1(clause, num, level)
        unless clause["container"]
          @anchors[clause["id"]] =
            { label: num,
              xref: l10n("#{@labels['annex']} #{num}"), level: level }
        end
        i = 0
        clause.xpath(ns("./clause | ./references")).each do |c|
          i = annex_naming(c, num, level, i)
        end
      end
    end
  end
end
