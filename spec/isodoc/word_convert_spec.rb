require "spec_helper"

RSpec.describe IsoDoc::MPFA do
  it "processes pre" do
    input = <<~"INPUT"
      <mpfd-standard xmlns="https://open.ribose.com/standards/rsd">
        <preface>
          <foreword>
            <pre>ABC</pre>
          </foreword>
        </preface>
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

    expect(xmlpp(IsoDoc::MPFA::WordConvert.new({})
      .convert("test", input, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to output
  end

  it "processes keyword" do
    input = <<~"INPUT"
      <mpfd-standard xmlns="https://open.ribose.com/standards/rsd">
        <preface>
          <foreword>
            <keyword>ABC</keyword>
          </foreword>
        </preface>
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

    expect(xmlpp(IsoDoc::MPFA::WordConvert.new({})
      .convert("test", input, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to output
  end

  it "processes ordered list style" do
    input = <<~"INPUT"
      <mpfd-standard xmlns="https://open.ribose.com/standards/rsd">
        <preface>
          <foreword>
          <ol type="roman">
            <li>
            <ol type="arabic">
              <li>A
            </ol>
          </ol>
          </foreword>
        </preface>
      </mpfd-standard>
    INPUT

    output = xmlpp(<<~"OUTPUT")
      #{WORD_HDR}
      <div>
        <h1 class="ForewordTitle">Foreword</h1>
        <ol type="i">
          <li>
            <ol type="1">
              <li>A</li>
            </ol>
          </li>
        </ol>
      </div>
      #{WORD_FTR}
    OUTPUT

    expect(xmlpp(IsoDoc::MPFA::WordConvert.new({})
      .convert("test", input, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to output
  end
end
