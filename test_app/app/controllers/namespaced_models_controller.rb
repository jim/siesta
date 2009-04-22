class NamespacedModelsController < ApplicationController
  siesta 'Creature::Merfolk', 'Weapon::Trident', :actions => :all
end