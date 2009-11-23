class Stat < ActiveRecord::Base
  validates_presence_of :start, :stop
  validates_inclusion_of :group_by, :in => %w( user location location_group )
  validates_inclusion_of :view_by, :in => %w( day week month quarter year all)

  def start_date
    @start_date
  end

  def start_date=(sd)
    @start_date = Date.parse sd
    self.start = @start_date.to_time
  rescue ArgumentError
    @invalid_start_date = true
  end

  def stop_date
    @stop_date ||= Date.today
  end

  def stop_date=(sd)
    @stop_date = Date.parse sd
    self.stop = @stop_date.to_time
  rescue ArgumentError
    @invalid_stop_date = true
  end


  def display
    "Stats from #{start.to_s(:short_name)} to #{stop.to_s(:short_name)}"
  end
  def shifts(reset=false)
    if reset || @shifts.nil? # recalculate if reset is on or @shifts not calculated yet
      @shifts = find_shifts
      t1 = 	(@shifts)
      t2 = filter_by_departments(t1)
      @shifts = t2
    end
    @shifts
  end

  def time_slots(reset=false)
    debugger
    if reset || @time_slots.nil? # recalculate if reset is on or @shifts not calculated yet
      @time_slots = find_time_slots
      t1 = filter_by_location_groups(@time_slots)
      t2 = filter_by_departments(t1)
      @time_slots = t2
    end
    @time_slots
  end

  def split_to_view(shift_list)
    case view_by
      when "all"
        x = ActiveSupport::OrderedHash.new
        x[start] = shift_list
        x
      else
        methodname = "beginning_of_#{view_by}"
        shift_list.group_by {|sh| sh.start.send(methodname)}
      end
  end

  def split_to_days
    hash = {}
    (start_date...stop_date).each { |d| hash[d] = [] }
    (shifts||[]).each do |sh|
      hash[sh.date] << sh
    end
    hash
  end

  def user_list
    shifts.collect { |sh| sh.user }.uniq
  end

  def location_list
    shifts.collect { |sh| sh.location }.uniq
  end

  def location_group_list
    shifts.collect { |sh| sh.location.loc_group }.uniq
  end

  def users_string
    @us
  end
  def users_string=(str)
    @us = str
    self.user_ids = str.split(/\s*,\s*/).map { |s| User.find_by_name(s).id rescue nil  }.compact.join(',')
  end

  def location_id_array=(arr)
    self.location_ids = arr.join(',') unless arr.blank?
  end

  def location_group_id_array=(arr)
    self.location_group_ids = arr.join(',') unless arr.blank?
  end

  def view_title(time)
    case view_by
    when "all"
      "All shifts since #{time.to_s(:short_name)}"
    else
      "#{view_by.capitalize} starting on #{time.to_s(:just_date)}"
    end
  end
  #CLASS methods
  def self.view_formats
    %w( day week month quarter year all)
  end

  def self.group_formats
    %w( user location location_group )
  end

  def self.split_to_users(shift_list)
    (shift_list||[]).group_by {|s| s.user_id}
  end

  def self.split_to_locations(shift_list)
    (shift_list||[]).group_by {|s| s.location_id}
  end

  def self.split_to_location_groups(shift_list)
    (shift_list||[]).group_by {|s| s.location.loc_group_id}
  end

  #TODO: Use memoize feature from rails 2.2 for this
  def self.filter_late(shift_list)
    (shift_list||[]).select { |s| s.late? }
  end

  def self.filter_missed(shift_list)
    (shift_list||[]).select { |e| e.report.nil? }
  end

  def self.actual_vs_scheduled(shift_list)
    covered = 0;
    total = 0;
    (shift_list||[]).each do |sh|
      if sh.scheduled?
        total += sh.end - sh.start if sh.end
        covered += (sh.report.departed - sh.report.arrived) if sh.report && sh.report.departed
      end
    end
    if total.zero?
      0
    else
      "%.1f / %.1f" % [covered/3600,total/3600]
    end
  end

  def self.duration(shift_list)
    total = 0
    (shift_list || []).each do |sh|
      total += sh.end - sh.start if sh.end
    end
    total/3600
  end

  private
  #used to filter user_id, location_id, location_group_id, department_id
  def filter_by_location_groups(shift_list)
    unless location_group_ids.blank?
      id_list = location_group_ids.split(/,\s*/).map { |i| i.to_i }
      filtered = shift_list.select { |s| id_list.include?(s.location.location_group_id) }
    else
      shift_list
    end
  end

  def filter_by_departments(shift_list)
    unless department_ids.blank?
      id_list = department_ids.split(/,\s*/).map { |i| i.to_i }
      filtered = shift_list.select { |s| id_list.include?(s.location.loc_group.department_id) }
    else
      shift_list
    end
  end

  def find_time_slots
    temp = TimeSlot.on_days(start, stop)
    if location_ids.blank?
      temp
    else
      temp.find(:all, :conditions => ["time_slots.location_id IN (#{location_ids})"], :include => {:location => :location_group})
    end
    return temp
  end

  def find_shifts
    Shift.on_days(start, stop).find(:all, :conditions => conditions, :include => {:location => :loc_group})
  end

  def users_conditions
    ["shifts.user_id IN (#{user_ids})"] unless user_ids.blank?
  end

  def locations_conditions
    ["shifts.location_id IN(#{location_ids})"] unless location_ids.blank?
  end

  def conditions_clauses
    conditions_parts.map { |cond| cond.first }
  end

  def conditions
    [conditions_clauses.join(' AND '), *conditions_options]
  end

  def conditions_options
    conditions_parts.map { |cond| cond[1..-1] }.flatten #get rid of first element in each and flatten
  end

  def conditions_parts
    private_methods(false).grep(/_conditions$/).map { |m| send(m) }.compact
  end

  def validate
    errors.add(:start_date, "is invalid") if @invalid_start_date
    errors.add(:stop_date, "is invalid") if @invalid_stop_date
  end
end
