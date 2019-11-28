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

    output = xmlpp(<<~"OUTPUT")
    #{WORD_HDR}
    <div>
  <h1 class="ForewordTitle">Foreword</h1>
  <pre>ABC</pre>
  </div>
    #{WORD_FTR}
    OUTPUT

    expect(xmlpp(
      IsoDoc::Mpfd::WordConvert.new({}).
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
        #{WORD_HDR}
             <div>
              <h1 class="ForewordTitle">Foreword</h1>
               <span class="keyword">ABC</span>
             </div>
         #{WORD_FTR}
    OUTPUT

    expect(xmlpp(
      IsoDoc::Mpfd::WordConvert.new({}).
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

    output = xmlpp(<<~"OUTPUT")
           <body lang="EN-US" link="blue" vlink="#954F72">
           <div class="WordSection1">
             <p>&#160;</p>
           </div>
           <p><br clear="all" class="section"/></p>
           <div class="WordSection2">
           <p><br clear="all" style="mso-special-character:line-break;page-break-before:always"/></p>
<div>
  <h1 class="AbstractTitle">Abstract</h1>
  <p id="AA">This is an abstract</p>
</div>
             <p><br clear="all" style="mso-special-character:line-break;page-break-before:always"/></p>
             <div>
               <h1 class="ForewordTitle">Foreword</h1>
               <p id="A">This is a preamble</p>
             </div>
             <p><br clear="all" style="mso-special-character:line-break;page-break-before:always"/></p>
             <div class="Section3" id="B">
               <h1 class="IntroTitle">Introduction</h1>
               <div id="C"><h2>Introduction Subsection</h2>

        </div>
             </div>
             <div id="H">
               <h1>Terms, Definitions, Symbols and Abbreviated Terms</h1>
               <div id="I"><h2>Normal Terms</h2>


          <p class="Terms" style="text-align:left;">Term2</p>

        </div>
               <div id="K"><h2>Symbols and abbreviated terms</h2>
          <table class="dl"><tr><td valign="top" align="left"><p align="left" style="margin-left:0pt;text-align:left;">Symbol</p></td><td valign="top">Definition</td></tr></table>
        </div>
             </div>
             <p>&#160;</p>
           </div>
           <p><br clear="all" class="section"/></p>
           <div class="WordSection3">
             <p class="zzSTDTitle1"/>
             <div id="M">
               <h1>2.<span style="mso-tab-count:1">&#160; </span>Clause 4</h1>
               <div id="N"><h2>2.1. Introduction</h2>

        </div>
               <div id="O"><h2>2.2. Clause 4.2</h2>

        </div>
             </div>
             <p><br clear="all" style="mso-special-character:line-break;page-break-before:always"/></p>
             <div id="P" class="Section3">
               <h1 class="Annex"><b>Appendix A</b> <b>Annex</b></h1>
               <div id="Q"><h2>A.1. Annex A.1</h2>

          <div id="Q1"><h3>A.1.1. Annex A.1a</h3>

          </div>
        </div>
             </div>
             <p><br clear="all" style="mso-special-character:line-break;page-break-before:always"/></p>
             <div>
               <h1 class="Section3">Bibliography</h1>
               <div>
                 <h2 class="Section3">Bibliography Subsection</h2>
               </div>
             </div>
           </div>
         </body>
    OUTPUT

    expect(xmlpp(
      IsoDoc::Mpfd::WordConvert.new({}).convert("test", input, true).
      gsub(%r{^.*<body}m, "<body").
      gsub(%r{</body>.*}m, "</body>")
    )).to be_equivalent_to output
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

    output = xmlpp(<<~"OUTPUT")
    <body lang="EN-US" link="blue" vlink="#954F72">
    <div class="WordSection1">
      <p>&#160;</p>
    </div>
    <p><br clear="all" class="section"/></p>
    <div class="WordSection2">
      <p><br clear="all" style="mso-special-character:line-break;page-break-before:always"/></p>
      <div>
        <h1 class="ForewordTitle">&#21069;&#35328;</h1>
        <p id="A">This is a preamble</p>
      </div>
      <p><br clear="all" style="mso-special-character:line-break;page-break-before:always"/></p>
      <div class="Section3" id="B">
        <h1 class="IntroTitle">&#24341;&#35328;</h1>
        <div id="C"><h2>Introduction Subsection</h2>

 </div>
      </div>
      <div id="H">
        <h1>Terms, Definitions, Symbols and Abbreviated Terms</h1>
        <div id="I"><h2>Normal Terms</h2>


   <p class="Terms" style="text-align:left;">Term2</p>

 </div>
        <div id="K"><h2>&#31526;&#21495;&#12289;&#20195;&#21495;&#21644;&#32553;&#30053;&#35821;</h2>
   <table class="dl"><tr><td valign="top" align="left"><p align="left" style="margin-left:0pt;text-align:left;">Symbol</p></td><td valign="top">Definition</td></tr></table>
 </div>
      </div>
      <p>&#160;</p>
    </div>
    <p><br clear="all" class="section"/></p>
    <div class="WordSection3">
      <p class="zzSTDTitle1"/>
      <div id="M">
        <h1>2.<span style="mso-tab-count:1">&#160; </span>Clause 4</h1>
        <div id="N"><h2>2.1. Introduction</h2>

 </div>
        <div id="O"><h2>2.2. Clause 4.2</h2>

 </div>
      </div>
      <p><br clear="all" style="mso-special-character:line-break;page-break-before:always"/></p>
      <div id="P" class="Section3">
        <h1 class="Annex">&#38468;&#24405;A <b>Annex</b></h1>
        <div id="Q"><h2>A.1. Annex A.1</h2>

   <div id="Q1"><h3>A.1.1. Annex A.1a</h3>

   </div>
 </div>
      </div>
      <p><br clear="all" style="mso-special-character:line-break;page-break-before:always"/></p>
      <div>
        <h1 class="Section3">&#21442;&#32771;&#25991;&#29486;</h1>
        <div>
          <h2 class="Section3">Bibliography Subsection</h2>
        </div>
      </div>
    </div>
  </body>
OUTPUT
    expect(xmlpp(
      IsoDoc::Mpfd::WordConvert.new({}).convert("test", input, true).
      gsub(%r{^.*<body}m, "<body").
      gsub(%r{</body>.*}m, "</body>")
    )).to be_equivalent_to output
  end

    it "processes containers" do
      expect(xmlpp(IsoDoc::Mpfd::WordConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
                <body lang="EN-US" link="blue" vlink="#954F72">
           <div class="WordSection1">
             <p>&#160;</p>
           </div>
           <p><br clear="all" class="section"/></p>
           <div class="WordSection2">
             <p>&#160;</p>
           </div>
           <p><br clear="all" class="section"/></p>
           <div class="WordSection3">
             <p class="zzSTDTitle1"/>
             <div id="A">
               <h1>1.<span style="mso-tab-count:1">&#160; </span>A</h1>
               <p>
               <a href="#A">Paragraph 1</a>
               <a href="#B">B</a>
               <a href="#C">Paragraph 2</a>
               <a href="#D">Paragraph 2.1</a>
               <a href="#E">E</a>
               <a href="#F">Paragraph 3</a>
               <a href="#G">Paragraph 4</a>
               <a href="#AA">Appendix A.1</a>
               <a href="#AB">B</a>
               <a href="#AC">Appendix A.1.1</a>
               <a href="#AD">Appendix A.1.1.1</a>
               <a href="#AE">E</a>
               <a href="#AF">Appendix A.1.1.1</a>
               <a href="#AG">Appendix A.1.1.2</a>
               </p>
             </div>
             <div id="B">
               <h1 class="containerhdr">B</h1>
               <div id="C"><span class="zzMoveToFollowing"><b>2.<span style="mso-tab-count:1">&#160; </span>C </b></span>
     
                   <div id="D"><span class="zzMoveToFollowing"><b>2.1.<span style="mso-tab-count:1">&#160; </span>D </b></span>
     
                   </div>
               </div>
               <div id="E"><h2 class="containerhdr">E</h2>
     
                   <div id="F"><h2>3. F</h2>
     
                   </div>
                   <div id="G"><h2>4. G</h2>
     
                   </div>
               </div>
             </div>
             <p><br clear="all" style="mso-special-character:line-break;page-break-before:always"/></p>
             <div id="A0" class="Section3">
               <h1 class="Annex"><b>Appendix A</b> <b>Annex</b></h1>
               <div id="AA"><h2>A.1. A</h2>
     
           </div>
               <div id="AB"><h1 class="containerhdr">B</h1>
     
               <div id="AC"><h3>A.1.1. C</h3>
     
                   <div id="AD"><h4>A.1.1.1. D</h4>
     
                   </div>
               </div>
               <div id="AE"><h2 class="containerhdr">E</h2>
     
                   <div id="AF"><h4>A.1.1.1. F</h4>
     
                   </div>
                   <div id="AG"><h4>A.1.1.2. G</h4>
     
                   </div>
               </div>
           </div>
             </div>
           </div>
         </body>
OUTPUT

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
    #{WORD_HDR}
          <div>
        <h1 class="ForewordTitle">Foreword</h1>
        <ol type="i">
<li><ol type="1">
<li>A
</li>
</ol>
</li></ol>
      </div>
  #{WORD_FTR}
    OUTPUT

    expect(xmlpp(
      IsoDoc::Mpfd::WordConvert.new({}).
      convert("test", input, true).
      gsub(%r{^.*<body}m, "<body").
      gsub(%r{</body>.*}m, "</body>")
    )).to be_equivalent_to output
  end



end
