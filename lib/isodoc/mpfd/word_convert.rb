require "isodoc"
require_relative "metadata"

module IsoDoc
  module Mpfd
    # A {Converter} implementation that generates Word output, and a document
    # schema encapsulation of the document for validation

    class WordConvert < IsoDoc::WordConvert
      def rsd_html_path(file)
        File.join(File.dirname(__FILE__), File.join("html", file))
      end

      def initialize(options)
        super
        @wordstylesheet = generate_css(rsd_html_path("wordstyle.scss"), false, default_fonts(options))
        @standardstylesheet = generate_css(rsd_html_path("rsd.scss"), false, default_fonts(options))
        @header = rsd_html_path("header.html")
        @wordcoverpage = rsd_html_path("word_rsd_titlepage.html")
        @wordintropage = rsd_html_path("word_rsd_intro.html")
        @ulstyle = "l3"
        @olstyle = "l2"
        system "cp #{rsd_html_path('logo.jpg')} logo.jpg"
        system "cp #{rsd_html_path('mpfa-logo-no-text@4x.png')} mpfa-logo-no-text@4x.png"
        @files_to_delete << "logo.jpg"
        @files_to_delete << "mpfa-logo-no-text@4x.png"
      end

      def default_fonts(options)
        b = options[:bodyfont] ||
          (options[:script] == "Hans" ? '"SimSun",serif' :
           '"Arial",sans-serif')
        h = options[:headerfont] ||
          (options[:script] == "Hans" ? '"SimHei",sans-serif' :
           '"Arial",sans-serif')
        m = options[:monospacefont] || '"Courier New",monospace'
        "$bodyfont: #{b};\n$headerfont: #{h};\n$monospacefont: #{m};\n"
      end

      def metadata_init(lang, script, labels)
        @meta = Metadata.new(lang, script, labels)
      end

      def make_body(xml, docxml)
        body_attr = { lang: "EN-US", link: "blue", vlink: "#954F72" }
        xml.body **body_attr do |body|
          make_body1(body, docxml)
          make_body2(body, docxml)
          make_body3(body, docxml)
        end
      end

      def make_body2(body, docxml)
        body.div **{ class: "WordSection2" } do |div2|
          info docxml, div2
          div2.p { |p| p << "&nbsp;" } # placeholder
        end
        #body.br **{ clear: "all", style: "page-break-before:auto;mso-break-type:section-break;" }
        section_break(body)
      end

      def title(isoxml, _out)
        main = isoxml&.at(ns("//title[@language='en']"))&.text
        set_metadata(:doctitle, main)
      end

      def generate_header(filename, dir)
        return unless @header
        template = Liquid::Template.parse(File.read(@header, encoding: "UTF-8"))
        meta = @meta.get
        meta[:filename] = filename
        params = meta.map { |k, v| [k.to_s, v] }.to_h
        File.open("header.html", "w") { |f| f.write(template.render(params)) }
        @files_to_delete << "header.html"
        "header.html"
      end

      def header_strip(h)
        h = h.to_s.gsub(%r{<br/>}, " ").sub(/<\/?h[12][^>]*>/, "")
        h1 = to_xhtml_fragment(h.dup)
        h1.traverse do |x|
          x.replace(" ") if x.name == "span" &&
            /mso-tab-count/.match?(x["style"])
          x.remove if x.name == "span" && x["class"] == "MsoCommentReference"
          x.remove if x.name == "a" && x["epub:type"] == "footnote"
          x.replace(x.children) if x.name == "a"
        end
        from_xhtml(h1)
      end

      def info(isoxml, out)
        @meta.security isoxml, out
        super
      end

      def annex_name(annex, name, div)
        div.h1 **{ class: "Annex" } do |t|
          t << "#{get_anchors[annex['id']][:label]} "
          t << "<b>#{name.text}</b>"
        end
      end

      def annex_name_lbl(clause, num)
        obl = l10n("(#{@inform_annex_lbl})")
        obl = l10n("(#{@norm_annex_lbl})") if clause["obligation"] == "normative"
        l10n("<b>#{@annex_lbl} #{num}</b> #{obl}")
      end

      def pre_parse(node, out)
        out.pre node.text # content.gsub(/</, "&lt;").gsub(/>/, "&gt;")
      end

      def term_defs_boilerplate(div, source, term, preface)
        if source.empty? && term.nil?
          div << @no_terms_boilerplate
        else
          div << term_defs_boilerplate_cont(source, term)
        end
      end

      def i18n_init(lang, script)
        super
        @annex_lbl = "Appendix"
      end

      def error_parse(node, out)
        # catch elements not defined in ISO
        case node.name
        when "pre"
          pre_parse(node, out)
        when "keyword"
          out.span node.text, **{ class: "keyword" }
        else
          super
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
              YAML.load_file(File.join(File.dirname(__FILE__), "i18n-zh-Hans.yaml"))
            end
        @labels = @labels.merge(y)
        @clause_lbl = y["clause"]
      end

      def terms_defs_title(f)
        return f&.at(ns("./title"))&.content
      end 

           def terms_defs(isoxml, out, num)
      f = isoxml.at(ns(TERM_CLAUSE)) or return num
      out.div **attr_code(id: f["id"]) do |div|
        clause_name(nil, terms_defs_title(f), div, nil)
        f.elements.each do |e|
          parse(e, div) unless %w{title source}.include? e.name
        end
      end
      num
    end
         def middle(isoxml, out)
      middle_title(out)
      clause isoxml, out
      annex isoxml, out
      bibliography isoxml, out
    end

                  def make_body2(body, docxml)
      body.div **{ class: "WordSection2" } do |div2|
        info docxml, div2
        foreword docxml, div2
        introduction docxml, div2
         terms_defs docxml, div2, 0
        div2.p { |p| p << "&nbsp;" } # placeholder
      end
      section_break(body)
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

     def initial_anchor_names(d)
       preface_names(d.at(ns("//foreword")))
       preface_names(d.at(ns("//introduction")))
       preface_names(d.at(ns("//sections/terms | "\
                             "//sections/clause[descendant::terms]")))
       middle_section_asset_names(d)
       clause_names(d, 0)
       termnote_anchor_names(d)
       termexample_anchor_names(d)
     end

    end
  end
end
