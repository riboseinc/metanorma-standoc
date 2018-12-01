require "date"
require "nokogiri"
require "htmlentities"
require "json"
require "pathname"
require "open-uri"
require "pp"

module Asciidoctor
  module Standoc
    module Front
      def metadata_id(node, xml)
        part, subpart = node&.attr("partnumber")&.split(/-/)
        id = node.attr("docnumber") || ""
        id += "-#{part}" if part
        id += "-#{subpart}" if subpart
        xml.docidentifier id
        xml.docnumber node.attr("docnumber")
      end

      def metadata_version(node, xml)
        xml.version do |v|
          v.edition node.attr("edition") if node.attr("edition")
          v.revision_date node.attr("revdate") if node.attr("revdate")
          v.draft node.attr("draft") if node.attr("draft")
        end
      end

      def committee_component(compname, node, out)
        out.send compname.gsub(/-/, "_"), node.attr(compname),
          **attr_code(number: node.attr("#{compname}-number"),
                      type: node.attr("#{compname}-type"))
        i = 2
        while node.attr(compname+"_#{i}") do
          out.send compname.gsub(/-/, "_"), node.attr(compname+"_#{i}"),
            **attr_code(number: node.attr("#{compname}-number_#{i}"),
                        type: node.attr("#{compname}-type_#{i}"))
          i += 1
        end
      end

      def organization(org, orgname)
        org.name orgname
      end

      def metadata_author(node, xml)
        publishers = node.attr("publisher") || return
        publishers.split(/,[ ]?/).each do |p|
          xml.contributor do |c|
            c.role **{ type: "author" }
            c.organization { |a| organization(a, p) }
          end
        end
      end

      def metadata_publisher(node, xml)
        publishers = node.attr("publisher") || return
        publishers.split(/,[ ]?/).each do |p|
          xml.contributor do |c|
            c.role **{ type: "publisher" }
            c.organization { |a| organization(a, p) }
          end
        end
      end

      def metadata_copyright(node, xml)
        publishers = node.attr("publisher") || " "
        publishers.split(/,[ ]?/).each do |p|
          xml.copyright do |c|
            c.from (node.attr("copyright-year") || Date.today.year)
            p.match(/[A-Za-z]/).nil? or c.owner do |owner|
              owner.organization { |o| organization(o, p) }
            end
          end
        end
      end

      def metadata_status(node, xml)
        xml.status(**{ format: "plain" }) do |s|
          s << ( node.attr("status") || "published" )
        end
      end

      def metadata_committee(node, xml)
        xml.editorialgroup do |a|
          committee_component("technical-committee", node, a)
        end
      end

      def metadata_ics(node, xml)
        ics = node.attr("library-ics")
        ics && ics.split(/,\s*/).each do |i|
          xml.ics do |ics|
            ics.code i
          end
        end
      end

      def metadata_source(node, xml)
        node.attr("uri") && xml.source(node.attr("uri"))
        node.attr("xml-uri") && xml.source(node.attr("xml-uri"), type: "xml")
        node.attr("html-uri") && xml.source(node.attr("html-uri"), type: "html")
        node.attr("pdf-uri") && xml.source(node.attr("pdf-uri"), type: "pdf")
        node.attr("doc-uri") && xml.source(node.attr("doc-uri"), type: "doc")
        node.attr("relaton-uri") && xml.source(node.attr("relaton-uri"), type: "relaton")
      end

      def metadata_date1(node, xml, type)
        date = node.attr("#{type}-date")
        date and xml.date **{ type: type } do |d|
          d.on date
        end
      end

      DATETYPES = %w{ published accessed created implemented obsoleted
                      confirmed updated issued circulated unchanged received
      }.freeze

      def metadata_date(node, xml)
        DATETYPES.each { |t| metadata_date1(node, xml, t) }
        node.attributes.keys.each do |a|
          next unless a == "date" || /^date_\d+$/.match(a)
          type, date = node.attr(a).split(/ /, 2)
          type or next
          xml.date **{ type: type } do |d|
            d.on date
          end
        end
      end

      def metadata_language(node, xml)
        xml.language (node.attr("language") || "en")
      end

      def metadata_script(node, xml)
        xml.language (node.attr("script") || "Latn")
      end

      def metadata(node, xml)
        title node, xml
        metadata_source(node, xml)
        metadata_id(node, xml)
        metadata_date(node, xml)
        metadata_author(node, xml)
        metadata_publisher(node, xml)
        metadata_language(node, xml)
        metadata_script(node, xml)
        metadata_status(node, xml)
        metadata_copyright(node, xml)
        metadata_committee(node, xml)
        metadata_ics(node, xml)
      end

      def asciidoc_sub(x)
        return nil if x.nil?
        return "" if x.empty?
        d = Asciidoctor::Document.new(x.lines.entries, {header_footer: false})
        b = d.parse.blocks.first
        b.apply_subs(b.source)
      end

      def title(node, xml)
        ["en"].each do |lang|
          at = { language: lang, format: "text/plain" }
          xml.title **attr_code(at) do |t|
            t << asciidoc_sub(node.attr("title"))
          end
        end
      end
    end
  end
end
