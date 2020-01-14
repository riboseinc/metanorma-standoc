require "date"
require "nokogiri"
require "htmlentities"
require "pathname"
require "open-uri"

module Asciidoctor
  module Standoc
    module Front
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
        (node.attr("publisher") || "").split(/,[ ]?/).each do |p|
          xml.contributor do |c|
            c.role **{ type: "author" }
            c.organization { |a| organization(a, p) }
          end
        end
        personal_author(node, xml)
      end

      def personal_author(node, xml)
        (node.attr("fullname") || node.attr("surname")) and
          personal_author1(node, xml, "")
        i = 2
        while node.attr("fullname_#{i}") || node.attr("surname_#{i}")
          personal_author1(node, xml, "_#{i}")
          i += 1
        end
      end

      def personal_author1(node, xml, suffix)
        xml.contributor do |c|
          c.role **{ type: node.attr("role#{suffix}")&.downcase || "author" }
          c.person do |p|
            person_name(node, xml, suffix, p)
            person_affiliation(node, xml, suffix, p)
            node.attr("phone#{suffix}") and p.phone node.attr("phone#{suffix}")
            node.attr("fax#{suffix}") and
              p.phone node.attr("fax#{suffix}"), **{type: "fax"}
            node.attr("email#{suffix}") and p.email node.attr("email#{suffix}")
            node.attr("contributor-uri#{suffix}") and
              p.uri node.attr("contributor-uri#{suffix}")
          end
        end
      end

      def person_name(node, xml, suffix, p)
        p.name do |n|
          if node.attr("fullname#{suffix}")
            n.completename node.attr("fullname#{suffix}")
          else
            n.forename node.attr("givenname#{suffix}")
            n.initial node.attr("initials#{suffix}")
            n.surname node.attr("surname#{suffix}")
          end
        end
      end

      def person_affiliation(node, xml, suffix, p)
        node.attr("affiliation#{suffix}") and p.affiliation do |a|
          a.organization do |o|
            o.name node.attr("affiliation#{suffix}")
            abbr = node.attr("affiliation_abbrev#{suffix}") and
              o.abbreviation abbr
            node.attr("address#{suffix}") and o.address do |ad|
              ad.formattedAddress node.attr("address#{suffix}")
            end
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
    end
  end
end
