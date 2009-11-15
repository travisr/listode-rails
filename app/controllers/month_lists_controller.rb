class MonthListsController < ApplicationController
  before_filter :require_user
  
  def index
    today = Date.today
    @month_list = current_user.month_lists.first(:conditions => ["year = ? AND month = ?", today.year, today.month])
  end
  
  def generate
    today = Date.today
    # before we generate a list, make sure they don't already have one
    if current_user.month_lists.first(:conditions => ["year = ? AND month = ?", today.year, today.month]).nil?
      month_list = current_user.month_lists.new(:year => today.year, :month => today.month)
      current_user.tasks.active.each do |task|
        month_list.lists << List.new(:task_id => task.id)
      end
      month_list.save
    end
    redirect_to lists_path
  end
  
  def next_month
    # get the month and year for next month
    get_next_month_and_year
    @month_list = current_user.month_lists.first(:conditions => ["year = ? AND month = ?", @next_year, @next_month])
    # if we can't find the list, we need to generate one
    if @month_list.nil?
      @month_list = current_user.month_lists.new(:year => @next_year, :month => @next_month)
      current_user.tasks.active.each do |task|
        @month_list.lists << List.new(:task_id => task.id)
      end
      @month_list.save
    end
  end
  
  def previous
    @month_lists = current_user.month_lists.paginate(:all, :page => params[:page], :per_page => 10, :order => 'year DESC, month DESC')
  end
  
  def past
    @month_list = current_user.month_lists.first(:conditions => ["year = ? AND month = ?", params[:year], params[:month]])
  end
  
end
