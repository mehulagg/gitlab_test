def bulk_insert_subject_key(subject)
  "bulk_insert::#{subject.object_id}"
end

def bulk_insert_process_collection_item(collection)
  data = collection&.shift
  return unless data

  # assign the key context with the collection
  key = bulk_insert_subject_key(data[:record])

  #puts "Processing item: #{key}"
  Thread.current[key] = data[:collection]

  begin
    saved = data[:association].insert_record(data[:record], data[:validate])
    #puts "Processed item: #{key} => #{saved}"
    raise ActiveRecord::Rollback if !saved && !data[:validate]
    true
  ensure
    Thread.current[key] = nil
  end
end

def bulk_insert_next_for_subject(subject)
  key = bulk_insert_subject_key(subject)
  bulk_insert_process_collection_item(Thread.current[key])
end

MAX_BULK_INSERT = 100

def bulk_insert_flush_table(table_name, with_ids)
  key = "bulk_insert_#{table_name}"
  return unless Thread.current[key].present?

  collection = Thread.current[key]

  puts "Doing bulk insert for #{table_name} with #{collection.count} items"

  ids = Gitlab::Database.bulk_insert(table_name, collection.pluck(:attr), return_ids: with_ids)

  collection.each.with_index do |record, index|
    record[:call].call(ids[index])
  end if with_ids

ensure
  Thread.current[key] = nil
end

def bulk_insert_add_table(table_name, attributes, &blk)
  key = "bulk_insert_#{table_name}"
  Thread.current[key] ||= []
  Thread.current[key] << { attr: attributes, call: blk }

  #puts "Added bulk insert item to #{table_name}, total: #{Thread.current[key].count}"
  Thread.current[key].count >= MAX_BULK_INSERT
end

def bulk_insert_subject_with_values(subject, values)
  table_name = subject.class.table_name

  #puts "Inserting #{table_name} => #{values}"

  id = nil

  needs_flush = bulk_insert_add_table(table_name, values) do |received_id|
    id = received_id
    #puts "Received ID: #{id}"
  end

  if needs_flush || !bulk_insert_next_for_subject(subject)
    bulk_insert_flush_table(table_name, subject.class.primary_key.present?)
  end

  #puts "Done #{table_name} => #{values}"

  id
end

def bulk_insert_all_records(association, records, validate)
  collection = []

  records.each do |record|
    collection << {
      collection: collection,
      association: association,
      record: record,
      validate: validate
    }
  end

  return if collection.empty?

  puts "Gathered all bulk inserts: #{association.reflection.class_name} => #{collection.count}"

  while bulk_insert_process_collection_item(collection)
  end
end

module ActiveRecordPersistence
  extend ActiveSupport::Concern

  def _create_record(*)
    Thread.current[:insert_record_current] = self
    super
  end

  class_methods do
    def _insert_record(values) # :nodoc:
      primary_key_value = nil

      if primary_key && Hash === values
        primary_key_value = values[primary_key]

        if !primary_key_value && prefetch_primary_key?
          primary_key_value = next_sequence_value
          values[primary_key] = primary_key_value
        end
      end

      # we need to merge with the defaults, it is not always given...
      casted_values = columns_hash.map do |key, column_def|
        next if key == primary_key

        [key, values.include?(key) ? type_caster.type_cast_for_database(key, values[key]) : column_def.default]
      end.compact.to_h
  
      bulk_insert_subject_with_values(Thread.current[:insert_record_current], casted_values)
    end
  end
end

module ActiveRecordAutoSave
  def save_collection_association(reflection)
    # puts "save_collection_association: #{reflection.name}"

    association = association_instance_get(reflection.name)
    return unless association

    autosave = reflection.options[:autosave]

    # reconstruct the scope now that we know the owner's id
    association.reset_scope

    if records = associated_records_to_validate_or_save(association, @new_record_before_save, autosave)
      if autosave
        records_to_destroy = records.select(&:marked_for_destruction?)
        records_to_destroy.each { |record| association.destroy(record) }
        records -= records_to_destroy
      end

      bulk_insert_collection = []

      records.each do |record|
        next if record.destroyed?

        saved = true

        if autosave != false && (@new_record_before_save || record.new_record?)
          if autosave
            bulk_insert_collection << {
              collection: bulk_insert_collection,
              association: association,
              record: record,
              validate: false
            }
          else
            unless reflection.nested?
              bulk_insert_collection << {
                collection: bulk_insert_collection,
                association: association,
                record: record,
                validate: true
              }
            end
          end
        elsif autosave
          saved = record.save(validate: false)
        end

        raise ActiveRecord::Rollback unless saved
      end

      return if bulk_insert_collection.empty?

      puts "Gathered all bulk inserts: #{reflection.class_name} => #{bulk_insert_collection.count}"

      while bulk_insert_process_collection_item(bulk_insert_collection)
      end
    end
  end
end

ActiveRecord::Base.prepend(ActiveRecordAutoSave)
ActiveRecord::Base.prepend(ActiveRecordPersistence)

puts "Loaded MyCollectionAssociation"
