module Asciidoctor
  module Standoc
    module Cleanup
      def external_terms_boilerplate(sources)
        @i18n.l10n(
          @i18n.external_terms_boilerplate.gsub(/%/, sources || "???"),
          @lang, @script)
      end

      def internal_external_terms_boilerplate(sources)
        @i18n.l10n(
          @i18n.internal_external_terms_boilerplate.gsub(/%/, sources || "??"),
          @lang, @script)
      end

      def term_defs_boilerplate(div, source, term, preface, isodoc)
        a = @i18n.term_def_boilerplate and div.next = a
        source.each do |s|
          @anchors[s["bibitemid"]] or
            @log.add("Crossreferences", nil, "term source #{s['bibitemid']} not referenced")
        end
        if source.empty? && term.nil?
          div.next = @i18n.no_terms_boilerplate
        else
          div.next = term_defs_boilerplate_cont(source, term, isodoc)
        end
      end

      def term_defs_boilerplate_cont(src, term, isodoc)
        sources = isodoc.sentence_join(src.map do |s|
          %{<eref bibitemid="#{s['bibitemid']}"/>}
        end)
        if src.empty? then @i18n.internal_terms_boilerplate
        elsif term.nil? then external_terms_boilerplate(sources)
        else
          internal_external_terms_boilerplate(sources)
        end
      end

      def norm_ref_preface(f)
      refs = f.elements.select do |e|
        ["reference", "bibitem"].include? e.name
      end
      f.at("./title").next =
        "<p>#{(refs.empty? ? @i18n.norm_empty_pref : @i18n.norm_with_refs_pref)}</p>"
    end

      TERM_CLAUSE = "//sections/terms | "\
        "//sections/clause[descendant::terms]".freeze

      NORM_REF = "//bibliography/references[@normative = 'true']".freeze

      def boilerplate_isodoc(xmldoc)
        x = xmldoc.dup
        x.root.add_namespace(nil, self.class::XML_NAMESPACE)
        xml = Nokogiri::XML(x.to_xml)
        @isodoc ||= isodoc(@lang, @script)
        @isodoc.info(xml, nil)
        @isodoc
      end

      def boilerplate_cleanup(xmldoc)
        isodoc = boilerplate_isodoc(xmldoc)
        xmldoc.xpath(self.class::TERM_CLAUSE).each do |f|
          term_defs_boilerplate(f.at("./title"),
                                xmldoc.xpath(".//termdocsource"),
                                f.at(".//term"), f.at(".//p"), isodoc)
        end
        f = xmldoc.at(self.class::NORM_REF) and
          norm_ref_preface(f)
        initial_boilerplate(xmldoc, isodoc)
      end

      def initial_boilerplate(x, isodoc)
        return if x.at("//boilerplate")
        preface = x.at("//preface") || x.at("//sections") || x.at("//annex") ||
          x.at("//references") || return
        b = boilerplate(x, isodoc) or return
        preface.previous = b
      end

      def boilerplate_file(xmldoc)
        File.join(@libdir, "boilerplate.xml")
      end

      def boilerplate(xml, conv)
        file = boilerplate_file(xml)
        file = File.join(@localdir, @boilerplateauthority) if @boilerplateauthority
        !file.nil? and File.exists?(file) or return
        conv.populate_template((File.read(file, encoding: "UTF-8")), nil)
      end

      def bibdata_cleanup(xmldoc)
        bibdata_anchor_cleanup(xmldoc)
        bibdata_docidentifier_cleanup(xmldoc)
      end

      def bibdata_anchor_cleanup(xmldoc)
        xmldoc.xpath("//bibdata//bibitem | //bibdata//note").each do |b|
          b.delete("id")
        end
      end

      def bibdata_docidentifier_cleanup(xmldoc)
        ins = xmldoc.at("//bibdata/docidentifier")
        xmldoc.xpath("//bibdata/docidentifier").each_with_index do |b, i|
          next if i == 0
          ins.next = b.remove
          ins = ins.next
        end
      end
    end
  end
end
