class Animal < ApplicationRecord
  belongs_to :user, optional: true
end
