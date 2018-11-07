require "spec_helper"

RSpec.describe IsoDoc::Mpfd do

  it "processes pre" do
    input = <<~"INPUT"
<mpfd-standard xmlns="https://open.ribose.com/standards/rsd">
<preface><foreword>
<pre>ABC</pre>
</foreword></preface>
</mpfd-standard>
    INPUT

    output = <<~"OUTPUT"
    #{WORD_HDR}
    <div>
  <h1 class="ForewordTitle">Foreword</h1>
  <pre>ABC</pre>
  </div>
    #{WORD_FTR}
    OUTPUT

    expect(
      IsoDoc::Mpfd::WordConvert.new({}).
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
        #{WORD_HDR}
             <div>
              <h1 class="ForewordTitle">Foreword</h1>
               <span class="keyword">ABC</span>
             </div>
         #{WORD_FTR}
    OUTPUT

    expect(
      IsoDoc::Mpfd::WordConvert.new({}).
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
           <body lang="EN-US" link="blue" vlink="#954F72">
           <div class="WordSection1">
             <p>&#160;</p>
           </div>
           <br clear="all" class="section"/>
           <div class="WordSection2">
             <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
             <div>
               <h1 class="ForewordTitle">Foreword</h1>
               <p id="A">This is a preamble</p>
             </div>
             <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
             <div class="Section3" id="B">
               <h1 class="IntroTitle">Introduction</h1>
               <div id="C"><h2>Introduction Subsection</h2>
     
          </div>
             </div>
             <p>&#160;</p>
           </div>
           <br clear="all" class="section"/>
           <div class="WordSection3">
             <p class="zzSTDTitle1"/>
             <div id="M">
               <h1>3.<span style="mso-tab-count:1">&#160; </span>Clause 4</h1>
               <div id="N"><h2>3.1. Introduction</h2>
     
          </div>
               <div id="O"><h2>3.2. Clause 4.2</h2>
     
          </div>
             </div>
             <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
             <div id="P" class="Section3">
               <h1 class="Annex"><b>Annex A</b> <b>Annex</b></h1>
               <div id="Q"><h2>A.1. Annex A.1</h2>
     
            <div id="Q1"><h3>A.1.1. Annex A.1a</h3>
     
            </div>
          </div>
             </div>
             <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
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
      IsoDoc::Mpfd::WordConvert.new({}).convert("test", input, true).
      gsub(%r{^.*<body}m, "<body").
      gsub(%r{</body>.*}m, "</body>")
    ).to be_equivalent_to output
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
OUTPUT
    expect(
      IsoDoc::Mpfd::WordConvert.new({}).convert("test", input, true).
      gsub(%r{^.*<body}m, "<body").
      gsub(%r{</body>.*}m, "</body>")
    ).to be_equivalent_to output
  end

end
