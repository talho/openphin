module SpecHelpers
  module ModelMacros

    def should_make_fields_accessible(*fields)
      fields.each do |field|
        it "should make #{field} accessible" do
          self.class.described_type.new(field => 'foo').send(field).should == 'foo'
        end
      end
    end
    
    def should_make_fields_protected(*fields)
      fields.each do |field|
        it "should make #{field} protected" do
          self.class.described_type.new(field => 'foo').send(field).should_not == 'foo'
        end
      end
    end

  end
end