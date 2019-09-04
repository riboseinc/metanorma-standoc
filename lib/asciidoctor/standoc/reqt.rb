require "htmlentities"
require "uri"
require "mime/types"
require "base64"

module Asciidoctor
  module Standoc
    module Blocks
      def requirement_subpart(node)
        name = node.role || node.attr("style")
        noko do |xml|
          xml.send name, **attr_code(exclude: node.option?("exclude"),
                                     type: node.attr("type")) do |o|
            o << node.content
          end
        end.join("\n")
      end

      def req_classif_parse(classif)
        ret = []
        classif.split(/;\s*/).each do |c|
          c1 = c.split(/:\s*/)
          next unless c1.size == 2
          c1[1].split(/,\s*/).each { |v| ret << [ c1[0], v ] }
        end
        ret
      end

      def requirement_classification(classif, ex)
        req_classif_parse(classif).each do |r|
          ex.classification do |c|
            c.tag r[0]
            c.value r[1]
          end
        end
      end

      def reqt_attributes(node)
        {
          id: Utils::anchor_or_uuid,
          unnumbered: node.option?("unnumbered") ? "true" : nil,
          obligation: node.attr("obligation"),
          filename: node.attr("filename")
        }
      end

      def requirement(node, obligation)
        classif = node.attr("classification")
        noko do |xml|
          xml.send obligation, **attr_code(reqt_attributes(node)) do |ex|
            ex.title node.title if node.title
            ex.label node.attr("label") if node.attr("label")
            ex.subject node.attr("subject") if node.attr("subject")
            ex.inherit node.attr("inherit") if node.attr("inherit")
            requirement_classification(classif, ex) if classif
            wrap_in_para(node, ex)
          end
        end.join("\n")
      end
    end
  end
end