require "isodoc"
require "twitter_cldr"
require 'date'

module IsoDoc
  module Mpfd

    class Metadata < IsoDoc::Metadata
      def initialize(lang, script, labels)
        super
      end

      def title(isoxml, _out)
        main = isoxml&.at(ns("//bibdata/title[@language='en']"))&.text
        set(:doctitle, main)
      end

      def subtitle(_isoxml, _out)
        nil
      end

      def author(isoxml, _out)
        publisher = isoxml.at(ns("//bibdata/contributor/organization/name"))
        set(:publisher, publisher.text) if publisher
      end

      def docid(isoxml, _out)
        docnumber = isoxml.at(ns("//bibdata/docidentifier"))
        set(:docnumber, docnumber&.text)
      end

      def doctype(isoxml, _out)
        b = isoxml&.at(ns("//bibdata/ext/doctype"))&.text || return
        return unless b
        t = b.split(/[- ]/).
          map{ |w| w.capitalize unless w == "MPF" }.join(" ")
        set(:doctype, t)
      end

      def status_abbr(status)
        case status
        when "working-draft" then "wd"
        when "committee-draft" then "cd"
        when "draft-standard" then "d"
        else
          ""
        end
      end

      def version(isoxml, _out)
        super
        revdate = get[:revdate]
        set(:revdate_monthyear, monthyr(revdate))
        edition = isoxml.at(ns("//version/edition"))
        if edition
          set(
            :edition,
            edition.text.to_i.localize.
              to_rbnf_s("SpelloutRules", "spellout-ordinal").
              split(/(\W)/).map(&:capitalize).join
          )
        end
      end

      def monthyr(isodate)
        date = DateTime.parse(isodate)
        date.strftime('%-d %B %Y')    #=> "Sun 04 Feb 2001"
      rescue
        # invalid dates get thrown
        isodate
      end
    end
  end
end
