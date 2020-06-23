require "spec_helper"
require "metanorma"
require "fileutils"

RSpec.describe Metanorma::Mpfd::Processor do

  registry = Metanorma::Registry.instance
  registry.register(Metanorma::Mpfd::Processor)

  let(:processor) {
    registry.find_processor(:mpfd)
  }

  it "registers against metanorma" do
    expect(processor).not_to be nil
  end

  it "registers output formats against metanorma" do
    expect(processor.output_formats.sort.to_s).to be_equivalent_to <<~"OUTPUT"
    [[:doc, "doc"], [:html, "html"], [:presentation, "presentation.xml"], [:rxl, "rxl"], [:xml, "xml"]]
    OUTPUT
  end

  it "registers version against metanorma" do
    expect(processor.version.to_s).to match(%r{^Metanorma::Mpfd })
  end

  it "generates IsoDoc XML from a blank document" do
    input = <<~"INPUT"
    #{ASCIIDOC_BLANK_HDR}
    INPUT

    output = <<~"OUTPUT"
    #{BLANK_HDR}
<sections/>
</mpfd-standard>
    OUTPUT

    expect(xmlpp(processor.input_to_isodoc(input, nil))).to be_equivalent_to xmlpp(output)
  end

  it "generates XML from IsoDoc XML" do
    FileUtils.rm_f "test.xml"
    input = <<~"INPUT"
    <mpfd-standard xmlns="http://riboseinc.com/isoxml">
      <sections>
        <clause id="H" obligation="normative"><title>Clause</title>
          <p>Text</p>
        </clause>
      </sections>
    </mpfd-standard>
    INPUT

    processor.output(input, "test.xml", "test.xml", :xml)
    expect(File.exists?("test.xml")).to be true
  end

  it "generates HTML from IsoDoc XML" do
    FileUtils.rm_f "test.xml"
    FileUtils.rm_f "test.html"
    input = <<~"INPUT"
    <mpfd-standard xmlns="http://riboseinc.com/isoxml">
      <sections>
        <clause id="H" obligation="normative"><title>Clause</title>
          <p>Text</p>
        </clause>
      </sections>
    </mpfd-standard>
    INPUT

    output = <<~"OUTPUT"
    <main class="main-section"><button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
      <p class="zzSTDTitle1"></p>
      <div id="H">
        <h1 id="toc0">1.&#xA0; Clause</h1>
        <p>Text</p>
      </div>
    </main>
    OUTPUT

    processor.output(input, "test.xml", "test.html", :html)
    expect(File.exists?("test.html")).to be true
    expect(
      xmlpp(File.read("test.html", encoding: "utf-8").gsub(%r{^.*<main}m, "<main").gsub(%r{</main>.*}m, "</main>"))
    ).to be_equivalent_to xmlpp(output)

  end

  it "generates DOC from IsoDoc XML" do
    FileUtils.rm_f "test.xml"
    FileUtils.rm_f "test.doc"
    input = <<~"INPUT"
    <mpfd-standard xmlns="http://riboseinc.com/isoxml">
      <sections>
        <clause id="H" obligation="normative"><title>Clause</title>
          <p>Text</p>
        </clause>
      </sections>
    </mpfd-standard>
    INPUT

    output = <<~"OUTPUT"
    <div class="WordSection3">
  <p class="zzSTDTitle1"></p>
  <div><a name="H" id="H"></a>
    <h1>1.<span style="mso-tab-count:1">&#xA0; </span>Clause</h1>
    <p class="MsoNormal">Text</p>
  </div>
</div>
    OUTPUT

    processor.output(input, "test.xml", "test.doc", :doc)
   expect(File.exists?("test.doc")).to be true

   expect(
      xmlpp(File.read("test.doc", encoding: "utf-8").gsub(%r{^.*<div class="WordSection3"}m, %(<div class="WordSection3")).gsub(%r{<div style="mso-element:footnote-list".*}m, ""))
    ).to be_equivalent_to xmlpp(output)

  end
end
