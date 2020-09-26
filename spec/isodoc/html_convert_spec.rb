require "spec_helper"

logoloc = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "lib", "isodoc", "mpfa", "html"))

RSpec.describe IsoDoc::MPFA do

  it "processes default metadata" do
    csdc = IsoDoc::MPFA::HtmlConvert.new({})
    input = <<~"INPUT"
<mpfd-standard xmlns="https://open.ribose.com/standards/rsd">
<bibdata type="standard">
  <title language="en" format="plain">Main Title</title>
  <docidentifier>1000</docidentifier>
  <docnumber>1000</docnumber>
  <contributor>
    <role type="author"/>
    <organization>
      <name>Ribose</name>
    </organization>
  </contributor>
  <contributor>
    <role type="publisher"/>
    <organization>
      <name>Ribose</name>
    </organization>
  </contributor>
  <language>en</language>
  <script>Latn</script>
  <status><stage>published</stage></status>
  <copyright>
    <from>2001</from>
    <owner>
      <organization>
        <name>Ribose</name>
      </organization>
    </owner>
  </copyright>
  <ext>
  <doctype>standard</doctype>
  <editorialgroup>
    <committee type="A">TC</committee>
  </editorialgroup>
  <security>Client Confidential</security>
  </ext>
</bibdata><version>
  <edition>2</edition>
  <revision-date>2000-01-01</revision-date>
  <draft>3.4</draft>
</version>
<sections/>
</mpfd-standard>
    INPUT

    output = <<~"OUTPUT"
{:accesseddate=>"XXX",
:circulateddate=>"XXX",
:confirmeddate=>"XXX",
:copieddate=>"XXX",
:createddate=>"XXX",
:docnumber=>"1000",
:docnumeric=>"1000",
:doctitle=>"Main Title",
:doctype=>"Standard",
:docyear=>"2001",
:draft=>"3.4",
:draftinfo=>" (draft 3.4, 2000-01-01)",
:edition=>"Second",
:implementeddate=>"XXX",
:issueddate=>"XXX",
:keywords=>[],
:logo=>"#{File.join(logoloc, "mpfa-logo-no-text@4x.png")}",
:obsoleteddate=>"XXX",
:publisheddate=>"XXX",
:publisher=>"Ribose",
:receiveddate=>"XXX",
:revdate=>"2000-01-01",
:revdate_monthyear=>"1 January 2000",
:stage=>"Published",
:transmitteddate=>"XXX",
:unchangeddate=>"XXX",
:unpublished=>false,
:updateddate=>"XXX",
:vote_endeddate=>"XXX",
:vote_starteddate=>"XXX"}
    OUTPUT

    docxml, filename, dir = csdc.convert_init(input, "test", true)
    expect(htmlencode(Hash[csdc.info(docxml, nil).sort].to_s).gsub(/, :/, ",\n:")).to be_equivalent_to output
  end

  it "processes pre" do
    input = <<~"INPUT"
<mpfd-standard xmlns="https://open.ribose.com/standards/rsd">
<preface><foreword>
<pre>ABC</pre>
</foreword></preface>
</mpfd-standard>
    INPUT

    output = xmlpp(<<~"OUTPUT")
    #{HTML_HDR}
             <div>
               <h1/>
               <pre>ABC</pre>
             </div>
             <p class="zzSTDTitle1"/>
           </div>
         </body>
    OUTPUT

    expect(xmlpp(
      IsoDoc::MPFA::HtmlConvert.new({}).
      convert("test", input, true).
      gsub(%r{^.*<body}m, "<body").
      gsub(%r{</body>.*}m, "</body>")
    )).to be_equivalent_to output
  end

  it "processes keyword" do
    input = <<~"INPUT"
<mpfd-standard xmlns="https://open.ribose.com/standards/rsd">
<preface><foreword>
<keyword>ABC</keyword>
</foreword></preface>
</mpfd-standard>
    INPUT

    output = xmlpp(<<~"OUTPUT")
    #{HTML_HDR}
             <div>
               <h1/>
               <span class="keyword">ABC</span>
             </div>
             <p class="zzSTDTitle1"/>
           </div>
         </body>
    OUTPUT

    expect(xmlpp(
      IsoDoc::MPFA::HtmlConvert.new({}).
      convert("test", input, true).
      gsub(%r{^.*<body}m, "<body").
      gsub(%r{</body>.*}m, "</body>")
    )).to be_equivalent_to output

  end

  it "processes section names" do
    input = <<~"INPUT"
    <mpfd-standard xmlns="http://riboseinc.com/isoxml">
      <preface>
      <abstract obligation="informative">
         <title>Summary</title>
         <p id="AA">This is an abstract</p>
       </abstract>
      <foreword obligation="informative">
         <title>Foreword</title>
         <p id="A">This is a preamble</p>
       </foreword>
        <introduction id="B" obligation="informative"><title>Introduction</title><clause id="C" inline-header="false" obligation="informative">
         <title>Introduction Subsection</title>
       </clause>
       </introduction>
        <clause id="H" obligation="normative"><title>Terms, Definitions, Symbols and Abbreviated Terms</title><terms id="I" obligation="normative">
         <title>Normal Terms</title>
         <term id="J">
         <preferred>Term2</preferred>
       </term>
       </terms>
       <definitions id="K">
         <dl>
         <dt>Symbol</dt>
         <dd>Definition</dd>
         </dl>
       </definitions>
       </clause>
        </preface><sections>
       <clause id="D" obligation="normative" type="scope">
         <title>Scope</title>
         <p id="E">Text</p>
       </clause>

       <definitions id="L">
         <dl>
         <dt>Symbol</dt>
         <dd>Definition</dd>
         </dl>
       </definitions>
       <clause id="M" inline-header="false" obligation="normative"><title>Clause 4</title><clause id="N" inline-header="false" obligation="normative">
         <title>Introduction</title>
       </clause>
       <clause id="O" inline-header="false" obligation="normative">
         <title>Clause 4.2</title>
       </clause></clause>

       </sections><annex id="P" inline-header="false" obligation="normative">
         <title>Annex</title>
         <clause id="Q" inline-header="false" obligation="normative">
         <title>Annex A.1</title>
         <clause id="Q1" inline-header="false" obligation="normative">
         <title>Annex A.1a</title>
         </clause>
       </clause>
       <references id="R" obligation="informative" normative="true">
         <title>Normative References</title>
       </references><clause id="S" obligation="informative">
         <title>Bibliography</title>
         <references id="T" obligation="informative" normative="false">
         <title>Bibliography Subsection</title>
       </references>
       </clause>
       </annex>
       </mpfd-standard>
    INPUT

    presxml = <<~OUTPUT
    <mpfd-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
         <preface>
         <abstract obligation="informative">
            <title>Summary</title>
            <p id="AA">This is an abstract</p>
          </abstract>
         <foreword obligation="informative">
            <title>Foreword</title>
            <p id="A">This is a preamble</p>
          </foreword>
           <introduction id="B" obligation="informative"><title>Introduction</title><clause id="C" inline-header="false" obligation="informative">
            <title depth="2">Introduction Subsection</title>
          </clause>
          </introduction>
           <clause id="H" obligation="normative"><title depth="1">Terms, Definitions, Symbols and Abbreviated Terms</title><terms id="I" obligation="normative">
            <title depth="2">Normal Terms</title>
            <term id="J">
            <preferred>Term2</preferred>
          </term>
          </terms>
          <definitions id="K">
            <dl>
            <dt>Symbol</dt>
            <dd>Definition</dd>
            </dl>
          </definitions>
          </clause>
           </preface><sections>
          <clause id="D" obligation="normative" type="scope">
            <title depth="1">1.<tab/>Scope</title>
            <p id="E">Text</p>
          </clause>

          <definitions id="L">
            <dl>
            <dt>Symbol</dt>
            <dd>Definition</dd>
            </dl>
          </definitions>
          <clause id="M" inline-header="false" obligation="normative"><title depth="1">2.<tab/>Clause 4</title><clause id="N" inline-header="false" obligation="normative">
            <title depth="2">2.1.<tab/>Introduction</title>
          </clause>
          <clause id="O" inline-header="false" obligation="normative">
            <title depth="2">2.2.<tab/>Clause 4.2</title>
          </clause></clause>

          </sections><annex id="P" inline-header="false" obligation="normative">
            <title><strong>Appendix A</strong> <strong>Annex</strong></title>
            <clause id="Q" inline-header="false" obligation="normative">
            <title depth="2">A.1.<tab/>Annex A.1</title>
            <clause id="Q1" inline-header="false" obligation="normative">
            <title depth="3">A.1.1.<tab/>Annex A.1a</title>
            </clause>
          </clause>
          <references id="R" obligation="informative" normative="true">
            <title depth="2">A.2.<tab/>Normative References</title>
          </references><clause id="S" obligation="informative">
            <title depth="2">A.3.<tab/>Bibliography</title>
            <references id="T" obligation="informative" normative="false">
            <title depth="3">A.3.1.<tab/>Bibliography Subsection</title>
          </references>
          </clause>
          </annex>
          </mpfd-standard>
          OUTPUT

    html = xmlpp(<<~"OUTPUT")
    #{HTML_HDR}
    <div>
             <h1>Summary</h1>
             <p id='AA'>This is an abstract</p>
           </div>
           <div>
             <h1>Foreword</h1>
             <p id='A'>This is a preamble</p>
           </div>
           <div id='B'>
             <h1>Introduction</h1>
             <div id='C'>
               <h2>Introduction Subsection</h2>
             </div>
           </div>
           <div id='H'>
             <h1>Terms, Definitions, Symbols and Abbreviated Terms</h1>
             <div id='I'>
               <h2>Normal Terms</h2>
               <p class='Terms' style='text-align:left;'>Term2</p>
             </div>
             <div id='K'>
               <h2>Symbols</h2>
               <dl>
                 <dt>
                   <p>Symbol</p>
                 </dt>
                 <dd>Definition</dd>
               </dl>
             </div>
           </div>
           <p class='zzSTDTitle1'/>
           <div id='D'>
  <h1>1.&#160; Scope</h1>
  <p id='E'>Text</p>
</div>
           <div id='M'>
             <h1>2.&#160; Clause 4</h1>
             <div id='N'>
               <h2>2.1.&#160; Introduction</h2>
             </div>
             <div id='O'>
               <h2>2.2.&#160; Clause 4.2</h2>
             </div>
           </div>
           <br/>
           <div id='P' class='Section3'>
             <h1 class='Annex'>
               <b>Appendix A</b>
               <b>Annex</b>
             </h1>
             <div id='Q'>
               <h2>A.1.&#160; Annex A.1</h2>
               <div id='Q1'>
                 <h3>A.1.1.&#160; Annex A.1a</h3>
               </div>
             </div>
             <div>
               <h2 class='Section3'>A.2.&#160; Normative References</h2>
             </div>
             <div id='S'>
               <h2>A.3.&#160; Bibliography</h2>
               <div>
                 <h3 class='Section3'>A.3.1.&#160; Bibliography Subsection</h3>
               </div>
             </div>
           </div>
         </div>
       </body>
    OUTPUT

     word = xmlpp(<<~"OUTPUT")
     <body lang='EN-US' link='blue' vlink='#954F72'>
         <div class='WordSection1'>
           <p>&#160;</p>
         </div>
         <p>
           <br clear='all' class='section'/>
         </p>
         <div class='WordSection2'>
           <p>
             <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
           </p>
           <div>
             <h1 class='AbstractTitle'>Summary</h1>
             <p id='AA'>This is an abstract</p>
           </div>
           <p>
             <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
           </p>
           <div>
             <h1 class='ForewordTitle'>Foreword</h1>
             <p id='A'>This is a preamble</p>
           </div>
           <p>
             <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
           </p>
           <div class='Section3' id='B'>
             <h1 class='IntroTitle'>Introduction</h1>
             <div id='C'>
               <h2>Introduction Subsection</h2>
             </div>
           </div>
           <div id='H'>
             <h1>Terms, Definitions, Symbols and Abbreviated Terms</h1>
             <div id='I'>
               <h2>Normal Terms</h2>
               <p class='Terms' style='text-align:left;'>Term2</p>
             </div>
             <div id='K'>
               <h2>Symbols</h2>
               <table class='dl'>
                 <tr>
                   <td valign='top' align='left'>
                     <p align='left' style='margin-left:0pt;text-align:left;'>Symbol</p>
                   </td>
                   <td valign='top'>Definition</td>
                 </tr>
               </table>
             </div>
           </div>
           <p>&#160;</p>
         </div>
         <p>
           <br clear='all' class='section'/>
         </p>
         <div class='WordSection3'>
           <p class='zzSTDTitle1'/>
           <div id='D'>
  <h1>
    1.
    <span style='mso-tab-count:1'>&#160; </span>
    Scope
  </h1>
  <p id='E'>Text</p>
</div>
           <div id='M'>
             <h1>
               2.
               <span style='mso-tab-count:1'>&#160; </span>
               Clause 4
             </h1>
             <div id='N'>
               <h2>
                 2.1.
                 <span style='mso-tab-count:1'>&#160; </span>
                 Introduction
               </h2>
             </div>
             <div id='O'>
               <h2>
                 2.2.
                 <span style='mso-tab-count:1'>&#160; </span>
                 Clause 4.2
               </h2>
             </div>
           </div>
           <p>
             <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
           </p>
           <div id='P' class='Section3'>
             <h1 class='Annex'>
               <b>Appendix A</b>
               <b>Annex</b>
             </h1>
             <div id='Q'>
               <h2>
                 A.1.
                 <span style='mso-tab-count:1'>&#160; </span>
                 Annex A.1
               </h2>
               <div id='Q1'>
                 <h3>
                   A.1.1.
                   <span style='mso-tab-count:1'>&#160; </span>
                   Annex A.1a
                 </h3>
               </div>
             </div>
             <div>
               <h2 class='Section3'>
                 A.2.
                 <span style='mso-tab-count:1'>&#160; </span>
                 Normative References
               </h2>
             </div>
             <div id='S'>
               <h2>
                 A.3.
                 <span style='mso-tab-count:1'>&#160; </span>
                 Bibliography
               </h2>
               <div>
                 <h3 class='Section3'>
                   A.3.1.
                   <span style='mso-tab-count:1'>&#160; </span>
                   Bibliography Subsection
                 </h3>
               </div>
             </div>
           </div>
         </div>
       </body>
    OUTPUT

    expect(xmlpp(IsoDoc::MPFA::PresentationXMLConvert.new({}).convert("test", input, true))).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(
      IsoDoc::MPFA::HtmlConvert.new({}).convert("test", presxml, true).
      gsub(%r{^.*<body}m, "<body").
      gsub(%r{</body>.*}m, "</body>")
    )).to be_equivalent_to html
    expect(xmlpp(
     IsoDoc::MPFA::WordConvert.new({}).convert("test", presxml, true).
      gsub(%r{^.*<body}m, "<body").
      gsub(%r{</body>.*}m, "</body>")
    )).to be_equivalent_to word
  end

  it "injects JS into blank html" do
    system "rm -f test.html"
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

    expect(xmlpp(Asciidoctor.convert(input, backend: :mpfa, header_footer: true))).to be_equivalent_to output
    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r{jquery\.min\.js})
    expect(html).to match(%r{Overpass})
  end

  it "processes Simplified Chinese" do
    input = <<~"INPUT"
    <mpfd-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
      <language>zh</language>
      <script>Hans</script>
      </bibdata>
      <preface>
      <foreword obligation="informative">
         <title>Foreword</title>
         <p id="A">This is a preamble</p>
       </foreword>
        <introduction id="B" obligation="informative"><title>Introduction</title><clause id="C" inline-header="false" obligation="informative">
         <title>Introduction Subsection</title>
       </clause>
       </introduction>
        <clause id="H" obligation="normative"><title>Terms, Definitions, Symbols and Abbreviated Terms</title><terms id="I" obligation="normative">
         <title>Normal Terms</title>
         <term id="J">
         <preferred>Term2</preferred>
       </term>
       </terms>
       <definitions id="K">
         <dl>
         <dt>Symbol</dt>
         <dd>Definition</dd>
         </dl>
       </definitions>
       </clause>
       </preface><sections>
       <clause id="D" obligation="normative" type="scope">
         <title>Scope</title>
         <p id="E">Text</p>
       </clause>

       <definitions id="L">
         <dl>
         <dt>Symbol</dt>
         <dd>Definition</dd>
         </dl>
       </definitions>
       <clause id="M" inline-header="false" obligation="normative"><title>Clause 4</title><clause id="N" inline-header="false" obligation="normative">
         <title>Introduction</title>
       </clause>
       <clause id="O" inline-header="false" obligation="normative">
         <title>Clause 4.2</title>
       </clause></clause>

       </sections><annex id="P" inline-header="false" obligation="normative">
         <title>Annex</title>
         <clause id="Q" inline-header="false" obligation="normative">
         <title>Annex A.1</title>
         <clause id="Q1" inline-header="false" obligation="normative">
         <title>Annex A.1a</title>
         </clause>
       </clause>
       </annex><bibliography><references id="R" obligation="informative" normative="true">
         <title>Normative References</title>
       </references><clause id="S" obligation="informative">
         <title>Bibliography</title>
         <references id="T" obligation="informative" normative="false">
         <title>Bibliography Subsection</title>
       </references>
       </clause>
       </bibliography>
       </mpfd-standard>
    INPUT

    presxml = <<~OUTPUT
    <mpfd-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
         <bibdata>
         <language>zh</language>
         <script>Hans</script>
         </bibdata>
         <local_bibdata>
         <language>zh</language>
         <script>Hans</script>
         </local_bibdata>
         <preface>
         <foreword obligation="informative">
            <title>Foreword</title>
            <p id="A">This is a preamble</p>
          </foreword>
           <introduction id="B" obligation="informative"><title>Introduction</title><clause id="C" inline-header="false" obligation="informative">
            <title depth="2">Introduction Subsection</title>
          </clause>
          </introduction>
           <clause id="H" obligation="normative"><title depth="1">Terms, Definitions, Symbols and Abbreviated Terms</title><terms id="I" obligation="normative">
            <title depth="2">Normal Terms</title>
            <term id="J">
            <preferred>Term2</preferred>
          </term>
          </terms>
          <definitions id="K">
            <dl>
            <dt>Symbol</dt>
            <dd>Definition</dd>
            </dl>
          </definitions>
          </clause>
          </preface><sections>
          <clause id="D" obligation="normative" type="scope">
            <title depth="1">1.<tab/>Scope</title>
            <p id="E">Text</p>
          </clause>

          <definitions id="L">
            <dl>
            <dt>Symbol</dt>
            <dd>Definition</dd>
            </dl>
          </definitions>
          <clause id="M" inline-header="false" obligation="normative"><title depth="1">2.<tab/>Clause 4</title><clause id="N" inline-header="false" obligation="normative">
            <title depth="2">2.1.<tab/>Introduction</title>
          </clause>
          <clause id="O" inline-header="false" obligation="normative">
            <title depth="2">2.2.<tab/>Clause 4.2</title>
          </clause></clause>

          </sections><annex id="P" inline-header="false" obligation="normative">
            <title><strong>&#x9644;&#x5F55;A</strong> <strong>Annex</strong></title>
            <clause id="Q" inline-header="false" obligation="normative">
            <title depth="2">A.1.<tab/>Annex A.1</title>
            <clause id="Q1" inline-header="false" obligation="normative">
            <title depth="3">A.1.1.<tab/>Annex A.1a</title>
            </clause>
          </clause>
          </annex><bibliography><references id="R" obligation="informative" normative="true">
            <title depth="1">[R].<tab/>Normative References</title>
          </references><clause id="S" obligation="informative">
            <title depth="1">Bibliography</title>
            <references id="T" obligation="informative" normative="false">
            <title depth="2">Bibliography Subsection</title>
          </references>
          </clause>
          </bibliography>
          </mpfd-standard>
       OUTPUT

    html = xmlpp(<<~"OUTPUT")
    #{HTML_HDR}
    <div>
             <h1>Foreword</h1>
             <p id='A'>This is a preamble</p>
           </div>
           <div id='B'>
             <h1>Introduction</h1>
             <div id='C'>
               <h2>Introduction Subsection</h2>
             </div>
           </div>
           <div id='H'>
             <h1>Terms, Definitions, Symbols and Abbreviated Terms</h1>
             <div id='I'>
               <h2>Normal Terms</h2>
               <p class='Terms' style='text-align:left;'>Term2</p>
             </div>
             <div id='K'>
               <h2>&#31526;&#21495;</h2>
               <dl>
                 <dt>
                   <p>Symbol</p>
                 </dt>
                 <dd>Definition</dd>
               </dl>
             </div>
           </div>
           <p class='zzSTDTitle1'/>
           <div id='D'>
  <h1>1.&#12288;Scope</h1>
  <p id='E'>Text</p>
</div>
           <div id='M'>
             <h1>2.&#12288;Clause 4</h1>
             <div id='N'>
               <h2>2.1.&#12288;Introduction</h2>
             </div>
             <div id='O'>
               <h2>2.2.&#12288;Clause 4.2</h2>
             </div>
           </div>
           <br/>
           <div id='P' class='Section3'>
             <h1 class='Annex'>
               <b>&#38468;&#24405;A</b>
               <b>Annex</b>
             </h1>
             <div id='Q'>
               <h2>A.1.&#12288;Annex A.1</h2>
               <div id='Q1'>
                 <h3>A.1.1.&#12288;Annex A.1a</h3>
               </div>
             </div>
           </div>
           <br/>
           <div>
             <h1 class='Section3'>Bibliography</h1>
             <div>
               <h2 class='Section3'>Bibliography Subsection</h2>
             </div>
           </div>
         </div>
       </body>
    OUTPUT

    word = <<~OUTPUT
       <body lang='EN-US' link='blue' vlink='#954F72'>
         <div class='WordSection1'>
           <p>&#160;</p>
         </div>
         <p>
           <br clear='all' class='section'/>
         </p>
         <div class='WordSection2'>
           <p>
             <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
           </p>
           <div>
             <h1 class='ForewordTitle'>Foreword</h1>
             <p id='A'>This is a preamble</p>
           </div>
           <p>
             <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
           </p>
           <div class='Section3' id='B'>
             <h1 class='IntroTitle'>Introduction</h1>
             <div id='C'>
               <h2>Introduction Subsection</h2>
             </div>
           </div>
           <div id='H'>
             <h1>Terms, Definitions, Symbols and Abbreviated Terms</h1>
             <div id='I'>
               <h2>Normal Terms</h2>
               <p class='Terms' style='text-align:left;'>Term2</p>
             </div>
             <div id='K'>
               <h2>&#31526;&#21495;</h2>
               <table class='dl'>
                 <tr>
                   <td valign='top' align='left'>
                     <p align='left' style='margin-left:0pt;text-align:left;'>Symbol</p>
                   </td>
                   <td valign='top'>Definition</td>
                 </tr>
               </table>
             </div>
           </div>
           <p>&#160;</p>
         </div>
         <p>
           <br clear='all' class='section'/>
         </p>
         <div class='WordSection3'>
           <p class='zzSTDTitle1'/>
           <div id='D'>
  <h1>
    1.
    <span style='mso-tab-count:1'>&#160; </span>
    Scope
  </h1>
  <p id='E'>Text</p>
</div>
           <div id='M'>
             <h1>
               2.
               <span style='mso-tab-count:1'>&#160; </span>
               Clause 4
             </h1>
             <div id='N'>
               <h2>
                 2.1.
                 <span style='mso-tab-count:1'>&#160; </span>
                 Introduction
               </h2>
             </div>
             <div id='O'>
               <h2>
                 2.2.
                 <span style='mso-tab-count:1'>&#160; </span>
                 Clause 4.2
               </h2>
             </div>
           </div>
           <p>
             <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
           </p>
           <div id='P' class='Section3'>
             <h1 class='Annex'>
               <b>&#38468;&#24405;A</b>
               <b>Annex</b>
             </h1>
             <div id='Q'>
               <h2>
                 A.1.
                 <span style='mso-tab-count:1'>&#160; </span>
                 Annex A.1
               </h2>
               <div id='Q1'>
                 <h3>
                   A.1.1.
                   <span style='mso-tab-count:1'>&#160; </span>
                   Annex A.1a
                 </h3>
               </div>
             </div>
           </div>
           <p>
             <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
           </p>
           <div>
             <h1 class='Section3'>Bibliography</h1>
             <div>
               <h2 class='Section3'>Bibliography Subsection</h2>
             </div>
           </div>
         </div>
       </body>
OUTPUT

    expect(xmlpp(IsoDoc::MPFA::PresentationXMLConvert.new({}).convert("test", input, true))).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(
      IsoDoc::MPFA::HtmlConvert.new({}).convert("test", presxml, true).
      gsub(%r{^.*<body}m, "<body").
      gsub(%r{</body>.*}m, "</body>")
    )).to be_equivalent_to xmlpp(html)

    expect(xmlpp(
     IsoDoc::MPFA::WordConvert.new({}).convert("test", presxml, true).
      gsub(%r{^.*<body}m, "<body").
      gsub(%r{</body>.*}m, "</body>")
    )).to be_equivalent_to xmlpp(word)
  end

  it "processes containers" do
    input = <<~INPUT
      <mpfd-standard xmlns="https://open.ribose.com/standards/rsd">
<sections>
    <clause id="A">
        <title>A</title>
        <p>
        <xref target="A"/>
        <xref target="B"/>
        <xref target="C"/>
        <xref target="D"/>
        <xref target="E"/>
        <xref target="F"/>
        <xref target="G"/>
        <xref target="AA"/>
        <xref target="AB"/>
        <xref target="AC"/>
        <xref target="AD"/>
        <xref target="AE"/>
        <xref target="AF"/>
        <xref target="AG"/>
        </p>
    </clause>
    <clause id="B" container="true">
        <title>B</title>
        <clause id="C" inline-header="true">
            <title>C</title>
            <clause id="D" inline-header="true">
                <title>D</title>
            </clause>
        </clause>
        <clause id="E" container="true">
            <title>E</title>
            <clause id="F">
                <title>F</title>
            </clause>
            <clause id="G">
                <title>G</title>
            </clause>
        </clause>
    </clause>
</sections>
<annex id="A0"><title>Annex</title>
    <clause id="AA">
        <title>A</title>
    </clause>
    <clause id="AB" container="true">
        <title>B</title>
        <clause id="AC">
            <title>C</title>
            <clause id="AD">
                <title>D</title>
            </clause>
        </clause>
        <clause id="AE" container="true">
            <title>E</title>
            <clause id="AF">
                <title>F</title>
            </clause>
            <clause id="AG">
                <title>G</title>
            </clause>
        </clause>
    </clause>
</annex>
</mpfd-standard>
INPUT
presxml = <<~OUTPUT
       <mpfd-standard xmlns="https://open.ribose.com/standards/rsd" type="presentation">
       <sections>
           <clause id="A">
               <title depth="1">1.<tab/>A</title>
               <p>
               <xref target="A">Paragraph 1</xref>
               <xref target="B">B</xref>
               <xref target="C">Paragraph 2</xref>
               <xref target="D">Paragraph 2.1</xref>
               <xref target="E">E</xref>
               <xref target="F">Paragraph 3</xref>
               <xref target="G">Paragraph 4</xref>
               <xref target="AA">Appendix A.1</xref>
               <xref target="AB">B</xref>
               <xref target="AC">Appendix A.1.1</xref>
               <xref target="AD">Appendix A.1.1.1</xref>
               <xref target="AE">E</xref>
               <xref target="AF">Appendix A.1.1.1</xref>
               <xref target="AG">Appendix A.1.1.2</xref>
               </p>
           </clause>
           <clause id="B" container="true">
               <title depth="1">B</title>
               <clause id="C" inline-header="true">
                   <title depth="1">2.<tab/>C</title>
                   <clause id="D" inline-header="true">
                       <title depth="2">2.1.<tab/>D</title>
                   </clause>
               </clause>
               <clause id="E" container="true">
                   <title depth="2">E</title>
                   <clause id="F">
                       <title depth="2">3.<tab/>F</title>
                   </clause>
                   <clause id="G">
                       <title depth="2">4.<tab/>G</title>
                   </clause>
               </clause>
           </clause>
       </sections>
       <annex id="A0"><title><strong>Appendix A</strong> <strong>Annex</strong></title>
           <clause id="AA">
               <title depth="2">A.1.<tab/>A</title>
           </clause>
           <clause id="AB" container="true">
               <title depth="1">B</title>
               <clause id="AC">
                   <title depth="3">A.1.1.<tab/>C</title>
                   <clause id="AD">
                       <title depth="4">A.1.1.1.<tab/>D</title>
                   </clause>
               </clause>
               <clause id="AE" container="true">
                   <title depth="2">E</title>
                   <clause id="AF">
                       <title depth="4">A.1.1.1.<tab/>F</title>
                   </clause>
                   <clause id="AG">
                       <title depth="4">A.1.1.2.<tab/>G</title>
                   </clause>
               </clause>
           </clause>
       </annex>
       </mpfd-standard>
OUTPUT

html = <<~OUTPUT
         <body lang='EN-US' xml:lang='EN-US' link='blue' vlink='#954F72' class='container'>
         <div class='title-section'>
           <p>&#160;</p>
         </div>
         <br/>
         <div class='prefatory-section'>
           <p>&#160;</p>
         </div>
         <br/>
         <div class='main-section'>
           <p class='zzSTDTitle1'/>
           <div id='A'>
             <h1>1.&#160; A</h1>
             <p>
               <a href='#A'>Paragraph 1</a>
               <a href='#B'>B</a>
               <a href='#C'>Paragraph 2</a>
               <a href='#D'>Paragraph 2.1</a>
               <a href='#E'>E</a>
               <a href='#F'>Paragraph 3</a>
               <a href='#G'>Paragraph 4</a>
               <a href='#AA'>Appendix A.1</a>
               <a href='#AB'>B</a>
               <a href='#AC'>Appendix A.1.1</a>
               <a href='#AD'>Appendix A.1.1.1</a>
               <a href='#AE'>E</a>
               <a href='#AF'>Appendix A.1.1.1</a>
               <a href='#AG'>Appendix A.1.1.2</a>
             </p>
           </div>
           <div id='B'>
             <h1 class='containerhdr'>B</h1>
             <div id='C'>
               <span class='zzMoveToFollowing'>
                 <b>2.&#160; C&#160; </b>
               </span>
               <div id='D'>
                 <span class='zzMoveToFollowing'>
                   <b>2.1.&#160; D&#160; </b>
                 </span>
               </div>
             </div>
             <div id='E'>
               <h2 class='containerhdr'>E</h2>
               <div id='F'>
                 <h2>3.&#160; F</h2>
               </div>
               <div id='G'>
                 <h2>4.&#160; G</h2>
               </div>
             </div>
           </div>
           <br/>
           <div id='A0' class='Section3'>
             <h1 class='Annex'>
               <b>Appendix A</b>
               <b>Annex</b>
             </h1>
             <div id='AA'>
               <h2>A.1.&#160; A</h2>
             </div>
             <div id='AB'>
               <h1 class='containerhdr'>B</h1>
               <div id='AC'>
                 <h3>A.1.1.&#160; C</h3>
                 <div id='AD'>
                   <h4>A.1.1.1.&#160; D</h4>
                 </div>
               </div>
               <div id='AE'>
                 <h2 class='containerhdr'>E</h2>
                 <div id='AF'>
                   <h4>A.1.1.1.&#160; F</h4>
                 </div>
                 <div id='AG'>
                   <h4>A.1.1.2.&#160; G</h4>
                 </div>
               </div>
             </div>
           </div>
         </div>
       </body>
OUTPUT
word = <<~OUTPUT
         <body lang='EN-US' link='blue' vlink='#954F72'>
         <div class='WordSection1'>
           <p>&#160;</p>
         </div>
         <p>
           <br clear='all' class='section'/>
         </p>
         <div class='WordSection2'>
           <p>&#160;</p>
         </div>
         <p>
           <br clear='all' class='section'/>
         </p>
         <div class='WordSection3'>
           <p class='zzSTDTitle1'/>
           <div id='A'>
             <h1>
               1.
               <span style='mso-tab-count:1'>&#160; </span>
               A
             </h1>
             <p>
               <a href='#A'>Paragraph 1</a>
               <a href='#B'>B</a>
               <a href='#C'>Paragraph 2</a>
               <a href='#D'>Paragraph 2.1</a>
               <a href='#E'>E</a>
               <a href='#F'>Paragraph 3</a>
               <a href='#G'>Paragraph 4</a>
               <a href='#AA'>Appendix A.1</a>
               <a href='#AB'>B</a>
               <a href='#AC'>Appendix A.1.1</a>
               <a href='#AD'>Appendix A.1.1.1</a>
               <a href='#AE'>E</a>
               <a href='#AF'>Appendix A.1.1.1</a>
               <a href='#AG'>Appendix A.1.1.2</a>
             </p>
           </div>
           <div id='B'>
             <h1 class='containerhdr'>B</h1>
             <div id='C'>
               <span class='zzMoveToFollowing'>
                 <b>
                   2.
                   <span style='mso-tab-count:1'>&#160; </span>
                   C
                   <span style='mso-tab-count:1'>&#160; </span>
                 </b>
               </span>
               <div id='D'>
                 <span class='zzMoveToFollowing'>
                   <b>
                     2.1.
                     <span style='mso-tab-count:1'>&#160; </span>
                     D
                     <span style='mso-tab-count:1'>&#160; </span>
                   </b>
                 </span>
               </div>
             </div>
             <div id='E'>
               <h2 class='containerhdr'>E</h2>
               <div id='F'>
                 <h2>
                   3.
                   <span style='mso-tab-count:1'>&#160; </span>
                   F
                 </h2>
               </div>
               <div id='G'>
                 <h2>
                   4.
                   <span style='mso-tab-count:1'>&#160; </span>
                   G
                 </h2>
               </div>
             </div>
           </div>
           <p>
             <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
           </p>
           <div id='A0' class='Section3'>
             <h1 class='Annex'>
               <b>Appendix A</b>
               <b>Annex</b>
             </h1>
             <div id='AA'>
               <h2>
                 A.1.
                 <span style='mso-tab-count:1'>&#160; </span>
                 A
               </h2>
             </div>
             <div id='AB'>
               <h1 class='containerhdr'>B</h1>
               <div id='AC'>
                 <h3>
                   A.1.1.
                   <span style='mso-tab-count:1'>&#160; </span>
                   C
                 </h3>
                 <div id='AD'>
                   <h4>
                     A.1.1.1.
                     <span style='mso-tab-count:1'>&#160; </span>
                     D
                   </h4>
                 </div>
               </div>
               <div id='AE'>
                 <h2 class='containerhdr'>E</h2>
                 <div id='AF'>
                   <h4>
                     A.1.1.1.
                     <span style='mso-tab-count:1'>&#160; </span>
                     F
                   </h4>
                 </div>
                 <div id='AG'>
                   <h4>
                     A.1.1.2.
                     <span style='mso-tab-count:1'>&#160; </span>
                     G
                   </h4>
                 </div>
               </div>
             </div>
           </div>
         </div>
       </body>
OUTPUT
      expect((IsoDoc::MPFA::PresentationXMLConvert.new({}).convert("test", input, true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(presxml)
      expect(xmlpp(IsoDoc::MPFA::HtmlConvert.new({}).convert("test", presxml, true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(html)
      expect(xmlpp(IsoDoc::MPFA::WordConvert.new({}).convert("test", presxml, true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(word)
    end

    it "processes ordered list style" do
          input = <<~"INPUT"
<mpfd-standard xmlns="https://open.ribose.com/standards/rsd">
<preface><foreword>
<ol type="roman">
<li><ol type="arabic">
<li>A
</ol>
</ol>
</foreword></preface>
</mpfd-standard>
    INPUT

    output = xmlpp(<<~"OUTPUT")
    #{HTML_HDR}
          <div>
        <h1/>
        <ol type="i">
<li><ol type="1">
<li>A
</li>
</ol>
</li></ol>
      </div>
      <p class="zzSTDTitle1"/>
    </div>
  </body>
    OUTPUT

    expect(xmlpp(
      IsoDoc::MPFA::HtmlConvert.new({}).
      convert("test", input, true).
      gsub(%r{^.*<body}m, "<body").
      gsub(%r{</body>.*}m, "</body>")
    )).to be_equivalent_to output
  end



end
