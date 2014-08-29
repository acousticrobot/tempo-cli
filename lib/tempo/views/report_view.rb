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

        time_records.each do |d_id, days_record|

          day = Tempo::Model::TimeRecord.day_id_to_time d_id

          container = ViewRecords::Container.new
          container.pre = ViewRecords::Message.new day.strftime("Records for %m/%d/%Y:\n\n"), postpone: true
          container.post = ViewRecords::Message.new "\n\n", postpone: true

          days_record.each do |time_record|
            container.add(time_record_view time_record, postpone: true)
          end
        end
      end
    end
  end
end
