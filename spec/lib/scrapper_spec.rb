# coding: utf-8
require File.dirname(__FILE__) + "/scrapper_spec_helper"
require File.dirname(__FILE__) + "/../../lib/congress-scrapper"

describe Congress::Scrapper do
  
  describe "scrape" do
    
    before(:each) do
      stub_request(:get, search_page).to_return(:body => fixture(:search_page), :headers => { 'Content-Type' => 'text/html' })
      stub_request(:post, search_results_page).to_return(:body => fixture(:search_results_page1), :headers => { 'Content-Type' => 'text/html' })
      stub_request(:get, search_results_next_page).to_return(:body => fixture(:search_results_page2), :headers => { 'Content-Type' => 'text/html' })
      stub_request(:get, proposal_page1).to_return(:body => fixture(:open_proposal_page), :headers => { 'Content-Type' => 'text/html' })
      stub_request(:get, proposal_page2).to_return(:body => fixture(:closed_proposal_with_changes_page), :headers => { 'Content-Type' => 'text/html' })
      stub_request(:get, proposal_page3).to_return(:body => "", :headers => { 'Content-Type' => 'text/html' })
      stub_request(:get, proposal_page4).to_return(:body => fixture(:closed_proposal_page), :headers => { 'Content-Type' => 'text/html' })
    end
    
    it "should go to the proposal search form" do
      Congress::Scrapper.scrape
      a_request(:get, search_page).should have_been_made
    end
    
    it "should search the proposals we're interested in" do
      Congress::Scrapper.scrape
      a_request(:post, search_results_page).with{|r| r.body =~ /TPTR=Competencia\+Legislativa\+Plena/}.should have_been_made
    end
    
    it "should create one proposal for record found" do
      proposals = Congress::Scrapper.scrape
      proposals.collect { |p| p[:title] }.should == [
        "Proyecto de Ley de almacenamiento geológico de dióxido de carbono",
        "Proyecto de Ley del régimen de cesión de tributos del Estado a la Comunitat Valenciana y de fijación del alcance y condiciones de dicha cesión",
        "Proyecto de Ley de Reforma del Sistema de Apoyo Financiero a la Internacionalización de la empresa española",
        "Proyecto de Ley por la que se modifica el Estatuto Legal del Consorcio de Compensación de Seguros, aprobado por el Real Decreto Legislativo 7/2004, de 29 de octubre, para suprimir las funciones del Consorcio de Compensación de Seguros en relación con los seguros obligatorios de viajeros y del cazador y reducir el recargo destinado a financiar las funciones de liquidación de entidades aseguradoras, y el texto refundido de la Ley de Ordenación y Supervisión de los Seguros Privados, aprobado por el Real Decreto Legislativo 6/2004, de 29 de octubre"
      ]
    end
    
    it "should populate open proposals info" do
      proposals = Congress::Scrapper.scrape
      proposal = proposals.first
      proposal[:official_url].should == proposal_page1
      proposal[:proposal_type].should == "Proyecto de ley"
      proposal[:closed_at].should be_nil
      proposal[:status].should == "Comisión de Medio Ambiente, Agricultura y Pesca Enmiendas"
      proposal[:proposed_at].should == Date.new(2010, 4, 9)
      proposal[:category_name].should == "Medio Ambiente, Agricultura y Pesca"
      proposal[:proposer_name].should == "PSOE"
    end
    
    it "should populate closed proposals info with modifications" do
      proposals = Congress::Scrapper.scrape
      proposal = proposals[1]
      proposal[:official_url].should        == proposal_page2
      proposal[:proposal_type].should       == "Proyecto de ley"
      proposal[:closed_at].should           == Date.new(2012, 10, 24)
      proposal[:status].should == "Concluido - (Aprobado con modificaciones)"
      proposal[:category_name].should       == "Hacienda y Administraciones Públicas"
      proposal[:proposer_name].should       == "Gobierno"
    end

    it "should populate closed proposals info without modifications" do
      proposals = Congress::Scrapper.scrape
      proposal = proposals.last
      proposal[:official_url].should        == proposal_page4
      proposal[:proposal_type].should       == "Proyecto de ley"
      proposal[:closed_at].should           == Date.new(2009, 6, 24)
      proposal[:status].should == "Aprobado sin modificaciones"
      proposal[:category_name].should       == "Economía y Hacienda"
      proposal[:proposer_name].should       == "Gobierno"
    end
    
  end
end