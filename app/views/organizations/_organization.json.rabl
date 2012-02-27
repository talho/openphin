
attributes :name, :description, :id, :locality, :postal_code, :state, :street, :phone, :distribution_email
node(:long_description) {|o| simple_format(o.long_description)}