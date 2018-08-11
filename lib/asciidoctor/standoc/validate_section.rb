require "nokogiri"

module Asciidoctor
  module Standoc
    module Validate
      def section_validate(doc)
        sourcecode_style(doc.root)
        asset_style(doc.root)
      end

      def sourcecode_style(root)
        root.xpath("//sourcecode").each do |x|
          callouts = x.elements.select { |e| e.name == "callout" }
          annotations = x.elements.select { |e| e.name == "annotation" }
          if callouts.size != annotations.size
            warn "#{x['id']}: mismatch of callouts and annotations"
          end
        end
      end

      ASSETS_TO_STYLE =
        "//termsource | //formula | //termnote | //p | //li[not(p)] | "\
        "//dt | //dd[not(p)] | //td[not(p)] | //th[not(p)]".freeze

      NORM_BIBITEMS =
        "//references[title = 'Normative References']/bibitem".freeze

      def asset_title_style(root)
        root.xpath("//figure[image][not(title)]").each do |node|
          style_warning(node, "Figure should have title", nil)
        end
        root.xpath("//table[not(title)]").each do |node|
          style_warning(node, "Table should have title", nil)
        end
      end
    end
  end
end