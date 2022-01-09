require "spec_helper"
require "fileutils"

RSpec.describe Metanorma::MPFA do
  context "when xref_error.adoc compilation" do
    it "generates error file" do
      File.write("xref_error.adoc", <<~"CONTENT")
        = X
        A

        == Clause

        <<a,b>>
      CONTENT

      expect do
        Metanorma::Compile
          .new
          .compile("xref_error.adoc", type: "mpfa", no_install_fonts: true)
      end.to(change { File.exist?("xref_error.err") }
              .from(false).to(true))
    end
  end

  it "Warns of illegal doctype" do
    Asciidoctor.convert(<<~"INPUT", backend: :mpfa, header_footer: true)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :doctype: pizza

      text
    INPUT
    expect(File.read("test.err")).to include "pizza is not a recognised document type"
  end

  it "Warns of illegal status" do
    Asciidoctor.convert(<<~"INPUT", backend: :mpfa, header_footer: true)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :status: pizza

      text
    INPUT
    expect(File.read("test.err")).to include "pizza is not a recognised status"
  end
end
