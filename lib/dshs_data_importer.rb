require 'fastercsv'

class DshsDataImporter
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

  def self.userImport filename=nil
    abort "You did not specify a file to import or file does not exist, please call as rake dshs_data_migrate file=<filename_and_path>" if filename.blank? || !File.exists?(filename)
    rows = []
    finalrows = []
    csv = FasterCSV.open(filename, :headers => false)
    #puts csv.shift().to_csv
    FasterCSV.open(filename, :headers => true) do |records|
      records.each do |row|
        unless self.check_email(row['mail']) && !row['displayName'].blank?
          #puts row
          next
        end
        rows << row
      end
    end
    mails = rows.map{|row| row['mail']}
    rows.each do |row|
      unless mails.index(row['mail']) == mails.rindex(row['mail'])
        #puts row
        next
      end
      finalrows << row
    end
    finalrows.each do |row|
      name = row["displayName"].strip
      email = row["mail"].strip
      first_name = self.first_name(name)
      last_name = (name == first_name ? "" : self.last_name(name))
      jurisdiction = Jurisdiction.find_by_name(@ou2jur[row["DN"].sub(/^CN=.*?,/, '')])
      user = User.new(:first_name => first_name, :last_name => last_name, :display_name => name, :email => email, :password => "66w9X9bY4uJZtxKuD7Yo")
      @bad = nil
      if user.valid? && !jurisdiction.nil?
        begin
          user.save!
          @bad = RoleMembership.create!(:user => user, :jurisdiction => jurisdiction, :role => Role.public) unless RoleMembership.alread_exists?(user,Role.public
          ,jurisdiction)
        rescue
          puts user
          debugger
        end
      else
        #puts row
      end
      a = 1
    end
  end


  def self.first_name(name)
    prefixes = ["dr.","dr","ms.","ms","miss","mrs.","mrs"]
    first = name.sub(/\s.*/,'').strip
    last = name.sub(/^.*?\s/,'').strip
    if first.downcase == "le"
      first = "#{first} #{last.sub(/\s.*/,'')}"
    else
      first = last.sub(/\s.*/,'') if prefixes.include?(first.downcase)
    end
    first.strip
  end

  def self.last_name(name)
    suffixes = ["m.d.","md","i","ii","iii","iv","sr.","sr","jr.","jr","d.v.m.","dvm"]
    last = name.sub(/.*\s/,'').strip
    first = name.sub(/\s#{last}$/,'').strip
    last = first.sub(/.*\s/,'') if suffixes.include?(last.downcase)
    last.strip
  end

  EmailAddress = begin
    qtext = '[^\\x0d\\x22\\x5c\\x80-\\xff]'
    dtext = '[^\\x0d\\x5b-\\x5d\\x80-\\xff]'
    atom = '[^\\x00-\\x20\\x22\\x28\\x29\\x2c\\x2e\\x3a-' +
      '\\x3c\\x3e\\x40\\x5b-\\x5d\\x7f-\\xff]+'
    quoted_pair = '\\x5c[\\x00-\\x7f]'
    domain_literal = "\\x5b(?:#{dtext}|#{quoted_pair})*\\x5d"
    quoted_string = "\\x22(?:#{qtext}|#{quoted_pair})*\\x22"
    domain_ref = atom
    sub_domain = "(?:#{domain_ref}|#{domain_literal})"
    word = "(?:#{atom}|#{quoted_string})"
    domain = "#{sub_domain}(?:\\x2e#{sub_domain})*"
    local_part = "#{word}(?:\\x2e#{word})*"
    addr_spec = "#{local_part}\\x40#{domain}"
    pattern = /\A#{addr_spec}\z/
  end

  def self.check_email(email)
    (email =~ EmailAddress).nil? ? false : true
  end
end
