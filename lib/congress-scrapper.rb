# coding: utf-8

require "congress-scrapper/version"
require "mechanize"
require "progressbar"
require_relative "proposer"

module Congress
  module Scrapper
    extend self

    def agent
      @agent ||= Mechanize.new
    end

    def scrape
      proposals = []
      legislations = {current_legislation: 'iw10', previous_legislation: 'iwi9'}
      legislations.each do |legislation_name, legislation_value|
        search_page = agent.get("http://www.congreso.es/portal/page/portal/Congreso/Congreso/Iniciativas/Busqueda%20Avanzada")
        search_form = search_page.form_with(:action => /enviarCgiBuscadorAvIniciativas/)
        search_form["TPTR"] = "Competencia Legislativa Plena"
        search_form["BASE"] = legislation_value
        results_page = search_form.submit

        total_results = results_page.search("//*[contains(text(), 'Iniciativas encontradas')]/span").first.text.to_i
        progress = ProgressBar.new("Scrapping #{legislation_name}", total_results)

        while results_page
          results_page.search(".titulo_iniciativa a").each do |title|
            @proposal_page = agent.get(title[:href])
          
            proposal_type = clean_text(text_for(".subtitulo_competencias"))

            status = clean_text(text_for("//*[@class='apartado_iniciativa' and contains(normalize-space(text()),'Resultado de la tramitación')]/following-sibling::*[@class='texto']")) ||
                     clean_text(text_for("//*[@class='apartado_iniciativa' and contains(normalize-space(text()),'Situación actual')]/following-sibling::*[@class='texto']"))

            commission_name = clean_text(text_for("//*[@class='apartado_iniciativa' and contains(normalize-space(text()),'Comisión competente:')]/following-sibling::*[@class='texto']"))

            proposer_name = clean_text(text_for("//*[@class='apartado_iniciativa' and contains(normalize-space(text()),'Autor:')]/following-sibling::*[@class='texto']"))

            proposed_at_text = text_for("//*[@class='texto' and contains(normalize-space(text()),'Presentado el')]")
            proposed_at = Date.new($3.to_i, $2.to_i, $1.to_i) if proposed_at_text && proposed_at_text.match(/Presentado\s+el\s+(\d\d)\/(\d\d)\/(\d\d\d\d)/)

            closed_at_text = text_for("//*[@class='apartado_iniciativa' and contains(normalize-space(text()),'Tramitación seguida por la iniciativa:')]/following-sibling::*[@class='texto']")
            closed_at = Date.new($3.to_i, $2.to_i, $1.to_i) if closed_at_text && closed_at_text.match(/Concluido\s+.+\s+desde (\d\d)\/(\d\d)\/(\d\d\d\d)/)
          
            body = full_proposal_text(@proposal_page)

            proposal = {:title               => clean_text(title.content),
                        :official_url        => "http://www.congreso.es" + title[:href],
                        :proposal_type       => proposal_type,
                        :closed_at           => closed_at,
                        :status              => status,
                        :category_name       => category(commission_name),
                        :proposer_name       => proposer(proposer_name),
                        :proposed_at         => proposed_at,
                        :body                => body}
 
            progress.inc
          
            proposals << proposal
          end
        
          next_page =  results_page.link_with(:text => /Siguiente/)
          results_page = next_page.nil? ? nil : next_page.click
        end
  
        progress.finish
      end
      
      proposals
    end

    private
    
    def text_for(selector)
      element = @proposal_page.search(selector).first
      element.nil? ? nil : element.content
    end

    def clean_text(text)
      return unless text
      text.gsub(/\s+/,' ').gsub(/\s*\.\s*$/, '').strip
    end

    def category(name)
      return unless name
      upcase_first(name.gsub(/Comisión( Mixta)?( del?| para las?)? /, ""))
    end

    def upcase_first(string)
      string[0..0].upcase + string[1..-1]
    end

    def proposer(string)
      return unless string
      Proposer.new(string).name
    end

    def full_proposal_text(page)
      if page.search("//*[@class='apartado_iniciativa' and contains(normalize-space(text()),'Boletines:')]") and 
         url = page.link_with(:text => /texto/).href.strip and 
         url.match(/PopUpCGI/)

         law_draft_page = agent.get("http://www.congreso.es" + url)
         law_draft_page.encoding = "utf-8"        
         law_draft_page.search(".texto_completo").text
      end
    end

  end
end