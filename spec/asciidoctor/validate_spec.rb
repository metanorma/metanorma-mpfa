require "spec_helper"
require "fileutils"

RSpec.describe Asciidoctor::Mpfd do
      it "Warns of illegal doctype" do
    expect { Asciidoctor.convert(<<~"INPUT", backend: :mpfd, header_footer: true) }.to output(/pizza is not a recognised document type/).to_stderr
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :no-isobib:
  :doctype: pizza

  text
  INPUT
end

      it "Warns of illegal status" do
    expect { Asciidoctor.convert(<<~"INPUT", backend: :mpfd, header_footer: true) }.to output(/pizza is not a recognised status/).to_stderr
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :no-isobib:
  :status: pizza

  text
  INPUT
end

end
