# coding: utf-8
class Proposer
  
  attr_accessor :name

  def initialize(string)
    @name = string
  end

  def name
    full_name ? short_name(full_name) : @name  
  end

  def full_name 
    mapping.map(&:last).index(@name)
  end

  def short_name(index)
    mapping[index].first
  end

  def mapping
    [["PSOE",                "Grupo Parlamentario Socialista"],
     ["PP",                  "Grupo Parlamentario Popular en el Congreso"],
     ["Convergència i Unió", "Grupo Parlamentario Catalán (Convergència i Unió)"],
     ["PNV",                 "Grupo Parlamentario Vasco (EAJ-PNV)"],
     ["Izquierda Unida",     "Grupo Parlamentario de Esquerra Republicana-Izquierda Unida-Iniciativa per Catalunya Verds"],
     ["Grupo Mixto",         "Grupo Parlamentario Mixto"],
     ["PSOE",                "Senado Grupo Parlamentario Socialista"],
     ["PP",                  "Senado Grupo Parlamentario Popular en el Senado"],
     ["Convergència i Unió", "Senado Grupo Parlamentario Catalán en el Senado de Convergencia i Unió"],
     ["PNV",                 "Senado Grupo Parlamentario de Senadores Nacionalistas"],
     ["Izquierda Unida",     "Senado Grupo Parlamentario de Entesa Catalana de Progrés"],
     ["Grupo Mixto",         "Senado Grupo Parlamentario Mixto"],
     ["Andalucía",           "Comunidad Autónoma de Andalucía-Parlamento"],
     ["Aragón",              "Comunidad Autónoma de Aragón-Cortes"],
     ["Canarias",            "Comunidad Autónoma de Canarias - Parlamento"],
     ["Castilla y León",     "Comunidad Autónoma de Castilla y León - Cortes"],
     ["Castilla-La Mancha",  "Comunidad Autónoma de Castilla-La Mancha - Cortes"],
     ["Cataluña",            "Comunidad Autónoma de Cataluña - Parlamento"],
     ["Extremadura",         "Comunidad Autónoma de Extremadura - Asamblea"],
     ["Galicia",             "Comunidad Autónoma de Galicia - Parlamento"],
     ["Murcia",              "Comunidad Autónoma de la Región de Murcia - Asamblea Regional"],
     ["La Rioja",            "Comunidad Autónoma de La Rioja - Diputación General"],
     ["Baleares",            "Comunidad Autónoma de las Illes Balears - Gobierno"],
     ["País Vasco",          "Comunidad Autónoma del País Vasco - Gobierno"],
     ["País Vasco",          "Comunidad Autónoma del País Vasco - Parlamento"]]
  end
end