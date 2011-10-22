# coding: utf-8

require "congress-scrapper/version"
require "mechanize"
require "progressbar"

module Congress
  module Scrapper
    extend self

    def agent
      @agent ||= Mechanize.new
    end

    def scrape
      search_page = agent.get("http://www.congreso.es/portal/page/portal/Congreso/Congreso/Iniciativas/Busqueda%20Avanzada")
      search_form = search_page.form_with(:action => /enviarCgiBuscadorAvIniciativas/)
      search_form["TPTR"] = "Competencia Legislativa Plena"
      results_page = search_form.submit

      total_results = results_page.search("//*[contains(text(), 'Iniciativas encontradas')]/span").first.text.to_i
      progress = ProgressBar.new("Scrapping", total_results)
      
      proposals = []

      while results_page
        results_page.search(".titulo_iniciativa a").each do |title|
          @proposal_page = agent.get(title[:href])
          
          proposal_type = clean_text(text_for(".subtitulo_competencias"))
          
          resolution = clean_text(text_for("//*[@class='apartado_iniciativa' and contains(normalize-space(text()),'Resultado de la tramitación')]/following-sibling::*[@class='texto']"))

          commission_name = clean_text(text_for("//*[@class='apartado_iniciativa' and contains(normalize-space(text()),'Comisión competente:')]/following-sibling::*[@class='texto']"))

          proposer = clean_text(text_for("//*[@class='apartado_iniciativa' and contains(normalize-space(text()),'Autor:')]/following-sibling::*[@class='texto']"))

          proposed_at_text = text_for("//*[@class='texto' and contains(normalize-space(text()),'Presentado el')]")
          proposed_at = Date.new($3.to_i, $2.to_i, $1.to_i) if proposed_at_text && proposed_at_text.match(/Presentado\s+el\s+(\d\d)\/(\d\d)\/(\d\d\d\d)/)

          closed_at_text = text_for("//*[@class='apartado_iniciativa' and contains(normalize-space(text()),'Tramitación seguida por la iniciativa:')]/following-sibling::*[@class='texto']")
          closed_at = Date.new($3.to_i, $2.to_i, $1.to_i) if closed_at_text && closed_at_text.match(/Concluido\s+.+\s+desde (\d\d)\/(\d\d)\/(\d\d\d\d)/)
          
          proposal = {:title               => clean_text(title.content),
                      :official_url        => "http://www.congreso.es" + title[:href],
                      :proposal_type       => proposal_type,
                      :closed_at           => closed_at,
                      :official_resolution => resolution,
                      :commission_name     => commission_name,
                      :proposer            => proposer,
                      :proposed_at         => proposed_at}
 
          progress.inc
          
          proposals << proposal
        end
        
        next_page =  results_page.link_with(:text => /Siguiente/)
        results_page = next_page.nil? ? nil : next_page.click
      end
      
      progress.finish
      
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
  end
end
