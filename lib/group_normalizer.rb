=begin
    OpenPHIN is an opensource implementation of the CDC guidelines for 
    a public health information network.
    
    Copyright (C) 2009  Texas Association of Local Health Officials

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

=end
require 'csv'

class GroupNormalizer
  @ou2jur = {
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
    "OU=OrangeCO,OU=RG65,DC=txphin,DC=dshs,DC=state,DC=tx,DC=us" => "ORange",
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

  def self.normalize_groups(filename, options = {})
    options = {:col_sep => ",", :row_sep => :auto}.merge(options)
    file = File.open("new#{filename}", "w")
    file.write("email|jurisdiction|group_name\n")
    CSV.open(filename, :headers => true, :col_sep => options[:col_sep], :row_sep => options[:row_sep]) do |records|
      records.each do |rec|
        email = rec['mail'].strip unless rec['mail'].blank?
        memberof = rec['memberOf'].strip unless rec['memberOf'].blank?
        if email.blank? || memberof.blank?
          STDERR.puts rec.values_at.join(",")
          next
        end
        groups = self.groupsFromMemberOf(memberof)
        groups.each do |group|
          file.write("#{email}|#{group['jurisdiction']},#{group['group']}\n")
        end unless groups.nil?
      end
    end
    file.close()
  end

  def self.groupsFromMemberOf(memberof)
    groups = []
    groupsCN = memberof.split(';')
    groupsCN.each do |cn|
      unless cn.blank?
        cnsplit = cn.split(',')
        group = cnsplit[0][3..-1].strip
        cnsplit.shift
        jurisdiction = @ou2jur[cnsplit.join(',')]
        unless group.blank? || jurisdiction.blank?
          groups << {"group" => group, "jurisdiction" => jurisdiction}
        end
      end
    end
    groups
  end
end
