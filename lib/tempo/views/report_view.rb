module Tempo
  module Views
    class << self

      def report_records_view(options={})

        # Haven't we already checked for this?
        projects = options.fetch(:projects, Tempo::Model::Project.index)
        return no_items("projects") if projects.empty?

        # TODO: Document here days index structure, give example of sending in subsets
        # so the Records Controller can manage the organization of the records.
        time_records = options.fetch( :time_records, Tempo::Model::TimeRecord.days_index )

        # It this going to break if 1 of X record containers is empty?
        # Or should the controller not send empty records and this is good to check for?
        # Maybe No time records for <date>?
        return no_items("time records") if time_records.empty?

        if options[:order] == "date" || options[:order] == "d"
          order_by_date time_records
        elsif options[:order] == "project" || options[:order] == "p"
          order_by_project projects, time_records
        else
          return error "Unable to report time records sorted by '#{options[:order]}'"
        end
      end

    private

      def order_by_date(time_records)
        time_records.each do |d_id, days_record|

          day = Tempo::Model::TimeRecord.day_id_to_time d_id

          container = ViewRecords::TimeRecordContainer.new
          container.pre = ViewRecords::Message.new day.strftime("Records for %m/%d/%Y:\n\n"), postpone: true

          days_record.each do |time_record|
            container.add(time_record_view time_record, postpone: true)
          end
        end
      end

      def order_by_project(projects, time_records)
        project_records = Hash.new {|this_hash, nonexistent_key| this_hash[nonexistent_key] = [] }
        time_records.each do |d_id, days_records|
          days_records.each do |days_record|
            # TODO: if project in projects (for filtering)
            project_records[days_record.project] << days_record
          end
        end

        project_records.each do |pr,time_records|
          container = ViewRecords::TimeRecordContainer.new
          #require 'pry'; binding.pry
          container.pre = ViewRecords::Message.new "Records for #{Model::Project.find_by_id(pr).title}\n", postpone: true
          time_records.each do |time_record|
            container.add(time_record_view time_record, postpone: true)
          end
        end
      end
    end
  end
end
