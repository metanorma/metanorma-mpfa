require "spec_helper"
require "metanorma"

#RSpec.describe Asciidoctor::Gb do
RSpec.describe Metanorma::Rsd::Processor do

  registry = Metanorma::Registry.instance
  registry.register(Metanorma::Rsd::Processor)
  processor = registry.find_processor(:rsd)

  it "registers against metanorma" do
    expect(processor).not_to be nil
  end

  it "registers output formats against metanorma" do
    expect(processor.output_formats.sort.to_s).to be_equivalent_to <<~"OUTPUT"
    [[:doc, "doc"], [:html, "html"], [:pdf, "pdf"], [:xml, "xml"]]
    OUTPUT
  end

  it "registers version against metanorma" do
    expect(processor.version.to_s).to match(%r{^Asciidoctor::Rsd })
  end

  it "generates IsoDoc XML from a blank document" do
    expect(processor.input_to_isodoc(<<~"INPUT")).to be_equivalent_to <<~"OUTPUT"
    #{ASCIIDOC_BLANK_HDR}
    INPUT
    #{BLANK_HDR}
<sections/>
</rsd-standard>
    OUTPUT
  end

  it "generates HTML from IsoDoc XML" do
    system "rm -f test.xml"
    processor.output(<<~"INPUT", "test.html", :html)
               <rsd-standard xmlns="http://riboseinc.com/isoxml">
       <sections>
       <terms id="H" obligation="normative"><title>Terms, Definitions, Symbols and Abbreviated Terms</title>
         <term id="J">
         <preferred>Term2</preferred>
       </term>
        </terms>
        </sections>
        </rsd-standard>
    INPUT
    expect(File.read("test.html", encoding: "utf-8").gsub(%r{^.*<main}m, "<main").gsub(%r{</main>.*}m, "</main>")).to be_equivalent_to <<~"OUTPUT"
           <main class="main-section"><button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
             <p class="zzSTDTitle1"></p>
             <div id="H"><h1>1.&#xA0; Terms and definitions</h1><p>For the purposes of this document,
           the following terms and definitions apply.</p>
       <h2 class="TermNum" id="J">1.1&#xA0;<p class="Terms" style="text-align:left;">Term2</p></h2>

       </div>
           </main>
    OUTPUT
  end

end
