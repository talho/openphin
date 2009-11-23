#!/usr/bin/ruby
#

require 'rubygems'
require 'fastercsv'
require 'activesupport'

filename=ARGV[0]

class NormalizerBase
@@ou2jur = {
    "OU=AngelinaCO,OU=RG45,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Angelina",
    "OU=BeaumontPublicHealthDept,OU=RG65,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Jefferson",
    "OU=BellCO,OU=RG07,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Bell",
    "OU=BowieCO,OU=RG45,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Bowie",
    "OU=BrazoriaCO,OU=RG65,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Brazoria",
    "OU=BrazosCO,OU=RG07,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Brazos",
    "OU=BrownCO,OU=RG023,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Brown",
    "OU=CalhounCO,OU=RG08,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Calhoun",
    "OU=CameronCO,OU=RG11,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Cameron",
    "OU=ChambersCO,OU=RG65,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Chambers",
    "OU=CherokeeCO,OU=RG45,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Cherokee",
    "OU=CityofAmarillo,OU=RG01,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Potter",
    "OU=CityofAndrews,OU=RG910,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Andrews",
    "OU=CityofDallas,OU=RG023,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Dallas",
    "OU=CityofFortWorth,OU=RG023,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Tarrant",
    "OU=CityofHouston,OU=RG65,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Harris",
    "OU=CityofLaredo,OU=RG11,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Webb",
    "OU=CityofLubbock,OU=RG01,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Lubbock",
    "OU=CityofPortArthur,OU=RG65,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Jefferson",
    "OU=CO,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Texas",
    "OU=CollinCO,OU=RG023,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Collin",
    "OU=ComalCO,OU=RG08,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Comal",
    "OU=CorpusChristiNuecesCO,OU=RG11,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Nueces",
    "OU=DallasCO,OU=RG023,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Dallas",
    "OU=DentonCO,OU=RG023,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Denton",
    "OU=DeWittCO,OU=RG08,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "DeWitt",
    "OU=EctorCO,OU=RG910,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Ector",
    "OU=ElPasoCO,OU=RG910,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "El Paso",
    "OU=FortBendCO,OU=RG65,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Fort Bend",
    "OU=GalvestonCO,OU=RG65,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Galveston",
    "OU=GraysonCO,OU=RG023,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Grayson",
    "OU=GreggCO,OU=RG45,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Gregg",
    "OU=HaleCO,OU=RG01,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Hale",
    "OU=HardinCO,OU=RG65,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Hardin",
    "OU=HarrisCO,OU=RG65,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Harris",
    "OU=HaysCO,OU=RG07,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Hays",
    "OU=HidalgoCO,OU=RG11,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Hidalgo",
    "OU=HuntCO,OU=RG023,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Hunt",
    "OU=JacksonCO,OU=RG08,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Jackson",
    "OU=JasperNewtonCO,OU=RG45,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Jasper",
    "OU=LiveOakCO,OU=RG11,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Live Oak",
    "OU=MACC Users,OU=MACC Groups,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Texas",
    "OU=McLennanCO,OU=RG07,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "McLennan",
    "OU=MedinaCO,OU=RG08,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Medina",
    "OU=MidlandCO,OU=RG910,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Midland",
    "OU=MilamCO,OU=RG07,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Milam",
    "OU=MontgomeryCO,OU=RG65,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Montgomery",
    "OU=NavarroCO,OU=RG023,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Navarro",
    "OU=NolanCO,OU=RG023,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Nolan",
    "OU=OrangeCO,OU=RG65,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Orange",
    "OU=RG01,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Region 1",
    "OU=RG023,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Region 2/3",
    "OU=RG45,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Region 4/5 North",
    "OU=RG65,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Region 6/5 South",
    "OU=RG07,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Region 7",
    "OU=RG08,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Region 8",
    "OU=RG910,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Region 9/10",
    "OU=RG11,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Region 11",
    "OU=SanAntonioMetro,OU=RG08,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Bexar",
    "OU=SanPatricioCO,OU=RG11,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "San Patricio",
    "OU=ScurryCO,OU=RG023,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Scurry",
    "OU=SmithCO,OU=RG45,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Smith",
    "OU=SouthPlains,OU=RG01,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Terry",
    "OU=TarrantCO,OU=RG023,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Tarrant",
    "OU=TaylorCO,OU=RG023,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Taylor",
    "OU=TravisCO,OU=RG07,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Travis",
    "OU=TomGreenCO,OU=RG910,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Tom Green",
    "OU=UvaldeCO,OU=RG08,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Uvalde",
    "OU=VictoriaCO,OU=RG08,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Victoria",
    "OU=WichitaCO,OU=RG023,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Wichita",
    "OU=WilliamsonCO,OU=RG07,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Williamson",
    "OU=WoodCO,OU=RG45,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "Wood"
  }
@@bad_ous=[
"CN=Users,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us",
"DC=txphin,DC=dshs,DC=state,DC=tx,DC=us",
"OU=Essence,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us",
"OU=ServiceAccounts,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us",
"OU=Shared Directory Access,OU=MACC Groups,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us",
"OU=Specimens,OU=Shared Directory Access,OU=MACC Groups,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us",
"OU=TMB Data,OU=Shared Directory Access,OU=MACC Groups,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us",
"OU=TactComm,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us",
"OU=Test,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us"
]

  @@prefixes = ["dr.","dr","ms.","ms","miss","mrs.","mrs"]
  @@suffixes = ["m.d.","md","i","ii","iii","iv","sr.","sr","jr.","jr","d.v.m.","dvm"]
  def ou_to_jur(dn)
    ou=dn.split(",")[1..-1].join(",")
    return nil if @@bad_ous.include?(ou)

    jur=@@ou2jur[ou]
  end
  def first_name(name)
    return nil if name.nil? || name.strip == ""
    first = name.sub(/\s.*/,'').strip
    last = name.sub(/^.*?\s/,'').strip
    if first.downcase == "le"
      first = "#{first} #{last.sub(/\s.*/,'')}"
    else
      first = last.sub(/\s.*/,'') if @@prefixes.include?(first.downcase)
    end
    first.strip
  end

  def last_name(name)
    return nil if name.nil? || name.strip == ""
    last = name.sub(/.*\s/,'').strip
    first = name.sub(/\s#{last}$/,'').strip
    last = first.sub(/.*\s/,'') if @@suffixes.include?(last.downcase)
    last.strip
  end
  
end
class UserNormalizer < NormalizerBase
  def normalize_record(record)
  end
end
class ContactNormalizer < NormalizerBase
  def normalize_record(record)
    return nil unless record['DN'] && record['displayName'] && record['mail']

    jur=ou_to_jur(record['DN'])
    displayname=record['displayName'].split(/\s/).reject{|item| item.blank?}.join(" ")
    first = first_name(displayname)
    last = last_name(displayname)
    email = record['mail'].strip unless record['mail'].nil?
    mobile = record['mobile'].strip unless record['mobile'].nil?
    fax = record['facsimileTelephoneNumber'].strip unless record['facsimileTelephoneNumber'].nil?
    phone = record['telephoneNumber'].strip unless record['telephoneNumber'].nil?
    
    return nil if email.nil? || email.strip == ""

    [email, first, last, displayname, jur, mobile, fax, phone]
  end
end
ci=ContactNormalizer.new
ui=UserNormalizer.new

puts "email|first_name|last_name|display_name|jurisdiction|mobile|fax|phone"
FasterCSV.open(filename, :headers => true) do |records|
  records.each do |rec|
    case rec['objectClass']
      when 'contact'
        normal=ci.normalize_record(rec)
      when 'user'
        normal=ci.normalize_record(rec)
    end
    puts normal.join("|") if normal
  end
end

