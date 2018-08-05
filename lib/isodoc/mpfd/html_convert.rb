require "isodoc"
require_relative "metadata"

module IsoDoc
  module Mpfd

    # A {Converter} implementation that generates HTML output, and a document
    # schema encapsulation of the document for validation
    #
    class HtmlConvert < IsoDoc::HtmlConvert
      def rsd_html_path(file)
        File.join(File.dirname(__FILE__), File.join("html", file))
      end

      def initialize(options)
        super
        @htmlstylesheet = generate_css(rsd_html_path("htmlstyle.scss"), true, default_fonts(options))
        @htmlcoverpage = rsd_html_path("html_rsd_titlepage.html")
        @htmlintropage = rsd_html_path("html_rsd_intro.html")
        @scripts = rsd_html_path("scripts.html")
        system "cp #{rsd_html_path('logo.jpg')} logo.jpg"
        system "cp #{rsd_html_path('mpfa-logo-no-text@4x.png')} mpfa-logo-no-text@4x.png"
        @files_to_delete << "logo.jpg"
        @files_to_delete << "mpfa-logo-no-text@4x.png"
      end

      def default_fonts(options)
        b = options[:bodyfont] ||
          (options[:script] == "Hans" ? '"SimSun",serif' :
           '"Titillium Web",sans-serif')
        h = options[:headerfont] ||
          (options[:script] == "Hans" ? '"SimHei",sans-serif' :
           '"Titillium Web",sans-serif')
        m = options[:monospacefont] || '"Space Mono",monospace'
        "$bodyfont: #{b};\n$headerfont: #{h};\n$monospacefont: #{m};\n"
      end

      def metadata_init(lang, script, labels)
        @meta = Metadata.new(lang, script, labels)
      end

      def html_head
        <<~HEAD.freeze
    <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>

    <!--TOC script import-->
    <script type="text/javascript" src="https://cdn.rawgit.com/jgallen23/toc/0.3.2/dist/toc.min.js"></script>

    <!--Google fonts-->
    <link href="https://fonts.googleapis.com/css?family=Open+Sans:300,300i,400,400i,600,600i|Space+Mono:400,700" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css?family=Overpass:300,300i,600,900" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css?family=Titillium+Web:400,400i,700,700i" rel="stylesheet">
    <!--Font awesome import for the link icon-->
    <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.0.8/css/solid.css" integrity="sha384-v2Tw72dyUXeU3y4aM2Y0tBJQkGfplr39mxZqlTBDUZAb9BGoC40+rdFCG0m10lXk" crossorigin="anonymous">
    <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.0.8/css/fontawesome.css" integrity="sha384-q3jl8XQu1OpdLgGFvNRnPdj5VIlCvgsDQTQB6owSOHWlAurxul7f+JpUOVdAiJ5P" crossorigin="anonymous">
    <style class="anchorjs"></style>
        HEAD
      end

      def make_body(xml, docxml)
        body_attr = { lang: "EN-US", link: "blue", vlink: "#954F72", "xml:lang": "EN-US", class: "container" }
        xml.body **body_attr do |body|
          make_body1(body, docxml)
          make_body2(body, docxml)
          make_body3(body, docxml)
        end
      end

      def html_toc(docxml)
        docxml
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

     def make_body3(body, docxml)
       body.div **{ class: "main-section" } do |div3|
         foreword docxml, div3
         introduction docxml, div3
         terms_defs docxml, div3, 0
         middle docxml, div3
         footnotes div3
         comments div3
       end
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

    end
  end
end

