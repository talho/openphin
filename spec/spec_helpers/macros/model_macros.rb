module SpecHelpers
  module ModelMacros

    def should_make_fields_accessible(*fields)
      fields.each do |field|
        it "should make #{field} accessible" do
          self.class.described_type.new(field => 'foo').send(field).should == 'foo'
        end
      end
    end

  end
end