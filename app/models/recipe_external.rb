class RecipeExternal < ActiveRecord::Base

  require 'base32/crockford'  # for naming the filtered file

  extend RecipeModule

end

