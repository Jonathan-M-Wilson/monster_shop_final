class Coupon < ApplicationRecord
  validates_presence_of :name, :code, :percent_off
  validates_uniqueness_of :name, :code
  validates_presence_of :min_items
  validates_inclusion_of :percent_off, in: (0..100), message: "Field is empty or range is outside 0-100"

  belongs_to :merchant
  has_many :orders

  def self.best_discount(item_count)
    select(:percent_off).where("min_items <= ?", item_count).pluck(:percent_off).max
  end

  def enabled?
    if enabled
      "Enabled"
    else
      "Disabled"
    end
  end
end
