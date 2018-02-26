require "spec_helper"

RSpec.describe Asciidoctor::ISO do
  it "processes the Asciidoctor::ISO macros" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :iso, header_footer: true)).to be_equivalent_to <<~"OUTPUT"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:

      alt:[term1]
      deprecated:[term1]
      domain:[term1]
    INPUT
            #{BLANK_HDR}
       <sections>
         <admitted>term1</admitted>
       <deprecates>term1</deprecates>
       <domain>term1</domain>
       </sections>
       </iso-standard>
    OUTPUT
  end
end
