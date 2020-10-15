require "spec_helper"
require "fileutils"

RSpec.describe Asciidoctor::MPFA do
  it "has a version number" do
    expect(Metanorma::MPFA::VERSION).not_to be nil
  end

  it "processes a blank document" do
    input = <<~"INPUT"
    #{ASCIIDOC_BLANK_HDR}
    INPUT

    output = xmlpp(<<~"OUTPUT")
    #{BLANK_HDR}
<sections/>
</mpfd-standard>
    OUTPUT

    expect(xmlpp(Asciidoctor.convert(input, backend: :mpfa, header_footer: true))).to be_equivalent_to output
  end

  it "converts a blank document" do
    input = <<~"INPUT"
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
    INPUT

    output = xmlpp(<<~"OUTPUT")
    #{BLANK_HDR}
<sections/>
</mpfd-standard>
    OUTPUT

    system "rm -f test.html"
    system "rm -f test.doc"
    system "rm -f test.pdf"
    expect(xmlpp(Asciidoctor.convert(input, backend: :mpfa, header_footer: true))).to be_equivalent_to output
    expect(File.exist?("test.html")).to be true
    expect(File.exist?("test.pdf")).to be true
    expect(File.exist?("test.doc")).to be true
  end

  it "processes default metadata" do
    input = <<~"INPUT"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :docnumber: 1000
      :doctype: standard
      :edition: 2
      :revdate: 2000-01-01
      :draft: 3.4
      :committee: TC
      :committee-number: 1
      :committee-type: A
      :committee_2: TC2
      :committee-number_2: 2
      :committee-type_2: B
      :committee_3: TC3
      :committee-number_3: 2
      :committee-type_3: C
      :subcommittee: SC
      :subcommittee-number: 2
      :subcommittee-type: B
      :copyright-year: 2001
      :status: working-draft
      :iteration: 3
      :language: en
      :title: Main Title
      :security: Client Confidential
    INPUT

    output = xmlpp(<<~"OUTPUT")
    <?xml version="1.0" encoding="UTF-8"?>
<mpfd-standard xmlns="https://www.metanorma.org/ns/mpfd" type="semantic" version="#{Metanorma::MPFA::VERSION}">
<bibdata type="standard">
  <title language="en" format="text/plain">Main Title</title>
  <docidentifier>1000</docidentifier>
  <docnumber>1000</docnumber>
  <edition>2</edition>
<version>
  <revision-date>2000-01-01</revision-date>
  <draft>3.4</draft>
</version>  <contributor>
    <role type="author"/>
    <organization>
      <name>Mandatory Provident Fund Schemes Authority</name>
    </organization>
  </contributor>
  <contributor>
    <role type="publisher"/>
    <organization>
      <name>Mandatory Provident Fund Schemes Authority</name>
    </organization>
  </contributor>
  <language>en</language>
  <script>Latn</script>
  <status>
    <stage>working-draft</stage>
    <iteration>3</iteration>
  </status>
  <copyright>
    <from>2001</from>
    <owner>
      <organization>
      <name>Mandatory Provident Fund Schemes Authority</name>
      </organization>
    </owner>
  </copyright>
  <ext>
  <doctype>standard</doctype>
  <editorialgroup>
    <committee type="A">TC</committee>
    <committee type="B">TC2</committee>
    <committee type="C">TC3</committee>
  </editorialgroup>
  </ext>
</bibdata>
<sections/>
</mpfd-standard>
    OUTPUT

    expect(xmlpp(Asciidoctor.convert(input, backend: :mpfa, header_footer: true))).to be_equivalent_to output
  end

    it "processes default metadata" do
    input = <<~"INPUT"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :docnumber: 1000
      :status: working-draft
      :language: en
      :title: Main Title
    INPUT

        output = xmlpp(<<~"OUTPUT")
    <?xml version="1.0" encoding="UTF-8"?>
<mpfd-standard xmlns="https://www.metanorma.org/ns/mpfd" type="semantic" version="#{Metanorma::MPFA::VERSION}">
<bibdata type="standard">
  <title language="en" format="text/plain">Main Title</title>
  <docidentifier>1000</docidentifier>
  <docnumber>1000</docnumber>
  <contributor>
    <role type="author"/>
    <organization>
      <name>Mandatory Provident Fund Schemes Authority</name>
    </organization>
  </contributor>
  <contributor>
    <role type="publisher"/>
    <organization>
      <name>Mandatory Provident Fund Schemes Authority</name>
    </organization>
  </contributor>
  <language>en</language>
  <script>Latn</script>
  <status><stage>working-draft</stage></status>
  <copyright>
    <from>#{Date.today.year}</from>
    <owner>
      <organization>
      <name>Mandatory Provident Fund Schemes Authority</name>
      </organization>
    </owner>
  </copyright>
  <ext>
  <doctype>article</doctype>
  </ext>
</bibdata>
<sections/>
</mpfd-standard>
    OUTPUT

    expect(xmlpp(Asciidoctor.convert(input, backend: :mpfa, header_footer: true))).to be_equivalent_to output

    end

  it "strips inline header" do
    input = <<~"INPUT"
      #{ASCIIDOC_BLANK_HDR}
      This is a preamble

      == Section 1
    INPUT

    output = xmlpp(<<~"OUTPUT")
    #{BLANK_HDR}
             <preface><foreword id="_" obligation="informative">
         <title>Foreword</title>
         <p id="_">This is a preamble</p>
       </foreword></preface><sections>
       <clause id="_" obligation="normative">
         <title>Section 1</title>
       </clause></sections>
       </mpfd-standard>
    OUTPUT

    expect(xmlpp(strip_guid(Asciidoctor.convert(input, backend: :mpfa, header_footer: true)))).to be_equivalent_to output
  end

  it "uses default fonts" do
    input = <<~"INPUT"
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :no-pdf:
    INPUT

    system "rm -f test.html"
    Asciidoctor.convert(input, backend: :mpfa, header_footer: true)

    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r[\bpre[^{]+\{[^}]+font-family: "Space Mono", monospace;]m)
    expect(html).to match(%r[ div[^{]+\{[^}]+font-family: "Titillium Web", sans-serif;]m)
    expect(html).to match(%r[h1, h2, h3, h4, h5, h6 \{[^}]+font-family: "Titillium Web", sans-serif;]m)
  end

  it "uses Chinese fonts" do
    input = <<~"INPUT"
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :script: Hans
      :no-pdf:
    INPUT

    system "rm -f test.html"
    Asciidoctor.convert(input, backend: :mpfa, header_footer: true)

    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r[\bpre[^{]+\{[^}]+font-family: "Space Mono", monospace;]m)
    expect(html).to match(%r[ div[^{]+\{[^}]+font-family: "SimSun", serif;]m)
    expect(html).to match(%r[h1, h2, h3, h4, h5, h6 \{[^}]+font-family: "SimHei", sans-serif;]m)
  end

  it "uses specified fonts" do
    input = <<~"INPUT"
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :script: Hans
      :body-font: Zapf Chancery
      :header-font: Comic Sans
      :monospace-font: Andale Mono
      :no-pdf:
    INPUT

    system "rm -f test.html"
    Asciidoctor.convert(input, backend: :mpfa, header_footer: true)

    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r[\bpre[^{]+\{[^{]+font-family: Andale Mono;]m)
    expect(html).to match(%r[ div[^{]+\{[^}]+font-family: Zapf Chancery;]m)
    expect(html).to match(%r[h1, h2, h3, h4, h5, h6 \{[^}]+font-family: Comic Sans;]m)
  end

  it "processes inline_quoted formatting" do
    input = <<~"INPUT"
      #{ASCIIDOC_BLANK_HDR}
      _emphasis_
      *strong*
      `monospace`
      "double quote"
      'single quote'
      super^script^
      sub~script~
      stem:[a_90]
      stem:[<mml:math><mml:msub xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"> <mml:mrow> <mml:mrow> <mml:mi mathvariant="bold-italic">F</mml:mi> </mml:mrow> </mml:mrow> <mml:mrow> <mml:mrow> <mml:mi mathvariant="bold-italic">&#x391;</mml:mi> </mml:mrow> </mml:mrow> </mml:msub> </mml:math>]
      [keyword]#keyword#
      [strike]#strike#
      [smallcap]#smallcap#
    INPUT

    output = xmlpp(<<~"OUTPUT")
            #{BLANK_HDR}
       <sections>
        <p id="_"><em>emphasis</em>
       <strong>strong</strong>
       <tt>monospace</tt>
       “double quote”
       ‘single quote’
       super<sup>script</sup>
       sub<sub>script</sub>
       <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><msub><mrow>
  <mi>a</mi>
</mrow>
<mrow>
  <mn>90</mn>
</mrow>
</msub></math></stem> 
       <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><msub> <mrow> <mrow> <mi mathvariant="bold-italic">F</mi> </mrow> </mrow> <mrow> <mrow> <mi mathvariant="bold-italic">Α</mi> </mrow> </mrow> </msub> </math></stem>
       <keyword>keyword</keyword>
       <strike>strike</strike>
       <smallcap>smallcap</smallcap></p>
       </sections>
       </mpfd-standard>
    OUTPUT

    expect(xmlpp(strip_guid(Asciidoctor.convert(input, backend: :mpfa, header_footer: true)))).to be_equivalent_to output
  end

    it "processes guidance sections" do
              expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :mpfa, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
        #{ASCIIDOC_BLANK_HDR}

        == Section
        Section

        Text

        [.guidance]
        == Guidance
        Guidance
        INPUT
       #{BLANK_HDR}
  <sections>
    <clause id='_' obligation='normative'>
      <title>Section</title>
      <p id='_'>Section</p>
      <p id='_'>Text</p>
      <clause id='_' guidance='true' obligation='normative'>
        <title>Guidance</title>
        <p id='_'>Guidance</p>
      </clause>
    </clause>
  </sections>
</mpfd-standard>
        OUTPUT
    end

  it "processes sections" do
        expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :mpfa, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
        #{ASCIIDOC_BLANK_HDR}
        
        Foreword

        == Introduction
        Introduction

        == Glossary
        === Subglossary
        ==== Term
        Definition

        == Symbols
        x:: y

        [preface]
        == Prefatory

        == Acknowledgements

        == Clause 
        === Introduction
        Clause Introduction

        === Section
        Section

        [.guidance]
        === Guidance
        Guidance

        [.container]
        === Container
        Container

        [appendix]
        == Appendix 1
        Appendix

        == Bibliography
        === Subbibliography
        bibliography

INPUT
       #{BLANK_HDR}
       <preface><foreword id="_" obligation="informative">
  <title>Foreword</title>
  <p id="_">Foreword</p>
</foreword><introduction id="_" obligation="informative">
  <title>Introduction</title>
  <p id="_">Introduction</p>
</introduction><clause id="_" obligation="normative">
<title>Glossary</title>
<terms id="_" obligation="normative">
  <title>Subglossary</title>
  <term id="_">
  <preferred>Term</preferred>
  <definition><p id="_">Definition</p></definition>
</term>
</terms></clause>
<clause id="_" obligation="informative">
  <title>Prefatory</title>
</clause>
<acknowledgements id='_' obligation='informative'>
  <title>Acknowledgements</title>
</acknowledgements>
</preface><sections>

<definitions id="_" obligation="normative" type="symbols">
<title>Symbols</title>
  <dl id="_">
  <dt>x</dt>
  <dd>
    <p id="_">y</p>
  </dd>
</dl>
</definitions>

<clause id="_" obligation="normative"><title>Clause</title><clause id="_" obligation="normative">
  <title>Introduction</title>
  <p id="_">Clause Introduction</p>
</clause>
<clause id="_" obligation="normative">
  <title>Section</title>
  <p id="_">Section</p>
<clause id="_" guidance="true" obligation="normative">
  <title>Guidance</title>
  <p id="_">Guidance</p>
</clause></clause>
<clause id="_" container="true" obligation="normative">
  <title>Container</title>
  <p id="_">Container</p>
</clause></clause>

</sections><annex id="_" obligation="normative">
  <title>Appendix 1</title>
  <p id="_">Appendix</p>
</annex><bibliography><clause id="_" obligation="informative">
  <title>Bibliography</title>
  <references id="_" obligation="informative" normative="false">
  <title>Subbibliography</title>
  <p id="_">bibliography</p>
</references>
</clause></bibliography>
</mpfd-standard>
OUTPUT
  end

    it "processes sections" do
        expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :mpfa, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
        #{ASCIIDOC_BLANK_HDR}

        Foreword

        == Introduction
        Introduction

        == Glossary
        === Term
        Definition

        [preface]
        == Prefatory

        == Bibliography
        bibliography

INPUT
#{BLANK_HDR}
<preface><foreword id="_" obligation="informative">
  <title>Foreword</title>
  <p id="_">Foreword</p>
</foreword><introduction id="_" obligation="informative">
  <title>Introduction</title>
  <p id="_">Introduction</p>
</introduction><terms id="_" obligation="normative">
  <title>Glossary</title>
  <term id="_">
  <preferred>Term</preferred>
  <definition><p id="_">Definition</p></definition>
</term>
</terms><clause id="_" obligation="informative">
  <title>Prefatory</title>
</clause></preface><sections>



</sections><bibliography><references id="_" obligation="informative" normative="false">
  <title>Bibliography</title>
  <p id="_">bibliography</p>
</references></bibliography>
</mpfd-standard>
OUTPUT
end

end
