require "spec_helper"

RSpec.describe IsoDoc::Mpfd do

  it "processes default metadata" do
    csdc = IsoDoc::Mpfd::HtmlConvert.new({})
    input = <<~"INPUT"
<mpfd-standard xmlns="https://open.ribose.com/standards/rsd">
<bibdata type="standard">
  <title language="en" format="plain">Main Title</title>
  <docidentifier>1000</docidentifier>
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
  <status format="plain">published</status>
  <copyright>
    <from>2001</from>
    <owner>
      <organization>
        <name>Ribose</name>
      </organization>
    </owner>
  </copyright>
  <editorialgroup>
    <committee type="A">TC</committee>
  </editorialgroup>
  <security>Client Confidential</security>
</bibdata><version>
  <edition>2</edition>
  <revision-date>2000-01-01</revision-date>
  <draft>3.4</draft>
</version>
<sections/>
</mpfd-standard>
    INPUT

    output = <<~"OUTPUT"
        {:accesseddate=>"XXX", :confirmeddate=>"XXX", :createddate=>"XXX", :docnumber=>"1000", :doctitle=>"Main Title", :doctype=>"Standard", :docyear=>"2001", :draft=>"3.4", :draftinfo=>" (draft 3.4, 2000-01-01)", :edition=>"Second", :editorialgroup=>[], :implementeddate=>"XXX", :issueddate=>"XXX", :obsoleteddate=>"XXX", :obsoletes=>nil, :obsoletes_part=>nil, :publisheddate=>"XXX", :publisher=>"Ribose", :revdate=>"2000-01-01", :revdate_monthyear=>"1 January 2000", :sc=>"XXXX", :secretariat=>"XXXX", :status=>"Published", :tc=>"XXXX", :updateddate=>"XXX", :wg=>"XXXX"}
    OUTPUT

    docxml, filename, dir = csdc.convert_init(input, "test", true)
    expect(htmlencode(Hash[csdc.info(docxml, nil).sort].to_s)).to be_equivalent_to output
  end

  it "processes committee-draft" do
    csdc = IsoDoc::Mpfd::HtmlConvert.new({})
    input = <<~"INPUT"
<mpfd-standard xmlns="https://open.ribose.com/standards/rsd">
<bibdata type="standard">
  <title language="en" format="plain">Main Title</title>
  <docidentifier>1000</docidentifier>
  <status format="plain">committee-draft</status>
</bibdata>
<sections/>
</mpfd-standard>
    INPUT

    output = <<~"OUTPUT"
        {:accesseddate=>"XXX", :confirmeddate=>"XXX", :createddate=>"XXX", :docnumber=>"1000(cd)", :doctitle=>"Main Title", :doctype=>"Standard", :docyear=>nil, :draft=>nil, :draftinfo=>"", :editorialgroup=>[], :implementeddate=>"XXX", :issueddate=>"XXX", :obsoleteddate=>"XXX", :obsoletes=>nil, :obsoletes_part=>nil, :publisheddate=>"XXX", :revdate=>nil, :revdate_monthyear=>nil, :sc=>"XXXX", :secretariat=>"XXXX", :status=>"Committee Draft", :tc=>"XXXX", :updateddate=>"XXX", :wg=>"XXXX"}
    OUTPUT

    docxml, filename, dir = csdc.convert_init(input, "test", true)
    expect(htmlencode(Hash[csdc.info(docxml, nil).sort].to_s)).to be_equivalent_to output

  end

  it "processes draft-standard" do
    csdc = IsoDoc::Mpfd::HtmlConvert.new({})
    input = <<~"INPUT"
<mpfd-standard xmlns="https://open.ribose.com/standards/rsd">
<bibdata type="standard">
  <title language="en" format="plain">Main Title</title>
  <docidentifier>1000</docidentifier>
  <status format="plain">draft-standard</status>
</bibdata>
<sections/>
</mpfd-standard>
    INPUT

    output = <<~"OUTPUT"
        {:accesseddate=>"XXX", :confirmeddate=>"XXX", :createddate=>"XXX", :docnumber=>"1000(d)", :doctitle=>"Main Title", :doctype=>"Standard", :docyear=>nil, :draft=>nil, :draftinfo=>"", :editorialgroup=>[], :implementeddate=>"XXX", :issueddate=>"XXX", :obsoleteddate=>"XXX", :obsoletes=>nil, :obsoletes_part=>nil, :publisheddate=>"XXX", :revdate=>nil, :revdate_monthyear=>nil, :sc=>"XXXX", :secretariat=>"XXXX", :status=>"Draft Standard", :tc=>"XXXX", :updateddate=>"XXX", :wg=>"XXXX"}
    OUTPUT

    docxml, filename, dir = csdc.convert_init(input, "test", true)
    expect(htmlencode(Hash[csdc.info(docxml, nil).sort].to_s)).to be_equivalent_to output

  end

  it "processes working-draft" do
    csdc = IsoDoc::Mpfd::HtmlConvert.new({})
    input = <<~"INPUT"
<mpfd-standard xmlns="https://open.ribose.com/standards/rsd">
<bibdata type="standard">
  <title language="en" format="plain">Main Title</title>
  <docidentifier>1000</docidentifier>
  <status format="plain">working-draft</status>
</bibdata>
<sections/>
</mpfd-standard>
    INPUT

    output = <<~"OUTPUT"
    {:accesseddate=>"XXX", :confirmeddate=>"XXX", :createddate=>"XXX", :docnumber=>"1000(wd)", :doctitle=>"Main Title", :doctype=>"Standard", :docyear=>nil, :draft=>nil, :draftinfo=>"", :editorialgroup=>[], :implementeddate=>"XXX", :issueddate=>"XXX", :obsoleteddate=>"XXX", :obsoletes=>nil, :obsoletes_part=>nil, :publisheddate=>"XXX", :revdate=>nil, :revdate_monthyear=>nil, :sc=>"XXXX", :secretariat=>"XXXX", :status=>"Working Draft", :tc=>"XXXX", :updateddate=>"XXX", :wg=>"XXXX"}
    OUTPUT

    docxml, filename, dir = csdc.convert_init(input, "test", true)
    expect(htmlencode(Hash[csdc.info(docxml, nil).sort].to_s)).to be_equivalent_to output

  end


  it "processes pre" do
    input = <<~"INPUT"
<mpfd-standard xmlns="https://open.ribose.com/standards/rsd">
<preface><foreword>
<pre>ABC</pre>
</foreword></preface>
</mpfd-standard>
    INPUT

    output = <<~"OUTPUT"
    #{HTML_HDR}
             <div>
               <h1/>
               <pre>ABC</pre>
             </div>
             <p class="zzSTDTitle1"/>
           </div>
         </body>
    OUTPUT

    expect(
      IsoDoc::Mpfd::HtmlConvert.new({}).
      convert("test", input, true).
      gsub(%r{^.*<body}m, "<body").
      gsub(%r{</body>.*}m, "</body>")
    ).to be_equivalent_to output
  end

  it "processes keyword" do
    input = <<~"INPUT"
<mpfd-standard xmlns="https://open.ribose.com/standards/rsd">
<preface><foreword>
<keyword>ABC</keyword>
</foreword></preface>
</mpfd-standard>
    INPUT

    output = <<~"OUTPUT"
    #{HTML_HDR}
             <div>
               <h1/>
               <span class="keyword">ABC</span>
             </div>
             <p class="zzSTDTitle1"/>
           </div>
         </body>
    OUTPUT

    expect(
      IsoDoc::Mpfd::HtmlConvert.new({}).
      convert("test", input, true).
      gsub(%r{^.*<body}m, "<body").
      gsub(%r{</body>.*}m, "</body>")
    ).to be_equivalent_to output
  end

  it "processes section names" do
    input = <<~"INPUT"
    <mpfd-standard xmlns="http://riboseinc.com/isoxml">
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
        </preface><sections>
       <clause id="D" obligation="normative">
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
       </annex><bibliography><references id="R" obligation="informative">
         <title>Normative References</title>
       </references><clause id="S" obligation="informative">
         <title>Bibliography</title>
         <references id="T" obligation="informative">
         <title>Bibliography Subsection</title>
       </references>
       </clause>
       </bibliography>
       </mpfd-standard>
    INPUT

    output = <<~"OUTPUT"
    #{HTML_HDR}
        <div>
               <h1>Foreword</h1>
               <p id="A">This is a preamble</p>
             </div>
             <div id="B">
               <h1>Introduction</h1>
               <div id="C"><h2>Introduction Subsection</h2>

          </div>
             </div>
             <div id="H">
               <h1>Terms, Definitions, Symbols and Abbreviated Terms</h1>
               <div id="I"><h2>Normal Terms</h2>


            <p class="Terms" style="text-align:left;">Term2</p>

          </div>
               <div id="K"><h2>Symbols and abbreviated terms</h2>
            <dl><dt><p>Symbol</p></dt><dd>Definition</dd></dl>
          </div>
             </div>
             <div>
               <h1/>
               <div id="D"><h1>1. Scope</h1>

            <p id="E">Text</p>
          </div>
               <div id="L"><h2>Symbols and abbreviated terms</h2>
            <dl><dt><p>Symbol</p></dt><dd>Definition</dd></dl>
          </div>
               <div id="M"><h1>2. Clause 4</h1><div id="N"><h2>2.1. Introduction</h2>

          </div>
          <div id="O"><h2>2.2. Clause 4.2</h2>

          </div></div>
             </div>
             <div id="P">
               <h1><b>Appendix A</b>.&#160; Annex</h1>
               <div id="Q"><h2>A.1. Annex A.1</h2>

            <div id="Q1"><h3>A.1.1. Annex A.1a</h3>

            </div>
          </div>
             </div>
             <div>
               <h1/>
               <div>
                 <h2 class="Section3">Normative References</h2>
               </div>
               <div id="S"><h2>Bibliography</h2>

            <div><h2 class="Section3">Bibliography Subsection</h2></div>
          </div>
             </div>
             <p class="zzSTDTitle1"/>
             <div id="M">
               <h1>2.&#160; Clause 4</h1>
               <div id="N"><h2>2.1. Introduction</h2>

          </div>
               <div id="O"><h2>2.2. Clause 4.2</h2>

          </div>
             </div>
             <br/>
             <div id="P" class="Section3">
               <h1 class="Annex"><b>Appendix A</b> <b>Annex</b></h1>
               <div id="Q"><h2>A.1. Annex A.1</h2>

            <div id="Q1"><h3>A.1.1. Annex A.1a</h3>

            </div>
          </div>
             </div>
             <br/>
             <div>
               <h1 class="Section3">Bibliography</h1>
               <div>
                 <h2 class="Section3">Bibliography Subsection</h2>
               </div>
             </div>
           </div>
         </body>
    OUTPUT

    expect(
      IsoDoc::Mpfd::HtmlConvert.new({}).convert("test", input, true).
      gsub(%r{^.*<body}m, "<body").
      gsub(%r{</body>.*}m, "</body>")
    ).to be_equivalent_to output
  end

  it "injects JS into blank html" do
    system "rm -f test.html"
    input = <<~"INPUT"
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
    INPUT

    output = <<~"OUTPUT"
    #{BLANK_HDR}
<sections/>
</mpfd-standard>
    OUTPUT

    expect(Asciidoctor.convert(input, backend: :mpfd, header_footer: true)).to be_equivalent_to output
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
        </preface><sections>
       <clause id="D" obligation="normative">
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
       </annex><bibliography><references id="R" obligation="informative">
         <title>Normative References</title>
       </references><clause id="S" obligation="informative">
         <title>Bibliography</title>
         <references id="T" obligation="informative">
         <title>Bibliography Subsection</title>
       </references>
       </clause>
       </bibliography>
       </mpfd-standard>
    INPUT

    output = <<~"OUTPUT"
    #{HTML_HDR}
      <div>
        <h1>Foreword</h1>
        <p id="A">This is a preamble</p>
      </div>
      <div id="B">
        <h1>Introduction</h1>
        <div id="C"><h2>Introduction Subsection</h2>
   </div>
      </div>
      <div id="H">
        <h1>Terms, Definitions, Symbols and Abbreviated Terms</h1>
        <div id="I"><h2>Normal Terms</h2>
     <p class="Terms" style="text-align:left;">Term2</p>
   </div>
        <div id="K"><h2>&#31526;&#21495;&#12289;&#20195;&#21495;&#21644;&#32553;&#30053;&#35821;</h2>
     <dl><dt><p>Symbol</p></dt><dd>Definition</dd></dl>
   </div>
      </div>
      <div>
        <h1/>
        <div id="D"><h1>1. Scope</h1>
     <p id="E">Text</p>
   </div>
        <div id="L"><h2>&#31526;&#21495;&#12289;&#20195;&#21495;&#21644;&#32553;&#30053;&#35821;</h2>
     <dl><dt><p>Symbol</p></dt><dd>Definition</dd></dl>
   </div>
        <div id="M"><h1>2. Clause 4</h1><div id="N"><h2>2.1. Introduction</h2>
   </div>
   <div id="O"><h2>2.2. Clause 4.2</h2>
   </div></div>
      </div>
      <div id="P">
        <h1>&#38468;&#24405;A.&#160; Annex</h1>
        <div id="Q"><h2>A.1. Annex A.1</h2>
     <div id="Q1"><h3>A.1.1. Annex A.1a</h3>
     </div>
   </div>
      </div>
      <div>
        <h1/>
        <div>
          <h2 class="Section3">Normative References</h2>
        </div>
        <div id="S"><h2>Bibliography</h2>
     <div><h2 class="Section3">Bibliography Subsection</h2></div>
   </div>
      </div>
      <p class="zzSTDTitle1"/>
      <div id="M">
        <h1>2.&#160; Clause 4</h1>
        <div id="N"><h2>2.1. Introduction</h2>
   </div>
        <div id="O"><h2>2.2. Clause 4.2</h2>
   </div>
      </div>
      <br/>
      <div id="P" class="Section3">
        <h1 class="Annex">&#38468;&#24405;A <b>Annex</b></h1>
        <div id="Q"><h2>A.1. Annex A.1</h2>
     <div id="Q1"><h3>A.1.1. Annex A.1a</h3>
     </div>
   </div>
      </div>
      <br/>
      <div>
        <h1 class="Section3">&#21442;&#32771;&#25991;&#29486;</h1>
        <div>
          <h2 class="Section3">Bibliography Subsection</h2>
        </div>
      </div>
    </div>
  </body>
    OUTPUT

    expect(
      IsoDoc::Mpfd::HtmlConvert.new({}).convert("test", input, true).
      gsub(%r{^.*<body}m, "<body").
      gsub(%r{</body>.*}m, "</body>")
    ).to be_equivalent_to output

  end

    it "processes containers" do
    end

end
