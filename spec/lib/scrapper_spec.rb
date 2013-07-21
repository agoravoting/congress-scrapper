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
      stub_request(:get, proposal_page3).to_return(:body => fixture(:proposal_with_law_draft), :headers => { 'Content-Type' => 'text/html' })
      stub_request(:get, proposal_page4).to_return(:body => fixture(:closed_proposal_page), :headers => { 'Content-Type' => 'text/html' })

      stub_request(:get, /#{full_proposal_text}/).to_return(:body => fixture(:full_proposal_text), :headers => { 'Content-Type' => 'text/html' })
    end
    
    it "should go to the proposal search form" do
      Congress::Scrapper.scrape
      a_request(:get, search_page).should have_been_made.times(2)
    end
    
    it "should search the proposals we're interested in" do
      Congress::Scrapper.scrape
      a_request(:post, search_results_page).with{|r| r.body =~ /TPTR=Competencia\+Legislativa\+Plena/}.should have_been_made.times(2)
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

    it "should populate the full proposal text" do
      proposals = Congress::Scrapper.scrape
      proposal = proposals[2]
      proposal[:official_url].should        == proposal_page3
      proposal[:body].should                =~ /En cumplimiento de lo dispuesto en el artículo 86.2/
    end
    
  end
end