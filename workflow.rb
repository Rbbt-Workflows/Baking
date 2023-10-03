module Pantry
  extend Resource
  self.subdir = 'share/pantry'

  Pantry.claim Pantry.eggs, :proc do |filename|
    Log.info "Buying Eggs in the store"
    "Eggs from #{filename}"
  end

  Pantry.claim Pantry.flour, :proc do |filename|
    Log.info "Buying Flour in the store"
    "Flour from #{filename}"
  end

  Pantry.claim Pantry.blueberries, :proc do |filename|
    Log.info "Buying Bluberries in the store"
    "Bluberries from #{filename}"
  end
end

module Baking
  def self.whisk(eggs)
    "whisking #{eggs}"
  end

  def self.mix(base, mixer)
    "mixing (#{base}) with (#{mixer})"
  end

  def self.bake(batter)
    "baking batter (#{batter})"
  end
end

module Baking
  extend Workflow

  self.title = "Bake some muffins" if self.respond_to?(:title)

  self.description =<<-EOF 
Use this workflow to test your scout. The workflow consist only of 3 steps that represents the steps to making muffins. What 
these different steps actually make is a string that contains a description of the actions taken.
EOF

  desc 'Put batter in the oven'
  dep :prepare_batter
  task :bake_muffin_tray => :string do 
    Baking.bake(step(:prepare_batter).load)
  end

  desc 'Mix the whisked eggs with flour, blueberries are optional'
  dep :whisk_eggs
  input :blueberries, :boolean, "Blue berries can give a lot of flavour", nil
  task :prepare_batter => :string do |add_blueberries|
    whisked_eggs = step(:whisk_eggs).load
    batter = Baking.mix(whisked_eggs, Pantry.flour.read)

    if add_blueberries
      batter = Baking.mix(batter, Pantry.blueberries.read) 
    end

    batter
  end

  desc 'Whisk some eggs'
  task :whisk_eggs => :string do
    Baking.whisk(Pantry.eggs.read)
  end

  # Task alises. They need to be at the end
  dep_task :bake_blueberry_muffin_tray, Baking, :bake_muffin_tray, :blueberries => true
end


