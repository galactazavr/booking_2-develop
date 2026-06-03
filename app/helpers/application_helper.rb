module ApplicationHelper
  def all_db_cities
    @all_db_cities ||= begin
      cities = (Hotel.active.distinct.pluck(:city) + Property.active.distinct.pluck(:city))
      cities.map { |c| c.to_s.strip }.uniq.compact.reject(&:blank?).sort
    end
  end
end
